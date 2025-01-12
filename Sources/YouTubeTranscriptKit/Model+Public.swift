//
//  VideoInfo.swift
//  YouTubeTranscript
//
//  Created by Adam Wulf on 1/11/25.
//

import Foundation

public struct VideoInfo: Codable {
    public let videoId: String?
    public let title: String?
    public let channelId: String?
    public let channelName: String?
    public let description: String?
    public let publishedAt: Date?
    public let uploadedAt: Date?
    public let viewCount: Int?
    public let lengthSeconds: Int?
    public let category: String?
    public let isLive: Bool?
    public let thumbnails: [VideoThumbnail]?
    public let channelURL: URL?
    public let videoURL: URL?
    public let transcript: [TranscriptMoment]?
}

public struct VideoThumbnail: Codable {
    public let url: String
    public let width: Int
    public let height: Int
}

public struct TranscriptMoment: Codable {
    public let start: Double
    public let duration: Double
    public let text: String
}
