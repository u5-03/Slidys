//
//  QuizDescriptionSlide.swift
//  ChibaSwiftSlide
//
//  Created by Yugo Sugiyama on 2024/09/08.
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
        HeaderSlide("千葉 シンボルクイズ！") {
            Item("千葉にちなんだ何かがアニメーションで描かれます！", accessory: .number(1))
            Item("分かった人は挙手して、回答してください！", accessory: .number(2))
            Item("問題は全部で3問", accessory: .number(3))
            Item("1番多く得点した人が優勝です！", accessory: .number(4))
            Item("なんと優勝した人には千葉にちなんだ賞品が！", accessory: .number(5))
            Item("Figmaで作ったSVGベースなので、絵心に問題あり...!", accessory: .number(6))
            Item("SNSなどでのクイズ結果のネタバレはご注意を！笑", accessory: .number(7))
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
