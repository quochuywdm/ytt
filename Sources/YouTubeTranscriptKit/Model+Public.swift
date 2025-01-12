//
//  VideoInfo.swift
//  YouTubeTranscript
//
//  Created by Adam Wulf on 1/11/25.
//

import Foundation

public struct VideoInfo: Codable {
    public let title: String?
    public let channelId: String?
    public let channelName: String?
    public let description: String?
    public let publishedAt: Date?
    public let viewCount: Int?
    public let likeCount: Int?
}

public struct TranscriptMoment: Codable {
    public let start: Double
    public let duration: Double
    public let text: String
}
