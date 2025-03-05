//
//  QuizAndroidReadMeSlide.swift
//  SlidysCore
//
//  Created by Yugo Sugiyama on 2025/03/01.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct QuizAndroidReadMeSlide: View {

    var body: some View {
        MultiIntroductionSlide(
            title: "チームAndroid",
            firstPersonInfo: .init(
                name: "ティフェン",
                image: .tahia,
                firstText: " PocochaのAndroidアプリ開発をやっています。",
                secondText: "アクセシビリティとアプリ品質についてお話をしましょう！"
            ),
            secondPersonInfo: .init(
                name: "",
                image: .tahia,
                firstText: "",
                secondText: ""
            )
        )
    }
}

#Preview {
    SlidePreview {
        QuizAndroidReadMeSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
