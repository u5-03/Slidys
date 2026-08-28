//
//  DragonSummonMakingSlide.swift
//  iOSDC2026Slide
//
//  竜の召喚エフェクト(デモ2で見せたもの)をどう作ったかの説明。
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct DragonSummonMakingSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        HeaderSlide("竜の召喚エフェクトができるまで") {
            Item("まず動きのシーケンスを、ぱらぱら漫画のような絵コンテとして作った", accessory: .number(1))
            Item("その絵コンテをベースに、Blender MCP経由でAIにモデルと動きを作ってもらった", accessory: .number(2))
            Item("細かい作り込みは自分の技術では届かず、このクオリティが今の限界", accessory: .number(3))
        }
    }
}

#Preview {
    SlidePreview {
        DragonSummonMakingSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}
