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
    var body: some View {
        HeaderSlide("大阪 シンボル？クイズ！") {
            Item("大阪にちなんだ何かがアニメーションで描かれます！", accessory: .number(1))
            Item("分かった人は挙手して、回答してください！", accessory: .number(2))
            Item("Figmaで作ったSVGベースなので、絵心に問題あり...!", accessory: .number(3)) {
                Item("色々推測して、がんばってください！笑", accessory: .number(1))
                Item("今回は手書きなので、より手作り感のある絵です笑", accessory: .number(2))
            }
            Item("Kanagawa.swiftと違って、マニアックなものが多め！", accessory: .number(3))
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
