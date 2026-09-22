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
        "まず課題から。画面のどこで不具合が起きているかが明確に書かれていると、修正はずっと速くなります。「○○画面の右上のボタン」のような文章だと、探すところから始まります。",
        "それに最近は不具合の修正を AI に依頼することも多いですよね。そのときも「どの Widget か」が正確に指定されていると、正確に直させるための材料になります。",
        "なので、報告する人が画面上で対象の Widget をタップするだけで、その Widget の識別子が Issue に載る仕組みにしました。",
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
        HeaderSlide("「画面のどこ」が明確だと直しやすい") {
            Item("「○○画面の右上のボタン」は探すところから始まる", keywords: ["探すところから"], accessory: .number(1))
            if shows(.second) {
                Item("AI に修正を頼むときも、どの Widget かが正確に直させる材料になる", keywords: ["AI に修正を頼むとき"], accessory: .number(2))
            }
            if shows(.third) {
                Item("報告する人は画面上で対象の Widget をタップするだけにしたい", keywords: ["タップするだけ"], accessory: .number(3))
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
