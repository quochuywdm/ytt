import Foundation

public enum YouTubeTranscriptKit {
    public enum TranscriptError: Error {
        case invalidURL
        case invalidVideoID
        case networkError(Error)
        case noTranscriptData
        case invalidHTMLFormat
        case jsonParsingError(Error)
        case noCaptionData
        case invalidXMLFormat
        case noVideoInfo
    }

    private static func youtubeURL(fromID videoID: String) throws -> URL {
        guard !videoID.isEmpty else {
            throw TranscriptError.invalidVideoID
        }

        guard let url = URL(string: "https://www.youtube.com/watch?v=\(videoID)") else {
            throw TranscriptError.invalidURL
        }

        return url
    }

    // MARK: - Video Info

    public static func getVideoInfo(videoID: String) async throws -> VideoInfo {
        let url = try youtubeURL(fromID: videoID)
        return try await getVideoInfo(url: url)
    }

    public static func getVideoInfo(url: URL) async throws -> VideoInfo {
        let data: Data
        do {
            (data, _) = try await URLSession.shared.data(from: url)
        } catch {
            throw TranscriptError.networkError(error)
        }

        guard let htmlString = String(data: data, encoding: .utf8) else {
            throw TranscriptError.invalidHTMLFormat
        }

        let tags = parseHTMLTags(from: htmlString)
        return extractVideoInfo(from: tags)
    }

    // MARK: - Transcripts

    public static func getTranscript(videoID: String) async throws -> [TranscriptMoment] {
        let url = try youtubeURL(fromID: videoID)
        return try await getTranscript(url: url)
    }

    public static func getTranscript(url: URL) async throws -> [TranscriptMoment] {
        let data: Data
        do {
            (data, _) = try await URLSession.shared.data(from: url)
        } catch {
            throw TranscriptError.networkError(error)
        }

        guard let htmlString = String(data: data, encoding: .utf8) else {
            throw TranscriptError.invalidHTMLFormat
        }

        let tracks = try extractCaptionTracks(from: htmlString)
        let text = try await getTranscriptText(from: tracks)
        return text
    }

    // MARK: - Private

    private static func parseHTMLTags(from html: String) -> (meta: [MetaTag], links: [LinkTag]) {
        var metaTags: [MetaTag] = []
        var linkTags: [LinkTag] = []

        // Find all meta tags
        let metaPattern = #/<meta[^>]+>/# // matches <meta ...> tags
        for match in html.matches(of: metaPattern) {
            if let tag = MetaTag(tag: String(match.0)) {
                metaTags.append(tag)
            }
        }

        // Find all link tags
        let linkPattern = #/<link[^>]+>/# // matches <link ...> tags
        for match in html.matches(of: linkPattern) {
            if let tag = LinkTag(tag: String(match.0)) {
                linkTags.append(tag)
            }
        }

        return (metaTags, linkTags)
    }

    private static func extractVideoInfo(from tags: (meta: [MetaTag], links: [LinkTag])) -> VideoInfo {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        // Helper to find meta tag content
        func metaContent(property: String? = nil, name: String? = nil) -> String? {
            if let property = property {
                return tags.meta.first { $0.property == property }?.content
            }
            if let name = name {
                return tags.meta.first { $0.name == name }?.content
            }
            return nil
        }

        // Try to get each field, but don't require any
        let title = metaContent(property: "og:title") ?? metaContent(name: "title")
        let channelName = metaContent(property: "og:video:director") ?? metaContent(name: "author")
        let publishedStr = metaContent(property: "og:video:release_date") ?? metaContent(name: "uploadDate")
        let published = publishedStr.flatMap { dateFormatter.date(from: String($0.prefix(10))) }
        let description = metaContent(property: "og:description") ?? metaContent(name: "description")
        let channelId = metaContent(name: "channelId")

        // Parse numbers, defaulting to nil on failure
        let viewCount = metaContent(name: "interactionCount").flatMap { Int($0) }
        let likeCount = metaContent(name: "likes").flatMap { Int($0) }

        return VideoInfo(
            title: title?.stringByDecodingHTMLEntities,
            channelId: channelId,
            channelName: channelName?.stringByDecodingHTMLEntities,
            description: description?.stringByDecodingHTMLEntities,
            publishedAt: published,
            viewCount: viewCount,
            likeCount: likeCount
        )
    }

