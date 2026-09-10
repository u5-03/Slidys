//
//  MediaPlaceholderSlide.swift
//  iOSDC2026Slide
//
//  動画・画像を差し込む位置を示すプレースホルダー。
//  素材が揃ったら VideoSlide / ContentSlide(Image) に差し替える。
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct MediaPlaceholderSlide: View {
    let title: String
    let caption: String
    let symbolName: String

    init(title: String, caption: String, symbolName: String = "play.rectangle") {
        self.title = title
        self.caption = caption
        self.symbolName = symbolName
    }

    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        VStack(spacing: 40) {
            // タイトルなし(空文字)なら動画/画像だけを全面に見せる
            if !title.isEmpty {
                Text(title)
                    .font(.largeFont)
                    .foregroundStyle(.themeColor)
            }
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .strokeBorder(style: StrokeStyle(lineWidth: 6, dash: [24, 18]))
                .foregroundStyle(.gray)
                .overlay {
                    VStack(spacing: 24) {
                        Image(systemName: symbolName)
                            .font(.system(size: 160, weight: .light))
                        Text(caption)
                            .font(.regularFont)
                            .multilineTextAlignment(.center)
                    }
                    .foregroundStyle(.gray)
                }
                .frame(maxWidth: 1400, maxHeight: 700)
        }
        .padding(80)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.slideBackgroundColor)
        .foregroundColor(.defaultForegroundColor)
    }
}

#Preview {
    SlidePreview {
        MediaPlaceholderSlide(title: "デモ動画", caption: "TODO: 完成デモ")
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}
