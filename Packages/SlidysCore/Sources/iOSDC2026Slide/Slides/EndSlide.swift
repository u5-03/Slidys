//
//  EndSlide.swift
//  iOSDC2026Slide
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct EndSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        HeaderSlide("ご清聴ありがとうございました") {
            VStack(alignment: .leading, spacing: 40) {
                Text("本日の発表内容のブログ(詳細・コードはこちら)")
                    .font(.mediumFont)
                // TODO: 記事公開後にQRコード画像アセット(iosdc2026ShareQr)へ差し替え
                Text("https://ulog.sugiy.com/iosdc2026-visionos-anime-card-battle/")
                    .font(.regularFont)
                Text("iOS/iPadOSへの応用(たい焼きフォーカス)の記事")
                    .font(.mediumFont)
                Text("https://ulog.sugiy.com/taiyaki-focus-3d-showcase-ios/")
                    .font(.regularFont)
                Text("実装リポジトリ: https://github.com/u5-03/Slidys")
                    .font(.regularFont)
            }
        }
    }
}

#Preview {
    SlidePreview {
        EndSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}
