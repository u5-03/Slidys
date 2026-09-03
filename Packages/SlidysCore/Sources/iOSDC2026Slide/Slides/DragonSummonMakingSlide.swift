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
            Item("動きのシーケンスを、ぱらぱら漫画のような絵コンテとして先に作成", keywords: ["絵コンテ"], accessory: .number(1))
            Item("絵コンテをベースに、Blender MCP経由でAIがモデルと動きを作成", keywords: ["AI"], accessory: .number(2))
            Item("細かい作り込みは自分の技術では届かず、これが今の限界", keywords: ["今の限界"], accessory: .number(3))
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
