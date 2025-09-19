//
//  QuizDescriptionSlide.swift
//  SlidysCore
//
//  Created by Yugo Sugiyama on 2025/03/06.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct QuizDescriptionSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        HeaderSlide("プラットフォーム横断公開モブプロ会「隣の芝鑑賞会」とは？") {
            Item("1つの共通のデザインをAndroid/iOS/Flutterで作る公開モブプロ", accessory: .number(1))
            Item("普段なかなか見れない自分が関わらないプラットフォームのUI実装の過程を覗き見る", accessory: .number(2))
            Item("4つのお題から、1つ選んで30分目安で、できるところまで作る!", accessory: .number(3))
            Item("UIの作り方は回答者にお任せ！", accessory: .number(4))
            Item("ChatGPTやCopilotなどのAI系ツールは、もちろんOK！", accessory: .number(5))
            Item("会場のみなさんも興味がある人はぜひ一緒に挑戦してみてください！", accessory: .number(6))
        }
    }
}

#Preview {
    SlidePreview {
        QuizDescriptionSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
