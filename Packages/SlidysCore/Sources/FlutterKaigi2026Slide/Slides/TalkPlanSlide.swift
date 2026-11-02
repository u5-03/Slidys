//
//  TalkPlanSlide.swift
//  FlutterKaigi2026Slide
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct TalkPlanSlide: View, PhasedScriptProviding {
    /// スピーカーノート(フェーズごとのセグメント。区切りがスライド内の「次を表示」位置)
    var scriptSegments: [String] {
        [
        "今日の話は3つです。\nまず、画面上の Widget をタップして報告対象を選ぶ仕組み。",
        "次に、不具合の瞬間を動画にする仕組み。",
        "最後に、ログや環境情報をチケットに添付する仕組みです。",
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
        HeaderSlide(loc: "今日話すこと") {
            Item(loc: "画面上のWidgetをタップして、対象のWidgetを選ぶ", accessory: .number(1))
            if shows(.second) {
                Item(loc: "静止画リングバッファ + デバイスで動画化して、不具合の動画を作る", accessory: .number(2))
            }
            if shows(.third) {
                Item(loc: "Widget階層・ログ・環境情報を一緒にチケットに添付する", accessory: .number(3))
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
