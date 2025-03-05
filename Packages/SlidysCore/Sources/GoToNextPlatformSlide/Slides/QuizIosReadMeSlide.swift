//
//  QuizIosReadMeSlide.swift
//  SlidysCore
//
//  Created by Yugo Sugiyama on 2025/03/01.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct QuizIosReadMeSlide: View {

    var body: some View {
        MultiIntroductionSlide(
            title: "チームiOS",
            firstPersonInfo: .init(
                name: "",
                image: .akidon,
                firstText: "",
                secondText: ""
            ),
            secondPersonInfo: .init(
                name: "akidon0000",
                image: .akidon,
                firstText: "4月からSansanの新卒ぴよぴよiOSエンジニア",
                secondText: "引っ越しで光回線の契約が遅れ、11日までテザリングで辛抱中"
            )
        )
    }
}

#Preview {
    SlidePreview {
        QuizIosReadMeSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
