//
//  QuizDescriptionSlide.swift
//  KanagawaSwiftSlide
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
        HeaderSlide("岐阜 シンボルクイズ！") {
            Item("岐阜にちなんだ何かがアニメーションで描かれます！", accessory: .number(1))
            Item("分かった人は挙手して、回答してください！", accessory: .number(2))
            Item("Figmaで作ったSVGベースなので、絵心に問題あり...!", accessory: .number(3)) {
                Item("色々推測して、がんばってください！笑", accessory: .number(1))
                Item("手書きなので、より手作り感のある絵です笑", accessory: .number(2))
            }
            Item("難易度は高め！？", accessory: .number(3))
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
