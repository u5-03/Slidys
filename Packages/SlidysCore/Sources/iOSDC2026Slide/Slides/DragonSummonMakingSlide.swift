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
    /// スピーカーノート(発表者用の原稿。ノートWindowに表示される)
    var script: String {
        "次にこの竜の召喚エフェクトをどう作ったかです。\nまず動きのシーケンスを、ぱらぱら漫画のような絵コンテとして作りました。何コマ目で光が出て、何コマ目で竜が現れて、という設計図です。\nその絵コンテをベースに、さっき紹介したBlender MCP経由でAIにモデルと動きを作ってもらいました。\n正直細かい作り込みは自分の技術では手が届かず、正直このクオリティが今の限界でした。"
    }

    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }
    @Environment(\.revealsAllPhases) private var revealsAllPhases
    @Environment(\.previewPhaseStep) private var previewPhaseStep
    @Phase private var phase: SlidePhase

    enum SlidePhase: Int, PhasedState {
        case initial, second, third
    }

    /// フェーズ表示の判定。通常は@Phaseの進行、スピーカーノートのプレビューでは
    /// previewPhaseStep(段階の直接指定)、一覧サムネイルでは全表示になる。
    private func shows(_ step: SlidePhase) -> Bool {
        if revealsAllPhases { return true }
        if let previewPhaseStep { return previewPhaseStep >= step.rawValue }
        return phase.isAfter(step)
    }

    var body: some View {
        HeaderSlide("竜の召喚エフェクトができるまで") {
            HStack(alignment: .top, spacing: 60) {
                VStack(alignment: .leading, spacing: 44) {
                    Item("先にぱらぱら漫画のような絵コンテを作成", keywords: ["絵コンテ"], accessory: .number(1))
                    if shows(.second) {
                        Item("絵コンテをもとに、AIがモデルと動きを作成", keywords: ["AI"], accessory: .number(2))
                    }
                    if shows(.third) {
                        Item("細部までは作り込めず、これが今の限界", keywords: ["今の限界"], accessory: .number(3))
                    }
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
