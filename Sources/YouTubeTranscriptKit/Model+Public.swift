//
//  VideoInfo.swift
//  YouTubeTranscript
//
//  Created by Adam Wulf on 1/11/25.
//

import Foundation

public struct Activity: Codable {
    public enum Action: String, Codable {
        case watched = "watched"
        case watchedStory = "watched story"
        case viewed = "viewed"
        case liked = "liked"
        case disliked = "disliked"
        case subscribedTo = "subscribed to"
        case answered = "answered"
        case votedOn = "voted on"
        case saved = "saved"
        case searchedFor = "searched for"
    }

    public enum Link: Codable {
        case video(id: String, title: String?)
        case post(id: String, text: String)
        case channel(id: String, name: String)
        case playlist(id: String, title: String)
        case search(query: String)

        public var url: URL {
            switch self {
            case .video(let id, _):
                return URL(string: "https://www.youtube.com/watch?v=\(id)")!
            case .post(let id, _):
                return URL(string: "https://www.youtube.com/post/\(id)")!
            case .channel(let id, _):
                return URL(string: "https://www.youtube.com/channel/\(id)")!
            case .playlist(let id, _):
                return URL(string: "https://www.youtube.com/playlist?list=\(id)")!
            case .search(let query):
                return URL(string: "https://www.youtube.com/results?search_query=\(query)")!
            }
        }
    }

    public let action: Action
    public let link: Link
    public let timestamp: Date
}

public struct VideoInfo: Codable {
    public let videoId: String?
    public let title: String?
    public let channelId: String?
    public let channelName: String?
    public let description: String?
    public let publishedAt: Date?
    public let uploadedAt: Date?
    public let viewCount: Int?
    public let duration: Int?
    public let category: String?
    public let isLive: Bool?
    public let thumbnails: [VideoThumbnail]?
    public let channelURL: URL?
    public let videoURL: URL?
    public let transcriptContainers: [TranscriptContainer]?

    public func withoutTranscript() -> VideoInfo {
        return VideoInfo(
            videoId: videoId,
            title: title,
            channelId: channelId,
            channelName: channelName,
            description: description,
            publishedAt: publishedAt,
            uploadedAt: uploadedAt,
            viewCount: viewCount,
            duration: duration,
            category: category,
            isLive: isLive,
            thumbnails: thumbnails,
            channelURL: channelURL,
            videoURL: videoURL,
            transcriptContainers: nil
        )
    }
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

public struct TranscriptContainer: Codable {
    public let languageCode: String
    public let vssId: String
    public let transcriptMoments: [TranscriptMoment]
}
