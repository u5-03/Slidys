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
        "仕組みの肝は4つです。\nひとつ目、Widgetではなく Element を歩く。Widget は位置を持たないので、実体の Element から RenderObject に辿ります。",
        "ふたつ目、RenderBox.localToGlobal で画面座標に変換する。左上の座標とサイズが取れるので、そのまま Rect になります。",
        "みっつ目、全部の Widget に枠を出すとノイズだらけなので、Semantics(identifier:) か ValueKey を持つ要素だけを候補にする。\nアクセシビリティ対応がそのままデバッグ資産になります。",
        "よっつ目、タップ位置を含む候補のうち面積が一番小さいものを選ぶ。入れ子でも一番具体的な要素が選ばれます。ヒットテストは自前で、矩形の包含判定だけで済みます。",
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
        HeaderSlide("仕組みの肝") {
            Item("Widget ではなく Element を歩く", keywords: ["Element"], accessory: .number(1))
            if shows(.second) {
                Item("RenderBox.localToGlobal で画面座標に変換する", keywords: ["localToGlobal"], accessory: .number(2))
            }
            if shows(.third) {
                Item("目印は Semantics(identifier:) / ValueKey。a11y対応がデバッグ資産に", keywords: ["Semantics(identifier:)"], accessory: .number(3))
            }
            if shows(.fourth) {
                Item("タップ位置を含む候補のうち、面積が最小の要素を選ぶ", keywords: ["面積が最小"], accessory: .number(4))
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
