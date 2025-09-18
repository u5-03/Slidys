//
//  VideoView.swift
//  
//
//  Created by Yugo Sugiyama on 2024/11/24.
//

import SwiftUI
import AVKit
import Combine

public enum VideoType {
    case visionProDemoInput
    case visionProDemoOutput
    case bookAnimation
    case handGestureEntitySample
    case handGestureSignLanguage

    var fileName: String {
        switch self {
        case .visionProDemoInput:
            return "opening_input"
        case .visionProDemoOutput:
            return "opening_output"
        case .bookAnimation:
            return "book_animation"
        case .handGestureEntitySample:
            return "hand_gesture_entity_sample"
        case .handGestureSignLanguage:
            return "hand_gesture_sign_language"
        }
    }

    var fileExtension: String {
        return "mp4"
    }
}

// Frameworks, Libraries, and Embedded ContentにAVKitを追加しないと、Previewでクラッシュする
public struct VideoView: View {
    @State private var player: AVPlayer
    @State private var playerItem: AVPlayerItem
    @State private var currentTime: Double = 0.0
    @State private var duration: Double = 0.0
    @State private var timeObserverToken: Any?
    @State private var cancellableSet = Set<AnyCancellable>()
    private let videoType: VideoType

    public init(videoType: VideoType) {
        self.videoType = videoType

        if let fileURL = Bundle.main.url(forResource: videoType.fileName, withExtension: videoType.fileExtension) {
            let playerItem = AVPlayerItem(url: fileURL)
            self.playerItem = playerItem
            player = AVPlayer(playerItem: playerItem)
        } else {
            fatalError("Video file '\(videoType.fileName).\(videoType.fileExtension)' not found in bundle.")
        }
    }

    public var body: some View {
        VideoPlayer(player: player)
            .task {
                do {
                    await playerItem.seek(to: .zero)
                    try await Task.sleep(for: .seconds(1))
                    player.play()
                    NotificationCenter.default
                        .publisher(for: .AVPlayerItemDidPlayToEndTime, object: playerItem)
                        .sink { _ in
                            player.seek(to: .zero)
                            player.play()
                        }
                        .store(in: &cancellableSet)
                } catch {
                }
            }
            .onDisappear {
                player.pause()
                if let token = timeObserverToken {
                    player.removeTimeObserver(token)
                    timeObserverToken = nil
                }
            }
    }
}

#Preview {
    VideoView(videoType: .visionProDemoInput)
}
