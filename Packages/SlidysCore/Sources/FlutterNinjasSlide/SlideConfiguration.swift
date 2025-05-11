//
//  SlideConfiguration.swift
//  Slidys
//
//  Created by Yugo Sugiyama on 2024/10/27.
//

import Foundation
import SlideKit
import SwiftUI
import SlidesCore

public struct SlideConfiguration: SlideConfigurationProtocol {

    public let slideIndexController = SlideIndexController(index: 0) {
        CenterTextSlide(text: "FlutterNinjas2025")
        CenterTextSlide(text: "早速ですが質問です！")
        QuestionCircleSlide()
        QuestionCircleWithInfoSlide()
        CenterTextSlide(text: "これらのUIをFlutterで実装するにはどうすればいいだろう？")
        TitleSlide()
        ReadmeSlide()
        DescriptionSlide()
        CharactersSlide()
        LayoutComparisonSlide()
        SplitContentSlide(leadingWidthRatio: 0.6) {
            Text("円環(アニメーション)")
                .font(.largeFont)
                .foregroundStyle(.tint)
        } trailingContent: {
            FlutterView(type: .circleAnimation)
        }
        CircleAnimationDescriptionSlide()
        WrapUpSlide()
        ReferenceSlide()
        CenterTextSlide(text: "おしまい")
    }

    public init() {}
}
