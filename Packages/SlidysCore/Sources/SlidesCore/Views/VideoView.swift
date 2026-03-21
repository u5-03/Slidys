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
    case visionProPianoDemo

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
        case .visionProPianoDemo:
            return "vision_pro_piano_demo"
        }
    }

    var fileExtension: String {
        return "mp4"
    }
}

// Frameworks, Libraries, and Embedded ContentにAVKitを追加しないと、Previewでクラッシュする
public struct VideoView: View {
    @State private var player: AVPlayer?
    @State private var playerItem: AVPlayerItem?
    @State private var cancellableSet = Set<AnyCancellable>()
    @State private var timeObserverToken: Any?
    @State private var isLoading = true
    @State private var loadError: String?
    private let videoType: VideoType

    public init(videoType: VideoType) {
        self.videoType = videoType
    }

    public var body: some View {
        Group {
            if let player {
                VideoPlayer(player: player)
            } else if let loadError {
                VStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                    Text(loadError)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }
                .foregroundStyle(.secondary)
            } else {
                ProgressView()
                    .controlSize(.large)
            }
        }
        .task {
            do {
                let url = try await resolveVideoURL(for: videoType)
                let item = AVPlayerItem(url: url)
                let newPlayer = AVPlayer(playerItem: item)
                playerItem = item
                player = newPlayer

                await item.seek(to: .zero)
                try await Task.sleep(for: .seconds(1))
                newPlayer.play()
                NotificationCenter.default
                    .publisher(for: .AVPlayerItemDidPlayToEndTime, object: item)
                    .sink { _ in
                        newPlayer.seek(to: .zero)
                        newPlayer.play()
                    }
                    .store(in: &cancellableSet)
                isLoading = false
            } catch {
                loadError = error.localizedDescription
                isLoading = false
            }
        }
        .onDisappear {
            player?.pause()
            if let token = timeObserverToken {
                player?.removeTimeObserver(token)
                timeObserverToken = nil
            }
        }
    }

    private func resolveVideoURL(for videoType: VideoType) async throws -> URL {
        // Bundle.main から探す（Copy Bundle Resources / Development Assets）
        if let url = Bundle.main.url(forResource: videoType.fileName, withExtension: videoType.fileExtension) {
            return url
        }
        // TODO: BA App Extension 整備後に AssetPackManager 経由の取得を有効化
        throw VideoLoadError.notFound(videoType.fileName)
    }

    private enum VideoLoadError: LocalizedError {
        case notFound(String)

        var errorDescription: String? {
            switch self {
            case .notFound(let name):
                return "Video '\(name)' not found in bundle."
            }
        }
    }
}

#Preview {
    VideoView(videoType: .visionProDemoInput)
}
