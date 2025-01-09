import ArgumentParser
import Foundation
import YouTubeTranscriptKit

@main
struct YouTubeTranscript: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "A utility for downloading YouTube video transcripts",
        version: "1.0.0"
    )

    @Argument(help: "YouTube video URL or ID")
    var input: String

    mutating func run() async throws {
        let api = YouTubeTranscriptKit()
        let tracks: [YouTubeTranscriptKit.CaptionTrack]

        if input.contains("youtube.com") || input.contains("youtu.be"),
           let url = URL(string: input) {
            tracks = try await api.getTranscript(url: url)
        } else {
            tracks = try await api.getTranscript(videoID: input)
        }

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted]
        let jsonData = try encoder.encode(tracks)
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            print(jsonString)
        }
    }
}
