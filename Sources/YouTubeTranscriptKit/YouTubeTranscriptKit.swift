import Foundation

public struct YouTubeTranscriptKit {
    public struct CaptionTrack: Codable {
        public let baseUrl: String
        public let name: CaptionName
        public let vssId: String
        public let languageCode: String
        public let kind: String?
        public let isTranslatable: Bool
        public let trackName: String
    }

    public struct CaptionName: Codable {
        public let simpleText: String
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

    public enum TranscriptError: Error {
        case invalidURL
        case invalidVideoID
        case networkError(Error)
        case noTranscriptData
        case invalidHTMLFormat
        case jsonParsingError(Error)
        case noCaptionData
    }

    public init() {}

    public func getTranscript(videoID: String) async throws -> [CaptionTrack] {
        guard !videoID.isEmpty else {
            throw TranscriptError.invalidVideoID
        }

        guard let url = URL(string: "https://www.youtube.com/watch?v=\(videoID)") else {
            throw TranscriptError.invalidURL
        }

        return try await getTranscript(url: url)
    }

    public func getTranscript(url: URL) async throws -> [CaptionTrack] {
        let data: Data
        do {
            (data, _) = try await URLSession.shared.data(from: url)
        } catch {
            throw TranscriptError.networkError(error)
        }

        guard let htmlString = String(data: data, encoding: .utf8) else {
            throw TranscriptError.invalidHTMLFormat
        }

        guard let range = htmlString.range(of: "var ytInitialPlayerResponse = "),
              let endRange = htmlString[range.upperBound...].range(of: ";</script>") else {
            throw TranscriptError.noTranscriptData
        }

        let jsonString = String(htmlString[range.upperBound..<endRange.lowerBound])

        guard let jsonData = jsonString.data(using: .utf8) else {
            throw TranscriptError.invalidHTMLFormat
        }

        do {
            let response = try JSONDecoder().decode(CaptionsResponse.self, from: jsonData)
            return response.captions.playerCaptionsTracklistRenderer.captionTracks
        } catch {
            throw TranscriptError.jsonParsingError(error)
        }
    }
}
