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
        let info: VideoInfo

        if input.contains("youtube.com") || input.contains("youtu.be"),
           let url = URL(string: input) {
            info = try await YouTubeTranscriptKit.getVideoInfo(url: url)
        } else {
            info = try await YouTubeTranscriptKit.getVideoInfo(videoID: input)
        }

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601

        let data = try encoder.encode(info)
        if let json = String(data: data, encoding: .utf8) {
            print(json)
        }
    }
}
