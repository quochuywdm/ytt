//
//  MetaTag.swift
//  YouTubeTranscript
//
//  Created by Adam Wulf on 1/11/25.
//

import Foundation

// MARK: - Video Details

struct VideoResponse: Codable {
    let videoDetails: VideoDetails
    let microformat: Microformat
}

struct Microformat: Codable {
    let playerMicroformatRenderer: PlayerMicroformat
}

struct PlayerMicroformat: Codable {
    let title: TextRuns
    let description: TextRuns
    let lengthSeconds: String
    let externalChannelId: String
    let category: String
    let publishDate: String
    let uploadDate: String
    let ownerChannelName: String
    let ownerProfileUrl: String
    let liveBroadcastDetails: LiveBroadcastDetails?
}

struct TextRuns: Codable {
    let runs: [TextRun]
}

struct TextRun: Codable {
    let text: String
}

struct LiveBroadcastDetails: Codable {
    let isLiveNow: Bool
    let startTimestamp: String
    let endTimestamp: String
}

struct VideoDetails: Codable {
    let videoId: String
    let title: String
    let lengthSeconds: String
    let channelId: String
    let shortDescription: String
    let viewCount: String
    let author: String
    let thumbnail: ThumbnailContainer
}

struct ThumbnailContainer: Codable {
    let thumbnails: [Thumbnail]
}

struct Thumbnail: Codable {
    let url: String
    let width: Int
    let height: Int
}

// MARK: - Captions

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
