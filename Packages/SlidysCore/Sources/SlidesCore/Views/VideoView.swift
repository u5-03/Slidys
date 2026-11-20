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
    case appleStoreFocusDemo

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
        case .appleStoreFocusDemo:
            return "apple_store_focus_demo"
        }
    }

    var fileExtension: String {
        return self == .appleStoreFocusDemo ? "mov" : "mp4"
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
    @State private var playerLooper: AVPlayerLooper?
    private let localVideoURL: URL?
    private let seamlessLoop: Bool
    private let videoType: VideoType

    public init(videoType: VideoType, seamlessLoop: Bool = false, localVideoURL: URL? = nil) {
        self.localVideoURL = localVideoURL
        self.seamlessLoop = seamlessLoop
        self.videoType = videoType
    }

    public var body: some View {
        Group {
            if isSlideThumbnail {
                // スライド一覧のサムネイルでは動画を起動しない
                // (AVPlayerやAssetPackManagerがプレビューエージェント内で全数起動してクラッシュするため)
                ZStack {
                    if seamlessLoop { Color.slideBackgroundColor } else { Color.black }
                    VStack(spacing: 16) {
                        Image(systemName: "play.rectangle.fill")
                            .font(.system(size: 160, weight: .light))
                        Text(videoType.fileName)
                            .font(.system(size: 40, design: .monospaced))
                    }
                    .foregroundStyle(.gray)
                }
            } else if let player {
                if seamlessLoop {
                    TransparentVideoSurface(player: player)
                } else {
#if os(macOS)
                // SwiftUIのVideoPlayerはmacOSで「デバッガ非接続の起動」(TestFlight配布版など)だと
                // 内部クラスVideoPlayerViewのスーパークラスAVPlayerViewのメタデータ解決に失敗して
                // クラッシュする既知バグがあるため、AVPlayerViewを直接ラップして使う。
                // (failed to demangle superclass of VideoPlayerView from 'So12AVPlayerViewC')
                MacVideoPlayerView(player: player)
#else
                VideoPlayer(player: player)
#endif
                }
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
                let url: URL
                if let localVideoURL {
                    url = localVideoURL
                } else {
                    url = try await resolveVideoURL(for: videoType)
                }
                try Task.checkCancellation()
                let item = AVPlayerItem(url: url)
                let newPlayer: AVPlayer
                if seamlessLoop {
                    let queuePlayer = AVQueuePlayer()
                    playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: item)
                    newPlayer = queuePlayer
                } else {
                    newPlayer = AVPlayer(playerItem: item)
                }
#if !os(visionOS)
                if seamlessLoop { newPlayer.allowsExternalPlayback = false }
#endif
                playerItem = item
                player = newPlayer

                if !seamlessLoop {
                    await item.seek(to: .zero)
                    try await Task.sleep(for: .seconds(1))
                }
                try Task.checkCancellation()
                newPlayer.play()
                if !seamlessLoop {
                    NotificationCenter.default
                        .publisher(for: .AVPlayerItemDidPlayToEndTime, object: item)
                        .sink { _ in
                            newPlayer.seek(to: .zero)
                            newPlayer.play()
                        }
                        .store(in: &cancellableSet)
                }
                isLoading = false
            } catch is CancellationError {
                player?.pause()
            } catch {
                loadError = error.localizedDescription
                isLoading = false
            }
        }
        .onDisappear {
            player?.pause()
            playerLooper?.disableLooping()
            playerLooper = nil
            (player as? AVQueuePlayer)?.removeAllItems()
            if let token = timeObserverToken {
                player?.removeTimeObserver(token)
                timeObserverToken = nil
            }
            player = nil
            playerItem = nil
            cancellableSet.removeAll()
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
        guard Bundle.main.bundleIdentifier != nil,
              ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1" else {
            throw CocoaError(.fileNoSuchFile)
        }
        let pack = try await AssetPackManager.shared.assetPack(withID: "slidys-videos")
        try await AssetPackManager.shared.ensureLocalAvailability(of: pack)
        let filePath = FilePath("payload/\(videoType.fileName).\(videoType.fileExtension)")
        return try AssetPackManager.shared.url(for: filePath)
    }
}

#if os(macOS)
/// AVPlayerViewを直接使うmacOS用プレイヤー(VideoViewのコメント参照)。
private struct MacVideoPlayerView: NSViewRepresentable {
    let player: AVPlayer

    func makeNSView(context: Context) -> AVPlayerView {
        let view = AVPlayerView()
        view.player = player
        view.controlsStyle = .inline
        view.showsFullScreenToggleButton = false
        return view
    }

    func updateNSView(_ view: AVPlayerView, context: Context) {
        if view.player !== player {
            view.player = player
        }
    }
}
#endif


/// The player layer draws only the aspect-fit video, leaving the slide background visible.
#if os(macOS)
private struct TransparentVideoSurface: NSViewRepresentable {
    let player: AVPlayer
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        view.wantsLayer = true
        let layer = AVPlayerLayer(player: player)
        layer.videoGravity = .resizeAspect
        layer.backgroundColor = NSColor.clear.cgColor
        view.layer = layer
        return view
    }
    func updateNSView(_ view: NSView, context: Context) {
        (view.layer as? AVPlayerLayer)?.player = player
    }
}
#else
private struct TransparentVideoSurface: UIViewRepresentable {
    let player: AVPlayer
    func makeUIView(context: Context) -> PlayerSurface {
        let view = PlayerSurface()
        view.backgroundColor = .clear
        view.isOpaque = false
        let layer = view.layer as! AVPlayerLayer
        layer.player = player
        layer.videoGravity = .resizeAspect
        layer.backgroundColor = UIColor.clear.cgColor
        return view
    }
    func updateUIView(_ view: PlayerSurface, context: Context) {
        (view.layer as? AVPlayerLayer)?.player = player
    }
    final class PlayerSurface: UIView {
        override class var layerClass: AnyClass { AVPlayerLayer.self }
    }
}
#endif

#Preview {
    VideoView(videoType: .visionProDemoInput)
}
