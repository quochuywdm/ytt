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

        var allTracks: [CaptionTrack] = []
        var searchRange = htmlString.startIndex..<htmlString.endIndex
        var matchCount = 0
        
        while let range = htmlString.range(of: "var ytInitialPlayerResponse = ", range: searchRange),
              let endRange = htmlString[range.upperBound...].range(of: ";</script>") {
            matchCount += 1
            print("Found match #\(matchCount)")
            
            let jsonString = String(htmlString[range.upperBound..<endRange.lowerBound])
            print("JSON string length: \(jsonString.count)")
            print("JSON preview: \(String(jsonString.prefix(100)))")
            
            if let jsonData = jsonString.data(using: .utf8) {
                do {
                    let response = try JSONDecoder().decode(CaptionsResponse.self, from: jsonData)
                    let newTracks = response.captions.playerCaptionsTracklistRenderer.captionTracks
                    print("Successfully parsed \(newTracks.count) tracks")
                    allTracks.append(contentsOf: newTracks)
                } catch {
                    print("Failed to parse JSON: \(error)")
                    if let jsonObject = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
                       let captionsDict = jsonObject["captions"] as? [String: Any] {
                        print("Raw captions structure: \(captionsDict)")
                    }
                }
            } else {
                print("Failed to convert JSON string to data")
            }
            
            // Update search range to continue after this match
            searchRange = endRange.upperBound..<htmlString.endIndex
            print("Updated search range, \(htmlString.distance(from: searchRange.lowerBound, to: searchRange.upperBound)) chars remaining\n")
        }
        
        print("Total matches found: \(matchCount)")
        print("Total tracks collected: \(allTracks.count)")
        
        guard !allTracks.isEmpty else {
            throw TranscriptError.noCaptionData
        }
        
        return allTracks
    }
}
