//
//  TitleVideoSlide.swift
//  Slidys
//
//  Created by Yugo Sugiyama on 2024/11/06.
//


import SwiftUI
import SlideKit
import SlidysCore

// Frameworks, Libraries, and Embedded ContentにAVKitを追加しないと、Previewでクラッシュする
@Slide
struct TitleVideoSlide: View {
    let title: String
    let videoType: VideoType

    init(title: String, videoType: VideoType) {
        self.title = title
        self.videoType = videoType
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.mediumFont)
                .lineLimit(2)
                .padding()
            VideoView(videoType: videoType)
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
            videoType: .visionProDemoInput
        )
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