    private static func getTranscriptText(from tracks: [CaptionTrack]) async throws -> [TranscriptMoment] {
        for track in tracks {
            do {
                return try await getTranscriptText(from: track)
            } catch {
                continue
            }
        }
        throw TranscriptError.noTranscriptData
    }

    private static func getTranscriptText(from track: CaptionTrack) async throws -> [TranscriptMoment] {
        let urlString = track.baseUrl.hasPrefix("http") ? track.baseUrl : "https://www.youtube.com\(track.baseUrl)"
        guard let url = URL(string: urlString) else {
            throw TranscriptError.invalidURL
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        guard let xmlString = String(data: data, encoding: .utf8) else {
            throw TranscriptError.invalidXMLFormat
        }

        return try parseTranscriptXML(xmlString)
    }

    private static func parseTranscriptXML(_ xml: String) throws -> [TranscriptMoment] {
        var moments: [TranscriptMoment] = []
        var searchRange = xml.startIndex..<xml.endIndex

        while let startTagRange = xml.range(of: #"<text start="([^"]+)" dur="([^"]+)">"#, options: .regularExpression, range: searchRange),
              let endTagRange = xml[startTagRange.upperBound...].range(of: "</text>") {

            let attributes = xml[startTagRange]
            guard let startMatch = attributes.range(of: #"start="([^"]+)""#, options: .regularExpression),
                  let durMatch = attributes.range(of: #"dur="([^"]+)""#, options: .regularExpression),
                  let start = Double(xml[startMatch].dropFirst(7).dropLast()),
                  let duration = Double(xml[durMatch].dropFirst(5).dropLast()) else {
                searchRange = endTagRange.upperBound..<xml.endIndex
                continue
            }

            let xmlContent = String(xml[startTagRange.upperBound..<endTagRange.lowerBound])
            let htmlContent = xmlContent.stringByDecodingHTMLEntities
            let textContent = htmlContent.stringByDecodingHTMLEntities

            moments.append(TranscriptMoment(start: start, duration: duration, text: textContent))
            searchRange = endTagRange.upperBound..<xml.endIndex
        }

        return moments
    }

    private static func extractCaptionTracks(from htmlString: String) throws -> [CaptionTrack] {
        var allTracks: [CaptionTrack] = []
        var searchRange = htmlString.startIndex..<htmlString.endIndex
        var matchCount = 0

        while let range = htmlString.range(of: "var ytInitialPlayerResponse = ", range: searchRange),
              let endRange = htmlString[range.upperBound...].range(of: ";</script>") {
            matchCount += 1

            let jsonString = String(htmlString[range.upperBound..<endRange.lowerBound])

            if let jsonData = jsonString.data(using: .utf8) {
                do {
                    let response = try JSONDecoder().decode(CaptionsResponse.self, from: jsonData)
                    let tracks = response.captions.playerCaptionsTracklistRenderer.captionTracks
                    allTracks.append(contentsOf: tracks)
                } catch {
                    // Silently continue to next match on parse failure
                }
            }

            searchRange = endRange.upperBound..<htmlString.endIndex
        }

        guard !allTracks.isEmpty else {
            throw TranscriptError.noCaptionData
        }

        // Sort tracks: English first (prioritizing non 'a' vssId), then others
        return allTracks.sorted { track1, track2 in
            if track1.languageCode == "en" && track2.languageCode != "en" {
                return true
            }
            if track1.languageCode != "en" && track2.languageCode == "en" {
                return false
            }
            if track1.languageCode == "en" && track2.languageCode == "en" {
                let track1StartsWithA = track1.vssId.hasPrefix("a")
                let track2StartsWithA = track2.vssId.hasPrefix("a")
                return track1StartsWithA == track2StartsWithA ? true : !track1StartsWithA
            }
            return true
        }
    }
}
