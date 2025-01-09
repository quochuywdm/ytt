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
        let transcript: String

        if input.contains("youtube.com") || input.contains("youtu.be"),
           let url = URL(string: input) {
            transcript = try await api.getTranscript(url: url)
        } else {
            transcript = try await api.getTranscript(videoID: input)
        }

        print(transcript)
    }
}
