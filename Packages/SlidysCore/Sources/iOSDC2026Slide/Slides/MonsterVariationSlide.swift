//
//  MonsterVariationSlide.swift
//  iOSDC2026Slide
//
//  1モデル4バリエーションの説明 + 右側で具材切り替えのライブデモ。
//  (TaiyakiFocusView の fillingOnly モード: タップ・説明UIなし、ドラッグ回転と具材切り替えのみ)
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct MonsterVariationSlide: View, PhasedScriptProviding {
    /// スピーカーノート(フェーズごとのセグメント。区切りがスライド内の「次を表示」位置)
    var scriptSegments: [String] {
        [
        "では最後にこのたい焼きのモンスターについて確認しましょう。たい焼きのモンスターはカードによって中の具材が変わります。あんこ、クリーム、抹茶、チョコの4種類。\n4体分のモデルを作ったのではなく、1つのモデルに具材4種を別パーツとしてまとめ、実行時に対応するパーツだけ表示しています。",
        "使い分けの目安は、形ごと変えたいならパーツ切り替え、絵だけ変えたいならテクスチャ差し替えで対応できます。\n実際にこのように簡単に切り替えられます。",
        ]
    }

    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }
    @Environment(\.revealsAllPhases) private var revealsAllPhases
    @Environment(\.previewPhaseStep) private var previewPhaseStep
    @Phase private var phase: SlidePhase

    enum SlidePhase: Int, PhasedState {
        case initial, second
    }

    /// フェーズ表示の判定。通常は@Phaseの進行、スピーカーノートのプレビューでは
    /// previewPhaseStep(段階の直接指定)、一覧サムネイルでは全表示になる。
    private func shows(_ step: SlidePhase) -> Bool {
        if revealsAllPhases { return true }
        if let previewPhaseStep { return previewPhaseStep >= step.rawValue }
        return phase.isAfter(step)
    }

    var body: some View {
        HeaderSlide("モンスターは1モデルで4バリエーション") {
            HStack(alignment: .top, spacing: 60) {
                VStack(alignment: .leading, spacing: 44) {
                    Item("具材4種を同梱して、1つだけ表示", keywords: ["1つだけ表示"], accessory: .number(1))
                    if shows(.second) {
                        Item("テクスチャではなくパーツ単位で切り替え", keywords: ["パーツ単位"], accessory: .number(2))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                TaiyakiFocusView(mode: .fillingOnly, modelScale: 1.2)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .frame(width: 840)
                    .frame(maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    SlidePreview {
        MonsterVariationSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}
