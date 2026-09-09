//
//  WrapUpSlide.swift
//  iOSDC2026Slide
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct WrapUpSlide: View {
    /// スピーカーノート(発表者用の原稿。ノートWindowに表示される)
    var script: String {
        "まとめです。\nオブジェクトの形はBlender、エフェクト調整はReality Composer Pro、細かい振る舞いはコード、と役割を分けて実現しました。\nハンドトラッキングのロストやブレはvisionOS側の制約なのでゼロにはできません。起きる前提で、逃げ道を設計に組み込むことが大事です。\n制約は多いですが、「いつかやってみたかった」は個人開発でも形にできます。"
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
        HeaderSlide("まとめ") {
            Item("形はBlender、エフェクトはRCP、振る舞いはコード", keywords: [], accessory: .number(1))
            if shows(.second) {
                Item("ロストやブレは起きる前提で設計する", keywords: ["起きる前提"], accessory: .number(2))
            }
            if shows(.third) {
                Item("「いつかやってみたかった」は個人開発でも形にできる", keywords: ["個人開発でも形にできる"], accessory: .number(3))
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
