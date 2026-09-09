//
//  EndSlide.swift
//  iOSDC2026Slide
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct EndSlide: View {
    /// スピーカーノート(発表者用の原稿。ノートWindowに表示される)
    var script: String {
        "発表の詳細とコードは、すべてこちらのブログにまとめています。たい焼きのiOS応用も別記事があります。QRコードから飛べます。実装はGitHubで公開しているので、ぜひ見てみてください。\nご清聴ありがとうございました！"
    }

    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        HeaderSlide("ご清聴ありがとうございました") {
            VStack(alignment: .leading, spacing: 48) {
                HStack(alignment: .top, spacing: 80) {
                    qrColumn(
                        title: "本日の発表のブログ(詳細・コード)",
                        url: "https://ulog.sugiy.com/iosdc2026-visionos-anime-card-battle/"
                    ) {
                        Image(.qrMainArticle)
                            .resizable()
                            .interpolation(.none) // QRのドットをにじませない
                            .scaledToFit()
                    }
                    qrColumn(
                        title: "このスライドアプリ(TestFlight)",
                        url: SlideConstants.testFlightPublicLink.absoluteString
                    ) {
                        // SlidesCoreにバンドル済みのTestFlight配布用QR
                        QrCodeType.native.view
                    }
                }
                .frame(maxWidth: .infinity)
                Text("実装リポジトリ: https://github.com/u5-03/Slidys")
                    .font(.regularFont)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }

    private func qrColumn(
        title: String,
        url: String,
        @ViewBuilder qrImage: () -> some View
    ) -> some View {
        VStack(spacing: 24) {
            Text(title)
                .font(.system(size: 40, weight: .bold))
            qrImage()
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
