//
//  PanelMcReadMe.swift
//  SlidysCore
//
//  Created by Yugo Sugiyama on 2025/03/05.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct PanelMcReadMe: View {

    var body: some View {
        MultiIntroductionSlide(
            title: "「隣の芝は青く見えるようで実は青くないかもしれない」MC",
            firstPersonInfo: .init(
                name: "rokuro / 市原禄朗",
                image: .rokuro,
                firstText: "PocochaのAndroidアプリを開発しています",
                secondText: "趣味はバスケと開発で、最近はKMP触ったりWeb触ったりしています"
            ),
            secondPersonInfo: .init(
                name: "たむしゅん / 田村駿典",
                image: .tamusyun,
                firstText: "VoicePocochaのFlutterエンジニア(Flutter歴１年ちょいぐらい)",
                secondText: "趣味はバドミントン(ガット貼り機所有)、カメラ(滝を求めて山を歩いたり)"
            )
        )
    }
}

#Preview {
    SlidePreview {
        PanelMcReadMe()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
