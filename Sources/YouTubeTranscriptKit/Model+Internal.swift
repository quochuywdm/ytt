//
//  MetaTag.swift
//  YouTubeTranscript
//
//  Created by Adam Wulf on 1/11/25.
//

import Foundation

struct CaptionTrack: Codable {
    public let baseUrl: String
    public let vssId: String
    public let languageCode: String
}

struct CaptionsResponse: Codable {
    public let captions: CaptionsData
}

struct CaptionsData: Codable {
    public let playerCaptionsTracklistRenderer: CaptionTrackList
}

struct CaptionTrackList: Codable {
    public let captionTracks: [CaptionTrack]
}
