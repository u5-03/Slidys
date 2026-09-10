//
//  BlenderMcpSlide.swift
//  iOSDC2026Slide
//
//  簡単なモデルならBlender MCP経由でAIに作らせられる、という紹介スライド。
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct BlenderMcpSlide: View, PhasedScriptProviding {
    /// スピーカーノート(フェーズごとのセグメント。区切りがスライド内の「次を表示」位置)
    var scriptSegments: [String] {
        [
        "ではBlender初心者の私が全て一からモデリングしたかというと、最初は手動で作りましたが、途中からはBlender MCPをメインで使っています。\nBlender MCPを使うと、ClaudeのようなAIがBlenderを直接操作してモデリングできます。「こういうモデルを作って」と頼むだけで、土台になる形はできてしまいます。",
        "細かい調整は必要ですが、「3Dモデリングは経験がないから無理」と思っている方も、まずAIに任せてみると結構いい感じになります。",
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
        HeaderSlide("簡単なモデルならAIでも作れる(Blender MCP)") {
            Item("AIがBlenderを直接操作してモデリング", keywords: ["直接操作"], accessory: .number(1))
            if shows(.second) {
                Item("細かい調整は人間が引き取る", keywords: [], accessory: .number(2))
            }
        }
    }
}

#Preview {
    SlidePreview {
        BlenderMcpSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}
