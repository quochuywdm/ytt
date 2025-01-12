import ArgumentParser
import Foundation
import YouTubeTranscriptKit

@main
struct YTT: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "A utility for downloading YouTube video transcripts",
        version: "1.0.0",
        subcommands: [Transcribe.self, Info.self]
    )
}

struct Transcribe: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "transcribe",
        abstract: "Download the transcript for a YouTube video"
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

struct Info: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "info",
        abstract: "Get information about a YouTube video"
    )

    @Argument(help: "YouTube video URL or ID")
    var input: String

    mutating func run() async throws {
        // Stub for info command
        print("Info command not yet implemented for: \(input)")
    }
}
