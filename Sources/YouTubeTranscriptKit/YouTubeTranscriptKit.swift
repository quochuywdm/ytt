import Foundation

public struct YouTubeTranscriptKit {
    public enum TranscriptError: Error {
        case invalidURL
        case invalidVideoID
        case networkError(Error)
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
    
    public func getTranscript(url: URL) async throws -> String {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return String(data: data, encoding: .utf8) ?? ""
        } catch {
            throw TranscriptError.networkError(error)
        }
    }
} 