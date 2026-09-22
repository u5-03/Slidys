//
//  Readme2026Slide.swift
//  FlutterKaigi2026Slide
//
//  自己紹介スライド。項目が多いので、デッキ既定より小さい .large 相当のスタイルで収める。
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct Readme2026Slide: View {
    /// スピーカーノート(発表者用の原稿。ノートWindowに表示される)
    var script: String {
        "簡単に自己紹介です。すぎーといいます。iOS/Flutterエンジニアです。FlutterKaigiは2024の前夜祭LT以来です。\n先日のiOSDC Japan 2026ではvisionOSでカードバトルを再現する話をしました。今日はそのiOSアプリで運用している仕組みをFlutterに持ち込んだ話です。"
    }

    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        ReadmeSlide(
            title: "README",
            info: .init(
                name: "すぎー/Sugiy",
                image: .iconDynamic,
                firstText: "iOS/Flutterエンジニアです",
                secondText: "FlutterKaigiは2024の前夜祭LT以来2回目",
                thirdText: "iOSDC Japan 2026でvisionOSのカードバトルの話をしました",
                fourthText: "社内向けの「アプリ内バグ起票」機能をiOSで運用中",
                fifthText: "最近車と3Dプリンターを買ってお金が...💸"
            ),
            iconSize: 510 // 既定(340)の1.5倍
        )
        .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    }
}

#Preview {
    SlidePreview {
        Readme2026Slide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}
