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
                Text("本日の発表内容のブログ")
                    .font(.mediumFont)
                // TODO: 記事公開後にQRコード画像アセット(iosdc2026ShareQr)へ差し替え
                Text("https://ulog.sugiy.com/iosdc2026-visionos-anime-card-battle/")
                    .font(.mediumFont)
                Text("実装リポジトリ")
                    .font(.mediumFont)
                Text("https://github.com/u5-03/Slidys")
                    .font(.mediumFont)
            }
        }
    }
}

#Preview {
    SlidePreview {
        EndSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
