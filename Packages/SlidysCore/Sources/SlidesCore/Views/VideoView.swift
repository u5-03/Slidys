//
//  VideoView.swift
//
//
//  Created by Yugo Sugiyama on 2024/11/24.
//

import SwiftUI
import AVKit
import BackgroundAssets
import Combine
import System

public enum VideoType {
    case visionProDemoInput
    case visionProDemoOutput
    case bookAnimation
    case handGestureEntitySample
    case handGestureSignLanguage
    case visionProPianoDemo
    /// iOSDC2026 デモ1の保険動画(ドロー→手札→配置→たい焼き召喚の一連の流れ)
    case duelDemoFull
    /// iOSDC2026 デモ2の保険動画(竜のモンスターの召喚エフェクト)
    case duelDemoDragon

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
        case .duelDemoFull:
            return "duel_demo_full"
        case .duelDemoDragon:
            return "duel_demo_dragon"
        }
    }

    var fileExtension: String {
        return "mp4"
    }
}

// Frameworks, Libraries, and Embedded ContentにAVKitを追加しないと、Previewでクラッシュする
public struct VideoView: View {
    @Environment(\.isSlideThumbnail) private var isSlideThumbnail
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
            if isSlideThumbnail {
                // スライド一覧のサムネイルでは動画を起動しない
                // (AVPlayerやAssetPackManagerがプレビューエージェント内で全数起動してクラッシュするため)
                ZStack {
                    Color.black
                    VStack(spacing: 16) {
                        Image(systemName: "play.rectangle.fill")
                            .font(.system(size: 160, weight: .light))
                        Text(videoType.fileName)
                            .font(.system(size: 40, design: .monospaced))
                    }
                    .foregroundStyle(.gray)
                }
            } else if let player {
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
            guard !isSlideThumbnail else { return }
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
        // 1. Bundle.main から探す（Development Assets / Copy Bundle Resources）
        if let url = Bundle.main.url(forResource: videoType.fileName, withExtension: videoType.fileExtension) {
            return url
        }
        // 2. AssetPackManager から取得（TestFlight / App Store）
        // バンドルIDを持たない実行環境(スナップショット用CLIツールなど)では
        // AssetPackManagerがfatalErrorになるため、その前にエラーで抜ける
        guard Bundle.main.bundleIdentifier != nil else {
            throw CocoaError(.fileNoSuchFile)
        }
        let pack = try await AssetPackManager.shared.assetPack(withID: "slidys-videos")
        try await AssetPackManager.shared.ensureLocalAvailability(of: pack)
        let filePath = FilePath("payload/\(videoType.fileName).\(videoType.fileExtension)")
        return try AssetPackManager.shared.url(for: filePath)
    }
}

#Preview {
    VideoView(videoType: .visionProDemoInput)
}
