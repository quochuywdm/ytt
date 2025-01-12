//
//  MetaTag.swift
//  YouTubeTranscript
//
//  Created by Adam Wulf on 1/11/25.
//

import Foundation

struct MetaTag {
    let property: String?
    let name: String?
    let content: String

    init?(tag: String) {
        // Match content="value" and (property|name)="value"
        guard let content = tag.firstMatch(of: #/content="([^"]*)"/#)?.1,
                let attr = tag.firstMatch(of: #/(property|name)="([^"]*)"/#) else {
            return nil
        }

        self.content = String(content)
        if attr.1 == "property" {
            self.property = String(attr.2)
            self.name = nil
        } else {
            self.name = String(attr.2)
            self.property = nil
        }
    }
}

struct LinkTag {
    let rel: String
    let href: String

    init?(tag: String) {
        // Match rel="value" and href="value"
        guard let rel = tag.firstMatch(of: #/rel="([^"]*)"/#)?.1,
                let href = tag.firstMatch(of: #/href="([^"]*)"/#)?.1 else {
            return nil
        }

        self.rel = String(rel)
        self.href = String(href)
    }
}

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
