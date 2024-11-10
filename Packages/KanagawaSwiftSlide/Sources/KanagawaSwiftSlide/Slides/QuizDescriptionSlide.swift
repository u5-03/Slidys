//
//  QuizDescriptionSlide.swift
//  KanagawaSwiftSlide
//
//  Created by Yugo Sugiyama on 2024/09/08.
//

import SwiftUI
import SlideKit
import SlidysCore

@Slide
struct QuizDescriptionSlide: View {
    var body: some View {
        HeaderSlide("神奈川 シンボルクイズ！") {
            Item("神奈川にちなんだ何かがアニメーションで描かれます！", accessory: .number(1))
            Item("分かった人は挙手して、回答してください！", accessory: .number(2))
            Item("問題は全部で5問", accessory: .number(3))
            Item("Figmaで作ったSVGベースなので、絵心に問題あり...!", accessory: .number(3)) {
                Item("色々推測して、がんばってください！笑", accessory: .number(1))
                Item("今回は手書きなので、より手作り感のある絵です笑", accessory: .number(2))
            }
            Item("王道のものから、マニアックなものまであります！", accessory: .number(4))
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
