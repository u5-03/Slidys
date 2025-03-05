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
            title: "",
            firstPersonInfo: .init(
                name: "",
                image: .icon,
                firstText: "",
                secondText: ""
            ),
            secondPersonInfo: .init(
                name: "",
                image: .clockvoid,
                firstText: "",
                secondText: ""
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
