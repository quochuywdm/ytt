import XCTest
@testable import YouTubeTranscriptKit

final class YouTubeTranscriptKitTests: XCTestCase {
    func testExample() throws {
        let transcript = YouTubeTranscriptKit()
        XCTAssertEqual(transcript.getTranscript(), "Transcript placeholder")
    }
} 