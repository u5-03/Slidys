//
//  WrapUpSlide.swift
//  FlutterKaigi2026Slide
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct WrapUpSlide: View, PhasedScriptProviding {
    /// スピーカーノート(フェーズごとのセグメント。区切りがスライド内の「次を表示」位置)
    var scriptSegments: [String] {
        [
        "まとめです。\nAI は機能開発だけでなく、開発の効率化や QA の負荷削減にも活用していくことが大事だと思っています。",
        "AI によって、こういう社内向けのツールを作るコストやハードルは大きく下がりました。",
        "そして、冒頭で QA をしたことがあるか聞きましたが、あまりしたことがない方は、まずは自分で QA をしてみてください。感覚がつかめると、課題意識を QA チームと共有しやすくなります。",
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
        HeaderSlide(loc: "まとめ") {
            Item(loc: "AI は機能開発だけでなく、効率化や QA の負荷削減にも", keywords: ["効率化や QA の負荷削減"], accessory: .number(1))
            if shows(.second) {
                Item(loc: "AI でツールを作るコストとハードルは大きく下がった", keywords: ["コストとハードル"], accessory: .number(2))
            }
            if shows(.third) {
                Item(loc: "まずは自分で QA をして、課題意識を QA チームと共有", keywords: ["自分で QA"], accessory: .number(3))
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
