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
        let transcript: [TranscriptMoment]

        if input.contains("youtube.com") || input.contains("youtu.be"),
           let url = URL(string: input) {
            transcript = try await YouTubeTranscriptKit.getTranscript(url: url)
        } else {
            transcript = try await YouTubeTranscriptKit.getTranscript(videoID: input)
        }

        print(transcript)
    }
}
