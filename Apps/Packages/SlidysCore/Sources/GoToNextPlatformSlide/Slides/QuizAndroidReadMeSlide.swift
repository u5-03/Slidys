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
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }


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
                name: "shinmiy",
                image: .shinmiy,
                firstText: "株式会社メルペイで主にAndroidアプリの開発をやっています",
                secondText: "6ヶ月の娘の蹴りがだんだん痛くなってきました"
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
