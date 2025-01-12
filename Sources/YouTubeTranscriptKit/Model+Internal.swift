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
