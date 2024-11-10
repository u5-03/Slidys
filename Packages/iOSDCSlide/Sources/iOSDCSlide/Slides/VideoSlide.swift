//
//  VideoSlide.swift
//  iOSDC2024Slide
//
//  Created by Yugo Sugiyama on 2024/07/27.
//

import SwiftUI
import SlideKit
import AVKit
import Combine
import SlidysCore

// Frameworks, Libraries, and Embedded ContentにAVKitを追加しないと、Previewでクラッシュする
@Slide
struct VideoSlide: View {
    @State private var player: AVPlayer
    @State private var playerItem: AVPlayerItem
    @State private var currentTime: Double = 0.0
    @State private var duration: Double = 0.0
    @State private var timeObserverToken: Any?
    @State private var cancellableSet = Set<AnyCancellable>()

    init(videoName: String, fileExtension: String) {
        if let filePath = Bundle.module.path(forResource: videoName, ofType: fileExtension) {
            let fileURL = URL(fileURLWithPath: filePath)
            let playerItem = AVPlayerItem(url: fileURL)
            self.playerItem = playerItem
            player = AVPlayer(playerItem: playerItem)

        } else {
            fatalError("Video file not found in bundle.")
        }
    }

    var body: some View {
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
    VideoSlide(videoName: "piano_demo", fileExtension: "mov")
        .frame(width: 800, height: 450)
}
