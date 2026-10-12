//
//  ElementPickerInsightsSlide.swift
//  FlutterKaigi2026Slide
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct ElementPickerInsightsSlide: View, PhasedScriptProviding {
    /// スピーカーノート(フェーズごとのセグメント。区切りがスライド内の「次を表示」位置)
    var scriptSegments: [String] {
        [
        "仕組みの肝は4つです。\nひとつ目、Element ツリーをトップからたどって、RenderObject の位置を取る。",
        "ふたつ目、localToGlobal で画面座標にして、そのまま枠にする。",
        "みっつ目、候補は Semantics の identifier を持つ要素だけにします。付け忘れた部品は、一番近い親が選ばれます。アクセシビリティ 対応がそのままデバッグ機能でも活用できます。",
        "よっつ目、タップ位置を含む候補のうち、一番小さいものを選ぶ。ざっくりこんな感じです！",
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

    private func shows(_ step: SlidePhase) -> Bool {
        if revealsAllPhases { return true }
        if let previewPhaseStep { return previewPhaseStep >= step.rawValue }
        return phase.isAfter(step)
    }

    var body: some View {
        HeaderSlide(loc: "仕組みの肝") {
            Item(loc: "Element ツリーをたどり、RenderObject の位置を取る", keywords: ["Element"], accessory: .number(1))
            if shows(.second) {
                Item(loc: "RenderBox.localToGlobal で画面座標に変換する", keywords: ["localToGlobal"], accessory: .number(2))
            }
            if shows(.third) {
                Item(loc: "目印は Semantics(identifier:) / ValueKey。a11y対応がデバッグ資産に", keywords: ["Semantics(identifier:)"], accessory: .number(3))
            }
            if shows(.fourth) {
                Item(loc: "タップ位置を含む候補のうち、面積が最小の要素を選ぶ", keywords: ["面積が最小"], accessory: .number(4))
            }
        }
    }
}

#Preview {
    SlidePreview {
        ElementPickerInsightsSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}
