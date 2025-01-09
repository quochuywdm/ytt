import ArgumentParser
import Foundation

@main
struct YouTubeTranscript: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "A utility for downloading YouTube video transcripts",
        version: "1.0.0"
    )

    func run() throws {
        print("YouTube Transcript Downloader")
    }
}
