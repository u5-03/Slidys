//
//  Readme2026Slide.swift
//  iOSDC2026Slide
//
//  自己紹介スライド。項目が5つ+アイコンで縦に長いため、デッキ既定の
//  .iosdc2026(68pt/行間広め)だと下が見切れる。このスライドだけ従来の
//  .large 相当のスタイルに上書きして収める。
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct Readme2026Slide: View {
    /// スピーカーノート(発表者用の原稿。ノートWindowに表示される)
    var script: String {
        "簡単に自己紹介です。すぎーといいます。このたい焼きのアイコンを使ってます。iOS/Flutterエンジニアです。iOSDCのスタッフもしています。\n最近は車を買って、さらに3Dプリンターも買って、お金が大変です。最近まで庭でメロンも育ててました"
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
                secondText: "iOSDCのスタッフもしてます",
                thirdText: "最近車を買いました",
                fourthText: "3Dプリンターも買いました。お金が...💸",
                fifthText: "こないだまで庭でメロンを育ててました"
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
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .iosdc2026))
    .itemStyle(CustomItemStyle())
}
