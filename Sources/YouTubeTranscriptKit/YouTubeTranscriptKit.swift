import Foundation

public struct YouTubeTranscriptKit {
    public struct CaptionTrack: Codable {
        public let baseUrl: String
        public let vssId: String
        public let languageCode: String
    }

    public struct CaptionsResponse: Codable {
        public let captions: CaptionsData
    }

    public struct CaptionsData: Codable {
        public let playerCaptionsTracklistRenderer: CaptionTrackList
    }

    public struct CaptionTrackList: Codable {
        public let captionTracks: [CaptionTrack]
    }

    public struct Moment {
        public let start: Double
        public let duration: Double
        public let text: String
    }

    public enum TranscriptError: Error {
        case invalidURL
        case invalidVideoID
        case networkError(Error)
        case noTranscriptData
        case invalidHTMLFormat
        case jsonParsingError(Error)
        case noCaptionData
        case invalidXMLFormat
    }

    public init() {}

    public func getTranscript(videoID: String) async throws -> [Moment] {
        guard !videoID.isEmpty else {
            throw TranscriptError.invalidVideoID
        }

        guard let url = URL(string: "https://www.youtube.com/watch?v=\(videoID)") else {
            throw TranscriptError.invalidURL
        }

        return try await getTranscript(url: url)
    }

    public func getTranscript(url: URL) async throws -> [Moment] {
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

    private func getTranscriptText(from tracks: [CaptionTrack]) async throws -> [Moment] {
        for track in tracks {
            do {
                return try await getTranscriptText(from: track)
            } catch {
                continue
            }
        }
        throw TranscriptError.noTranscriptData
    }

    private func getTranscriptText(from track: CaptionTrack) async throws -> [Moment] {
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

    private func parseTranscriptXML(_ xml: String) throws -> [Moment] {
        var moments: [Moment] = []
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

            let textContent = xml[startTagRange.upperBound..<endTagRange.lowerBound]
                .replacingOccurrences(of: "&amp;#39;", with: "'")
                .replacingOccurrences(of: "&amp;quot;", with: "\"")
            
            moments.append(Moment(start: start, duration: duration, text: String(textContent)))
            searchRange = endTagRange.upperBound..<xml.endIndex
        }

        return moments
    }

    private func extractCaptionTracks(from htmlString: String) throws -> [CaptionTrack] {
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
