//
//  WrapUpSlide.swift
//  iOSDC2026Slide
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct WrapUpSlide: View, PhasedScriptProviding {
    /// スピーカーノート(フェーズごとのセグメント。区切りがスライド内の「次を表示」位置)
    var scriptSegments: [String] {
        [
        "まとめです。\nオブジェクトの形はBlender、エフェクト調整はReality Composer Pro、細かい振る舞いはコード、と役割を分けて実現しました。",
        "ハンドトラッキングのロストやブレはvisionOS側の制約なのでゼロにはできません。起きる前提で、逃げ道を設計に組み込むことが大事です。\nまたAIがあれば、実は3Dモデリングは思ったよりもハードルは高くないということです。",
        "「いつかやってみたかった」、ロマンある個人開発は楽しいです",
        ]
    }

    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }
    @Environment(\.revealsAllPhases) private var revealsAllPhases
    @Environment(\.previewPhaseStep) private var previewPhaseStep
    @Phase private var phase: SlidePhase

    enum SlidePhase: Int, PhasedState {
        case initial, second, third, fourth
    }

    /// フェーズ表示の判定。通常は@Phaseの進行、スピーカーノートのプレビューでは
    /// previewPhaseStep(段階の直接指定)、一覧サムネイルでは全表示になる。
    private func shows(_ step: SlidePhase) -> Bool {
        if revealsAllPhases { return true }
        if let previewPhaseStep { return previewPhaseStep >= step.rawValue }
        return phase.isAfter(step)
    }

    var body: some View {
        HeaderSlide("まとめ") {
            Item("形はBlender、エフェクトはRCP、振る舞いはコード", keywords: [], accessory: .number(1))
            if shows(.second) {
                Item("ロストやブレは起きる前提で設計する", keywords: ["起きる前提"], accessory: .number(2))
            }
            if shows(.third) {
                Item("AIがあれば3Dモデリングはコワくないよ", accessory: .number(3))
            }
            if shows(.fourth) {
                Item("「いつかやってみたかった」、ロマンある個人開発は楽しい", keywords: ["いつかやってみたかった」"], accessory: .number(4))
            }
        }
    }
}

#Preview {
    SlidePreview {
        WrapUpSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}
