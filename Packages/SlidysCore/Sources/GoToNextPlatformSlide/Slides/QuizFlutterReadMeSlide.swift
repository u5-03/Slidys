//
//  QuizFlutterReadMeSlide.swift
//  SlidysCore
//
//  Created by Yugo Sugiyama on 2025/03/01.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct QuizFlutterReadMeSlide: View {

    var body: some View {
        MultiIntroductionSlide(
            title: "チームFlutter",
            firstPersonInfo: .init(
                name: "朝日 大樹(ashdik)",
                image: .ashdik,
                firstText: "2020年12月に株式会社YOUTRUSTにジョインし、FlutterにてYOUTRUSTアプリを開発中",
                secondText: "一児の父で、投資、プロ野球観戦、クラフトビール、ワインなどをこよなく愛しています"
            ),
            secondPersonInfo: .init(
                name: "Lucas Goldner/金 瑠加須",
                image: .lucas,
                firstText: "YOUTRUSTの2代目Flutterエンジニア",
                secondText: "ドイツ出身。Flutter Tokyoの運営もしてます！"
            )
        )
    }
}

#Preview {
    SlidePreview {
        QuizFlutterReadMeSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
