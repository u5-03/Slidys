//
//  PickerMotivationSlide.swift
//  FlutterKaigi2026Slide
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct PickerMotivationSlide: View, PhasedScriptProviding {
    /// スピーカーノート(フェーズごとのセグメント。区切りがスライド内の「次を表示」位置)
    var scriptSegments: [String] {
        [
        "例えば不具合箇所について「○○画面の右上のボタン」のような報告だと、開発者はどれが不具合対象なのかと探すところから始まってしまうこともあります。",
        "最近は修正を AI に頼むことも多いですが、そのときも「どの Widget か」が正確だと修正させやすくなります。",
        "なので、報告する人が画面上の Widget をタップしてどの範囲で不具合が起きているかを選択できるようにしました。",
        ]
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

    private func shows(_ step: SlidePhase) -> Bool {
        if revealsAllPhases { return true }
        if let previewPhaseStep { return previewPhaseStep >= step.rawValue }
        return phase.isAfter(step)
    }

    var body: some View {
        HeaderSlide(loc: "「画面のどこ」が明確だと直しやすい") {
            Item(loc: "曖昧だと不具合箇所を探すところから始まる", keywords: ["探すところから"], accessory: .number(1))
            if shows(.second) {
                Item(loc: "AI に修正を頼むときも、どの Widget かが正確に直させる材料になる", keywords: ["AI に修正を頼むとき"], accessory: .number(2))
            }
            if shows(.third) {
                Item(loc: "報告する人は画面上で対象の Widget をタップするだけにしたい", keywords: ["タップするだけ"], accessory: .number(3))
            }
        }
    }
}

#Preview {
    SlidePreview {
        PickerMotivationSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}
