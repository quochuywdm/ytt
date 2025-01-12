# ytt

A Swift package providing both a command line tool and library for interacting with YouTube content:
- Download transcripts from any YouTube video
- Get video metadata and information
- Parse YouTube activity history from Google Takeout

## Command Line Tool (ytt)

### Installation

```bash
swift build -c release
cp .build/release/ytt /usr/local/bin/
```

### Commands

#### Transcribe
Download a transcript from a YouTube video:
```bash
ytt transcribe https://www.youtube.com/watch?v=VIDEO_ID
# or just the ID
ytt transcribe VIDEO_ID
```

#### Info
Get detailed information about a video:
```bash
ytt info https://www.youtube.com/watch?v=VIDEO_ID
# Include transcript in the output
ytt info --include-transcript VIDEO_ID
```

#### Activity
Parse your YouTube activity history from Google Takeout:
```bash
ytt activity "Takeout/My Activity/YouTube/MyActivity.html"
# Supports path expansion
ytt activity "~/Downloads/Takeout/My Activity/YouTube/MyActivity.html"
ytt activity "../Takeout/My Activity/YouTube/MyActivity.html"
```
Supports various activity types:
- Watched videos
- Viewed posts/stories
- Liked content
- Subscribed to channels
- Answered polls
- Voted on content
- Saved videos/playlists
- Search history

## YouTubeTranscriptKit

A Swift library that can be integrated into any project to access YouTube content.

### Installation

Add to your Package.swift:
```swift
dependencies: [
    .package(url: "PATH_TO_REPO", branch: "main")
]
```

### Features

#### Video Transcripts
```swift
// Get transcript by URL
let transcript = try await YouTubeTranscriptKit.getTranscript(url: videoURL)

// Get transcript by ID
let transcript = try await YouTubeTranscriptKit.getTranscript(videoID: "VIDEO_ID")
```

#### Video Information
```swift
// Get video info with optional transcript
let info = try await YouTubeTranscriptKit.getVideoInfo(videoID: "VIDEO_ID", includeTranscript: true)
```

#### Activity History
Parse your YouTube activity history from Google Takeout:
```swift
let activities = try await YouTubeTranscriptKit.getActivity(fileURL: takeoutFile)
```

### Models

- `VideoInfo`: Complete video metadata including title, channel, views, etc.
- `TranscriptMoment`: Individual transcript entries with timing
- `Activity`: YouTube activity entries including:
  - Various action types (watched, liked, subscribed, etc.)
  - Links to videos, channels, playlists, etc.
  - Timestamps and additional metadata
