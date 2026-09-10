//
//  RcpUsageSlide.swift
//  iOSDC2026Slide
//
//  プロポーザルで「BlenderやRCP」と書いた件を、実際の使い分けとして正直に話すスライド。
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct RcpUsageSlide: View, PhasedScriptProviding {
    /// スピーカーノート(フェーズごとのセグメント。区切りがスライド内の「次を表示」位置)
    var scriptSegments: [String] {
        [
        "形を作るのは全部Blenderです。",
        "Reality Composer Proを使ったのは、後ほど紹介する召喚エフェクトのシーンの調整だけです。",
        "当初はReality Composer Proでコンポーネントを付けることも想定していましたが、今回の設定は複雑で、コードで管理する方が楽でした。AI活用も考えると、コードの方が設定はしやすいです。",
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

    /// フェーズ表示の判定。通常は@Phaseの進行、スピーカーノートのプレビューでは
    /// previewPhaseStep(段階の直接指定)、一覧サムネイルでは全表示になる。
    private func shows(_ step: SlidePhase) -> Bool {
        if revealsAllPhases { return true }
        if let previewPhaseStep { return previewPhaseStep >= step.rawValue }
        return phase.isAfter(step)
    }

    var body: some View {
        HeaderSlide("BlenderとRCPの使い分け(実際はこうなった)") {
            Item("形を作るのはBlender", keywords: ["Blender"], accessory: .number(1))
            if shows(.second) {
                Item("RCPを使ったのは召喚エフェクトの調整だけ(3章で)", keywords: ["召喚エフェクトの調整だけ"], accessory: .number(2))
            }
            if shows(.third) {
                Item("複雑な設定はコードで付与", keywords: ["コードで"], accessory: .number(3))
            }
        }
    }
}

#Preview {
    SlidePreview {
        RcpUsageSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}
