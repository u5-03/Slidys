//
//  AnimationStructureSlide.swift
//  KanagawaSwiftSlide
//
//  Created by Yugo Sugiyama on 2024/09/08.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct BlurSummarySlide: View {
    var body: some View {
        HeaderSlide("Blurとは？ UIにおける役割") {
            Item("背景との視認性のバランス", accessory: .number(1)) {
                Item("背景とのその前面のコントラストを確保するのに役立つ", accessory: .number(1))
                Item("visionOSではWindowの背景のコンテキストを掴みやすくするため", accessory: .number(2)) {
                    Item("Window選択中は透明度が変わって、薄くなる", accessory: .number(1))
                }
            }
            Item("奥行き・階層表現", accessory: .number(2)) {
                Item("背景のContextを維持したまま、前面にUIを表示", accessory: .number(1)) {
                    Item("例: 通知センターやコントロールセンター", accessory: .number(1))
                }
            }
            Item("モダンで洗練された印象を与える", accessory: .number(3)) {
                Item("圧迫感を与えない、柔らかい自然な境界を作れる", accessory: .number(1))
            }
        }
    }
}

#Preview {
    SlidePreview {
        BlurSummarySlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}

