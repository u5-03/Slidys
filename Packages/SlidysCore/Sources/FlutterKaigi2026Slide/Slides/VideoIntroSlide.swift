//
//  VideoIntroSlide.swift
//  FlutterKaigi2026Slide
//
//  まとめのあとに出す、YouTube 動画の紹介。サムネイルと動画のタイトルを見せる。
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct VideoIntroSlide: View {
    var script: String {
        "最後に 1 つ紹介です。YouTube で、こちらの動画が公開されています。よければご覧ください。"
    }

    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    /// 動画のタイトル(固有名なので訳さない)
    private let videoTitle = "【DeNA】文系出身iOSエンジニア1日密着｜クリエイターを支援するアニメ制作DXの裏側"

    var body: some View {
        HeaderSlide(loc: "YouTube 動画の紹介") {
            VStack(spacing: 28) {
                Image("youtube_dena_ios_engineer", bundle: .module)
                    .resizable()
                    .aspectRatio(16.0 / 9.0, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .shadow(color: .black.opacity(0.4), radius: 24, y: 12)
                    .frame(maxHeight: 580)
                Text(verbatim: videoTitle)
                    .font(.system(size: 44, weight: .bold))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.6)
                Text("YouTube で公開中".loc)
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(.gray)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
}

#Preview {
    SlidePreview {
        VideoIntroSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}
