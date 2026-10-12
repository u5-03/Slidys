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
        "簡単に自己紹介です。すぎーといいます。DeNAでiOS/Flutterエンジニアをしています。\n去年末まではFlutterアプリ、今はiPadOSアプリのプロジェクトにいて、今日はそのiPadOSアプリで運用している仕組みをFlutterに持ち込んだ話です。"
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
                firstText: "DeNAのiOS/Flutterエンジニア".loc,
                secondText: "FlutterKaigiは2024の前夜祭LT以来2回目".loc,
                thirdText: "去年末までFlutterアプリ、今はiPadOSアプリのプロジェクト".loc,
                fourthText: "最近車と3Dプリンターを買ってお金が...💸".loc,
                fifthText: "iPhone Duoを検討中…".loc
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
