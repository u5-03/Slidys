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
            VStack(alignment: .leading, spacing: 48) {
                HStack(alignment: .top, spacing: 80) {
                    qrColumn(
                        title: "本日の発表のブログ(詳細・コード)",
                        image: .qrMainArticle,
                        url: "https://ulog.sugiy.com/iosdc2026-visionos-anime-card-battle/"
                    )
                    qrColumn(
                        title: "iOS/iPadOS応用の記事",
                        image: .qrTaiyakiArticle,
                        url: "https://ulog.sugiy.com/taiyaki-focus-3d-showcase-ios/"
                    )
                }
                .frame(maxWidth: .infinity)
                Text("実装リポジトリ: https://github.com/u5-03/Slidys")
                    .font(.regularFont)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }

    private func qrColumn(title: String, image: ImageResource, url: String) -> some View {
        VStack(spacing: 24) {
            Text(title)
                .font(.system(size: 40, weight: .bold))
            Image(image)
                .resizable()
                .interpolation(.none) // QRのドットをにじませない
                .scaledToFit()
                .frame(width: 440, height: 440)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            Text(url)
                .font(.system(size: 26, weight: .regular))
                .foregroundStyle(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    SlidePreview {
        EndSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}
