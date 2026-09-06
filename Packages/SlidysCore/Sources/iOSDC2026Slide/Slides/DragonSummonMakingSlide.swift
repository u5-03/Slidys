//
//  DragonSummonMakingSlide.swift
//  iOSDC2026Slide
//
//  竜の召喚エフェクト(デモ2で見せたもの)をどう作ったかの説明。
//  右側で緋天竜の召喚シーケンスを自動ループ再生する(HitenryuSampleViewのautoLoopモード)。
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
            HStack(alignment: .top, spacing: 60) {
                VStack(alignment: .leading, spacing: 44) {
                    Item("動きのシーケンスを、ぱらぱら漫画のような絵コンテとして先に作成", keywords: ["絵コンテ"], accessory: .number(1))
                    Item("絵コンテをベースに、Blender MCP経由でAIがモデルと動きを作成", keywords: ["AI"], accessory: .number(2))
                    Item("細かい作り込みは自分の技術では届かず、これが今の限界", keywords: ["今の限界"], accessory: .number(3))
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                HitenryuSampleView(mode: .autoLoop, modelScale: 1.7)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .frame(width: 800)
                    .frame(maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
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
