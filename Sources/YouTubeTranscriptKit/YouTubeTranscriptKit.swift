import Foundation

public struct YouTubeTranscriptKit {
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

    public func getTranscript(videoID: String) async throws -> String {
        guard !videoID.isEmpty else {
            throw TranscriptError.invalidVideoID
        }

        guard let url = URL(string: "https://www.youtube.com/watch?v=\(videoID)") else {
            throw TranscriptError.invalidURL
        }

        return try await getTranscript(url: url)
    }

    public func getTranscript(url: URL) async throws -> [String: Any] {
        let data: Data
        do {
            (data, _) = try await URLSession.shared.data(from: url)
        } catch {
            throw TranscriptError.networkError(error)
        }

        guard let htmlString = String(data: data, encoding: .utf8) else {
            throw TranscriptError.invalidHTMLFormat
        }

        // Look for the ytInitialPlayerResponse script
        guard let range = htmlString.range(of: "var ytInitialPlayerResponse = "),
              let endRange = htmlString[range.upperBound...].range(of: ";</script>") else {
            throw TranscriptError.noTranscriptData
        }

        let jsonString = String(htmlString[range.upperBound..<endRange.lowerBound])

        guard let jsonData = jsonString.data(using: .utf8) else {
            throw TranscriptError.invalidHTMLFormat
        }

        let json: [String: Any]
        do {
            json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] ?? [:]
        } catch {
            throw TranscriptError.jsonParsingError(error)
        }

        guard let captions = json["captions"] as? [String: Any],
              let trackList = captions["playerCaptionsTracklistRenderer"] as? [String: Any],
              let captionTracks = trackList["captionTracks"] as? [[String: Any]] else {
            throw TranscriptError.noCaptionData
        }

        return captionTracks
    }
}
