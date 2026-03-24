//
//  QuizMcReadMeSlide.swift
//  SlidysCore
//
//  Created by yugo.sugiyama on 2025/02/27.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct QuizMcReadMeSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    
    var body: some View {
        MultiIntroductionSlide(
            title: "「隣の芝鑑賞会」MC",
            firstPersonInfo: .init(
                name: "すぎー/Sugiy",
                image: .icon,
                firstText: "現職はDeNAで、play-by-sportsというFlutter製のスポーツ系のライブ配信アプリを開発中",
                secondText: "注文住宅の要件定義が終わったので、これから家のBuildが始まります"
            ),
            secondPersonInfo: .init(
                name: "田嶋秀成 / clockvoid",
                image: .clockvoid,
                firstText: "PocochaのAndroidアプリを作っています",
                secondText: "趣味はArch Linuxを自分好みにカスタマイズすることです"
            )
        )
    }
}

#Preview {
    SlidePreview {
        QuizMcReadMeSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
