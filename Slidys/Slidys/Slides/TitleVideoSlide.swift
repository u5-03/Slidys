//
//  TitleVideoSlide.swift
//  Slidys
//
//  Created by Yugo Sugiyama on 2024/11/06.
//


import SwiftUI
import SlideKit
import AVKit
import Combine
import SlidysCore

// Frameworks, Libraries, and Embedded ContentにAVKitを追加しないと、Previewでクラッシュする
@Slide
struct TitleVideoSlide: View {
    @State private var player: AVPlayer
    @State private var playerItem: AVPlayerItem
    @State private var currentTime: Double = 0.0
    @State private var duration: Double = 0.0
    @State private var timeObserverToken: Any?
    @State private var cancellableSet = Set<AnyCancellable>()
    let title: String

    init(title: String, videoName: String, fileExtension: String) {
        self.title = title
        if let filePath = Bundle.main.path(forResource: videoName, ofType: fileExtension) {
            let fileURL = URL(fileURLWithPath: filePath)
            let playerItem = AVPlayerItem(url: fileURL)
            self.playerItem = playerItem
            player = AVPlayer(playerItem: playerItem)
        } else {
            fatalError("Video file not found in bundle.")
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.mediumFont)
                .lineLimit(2)
                .padding()
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundStyle(.defaultForegroundColor)
        .background(.slideBackgroundColor)
    }
}

#Preview {
    SlidePreview {
        TitleVideoSlide(
            title: "Vision Proで動くピアノのUIをSwiftUIで\n実装して、iOSDC2024で発表しました！",
            videoName: "opening_input",
            fileExtension: "mp4"
        )
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
