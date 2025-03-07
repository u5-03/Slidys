//
//  PanelerReadMeSlide.swift
//  SlidysCore
//
//  Created by Yugo Sugiyama on 2025/03/05.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct PanelerReadMeSlide: View {

    var body: some View {
        MultiIntroductionSlide(
            title: "「隣の芝は青く見えるようで実は青くないかもしれない」パネラー",
            firstPersonInfo: .init(
                name: "野瀬田 裕樹",
                image: .nodeda,
                firstText: "DMMのiOS/Flutter/Android?エンジニア(元DeNA)",
                secondText: "辞めた後でもDeNAのtimesが動くことがある笑"
            ),
            secondPersonInfo: .init(
                name: "守谷 / moriya",
                image: .moriya,
                firstText: "DeNAでFlutterのアプリやiOSのプロダクトにジョイン中",
                secondText: "去年はiOSDCとFlutterKaigiで両方とも40分登壇で疲弊しました"
            )
        )
    }
}

#Preview {
    SlidePreview {
        PanelerReadMeSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
