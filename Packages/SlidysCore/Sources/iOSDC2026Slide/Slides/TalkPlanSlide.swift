//
//  TalkPlanSlide.swift
//  iOSDC2026Slide
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct TalkPlanSlide: View {
    /// スピーカーノート(発表者用の原稿。ノートWindowに表示される)
    var script: String {
        "今日話すのはこの3つです。\nまずは3Dモデルを用意して表示する話。ここでは主にBlenderが出てきます。\n次にHand Gestureでカードを引いて、持って、置く実装の話です。\n最後にエフェクトとアニメーションで体験や演出を改善する話です。\n\nコードは最近だとAIに聞けば大抵解決できるので、今日はコードの詳細はほとんど出てきません。詳細はブログとコード、スライドはTestFlightで配布します。"
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
        HeaderSlide("今日話すこと") {
            Item("3Dモデルを用意して表示する", accessory: .number(1))
            if shows(.second) {
                Item("Hand Gestureでカードを操作する", accessory: .number(2))
            }
            if shows(.third) {
                Item("エフェクトとアニメーションで演出する", accessory: .number(3))
            }
        }
    }
}

#Preview {
    SlidePreview {
        TalkPlanSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}
