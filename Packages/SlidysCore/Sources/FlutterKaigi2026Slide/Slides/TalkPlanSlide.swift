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
        "今日話すのはこの3つです。\nまず、画面上の Widget をタップして報告対象を選ぶ仕組み。選んだ Widget が枠で囲まれます。",
        "次に、再現が難しいバグのために、静止画のリングバッファをデバイスで動画化して「不具合の瞬間の動画」を作る話。",
        "最後に、Widget階層・ログ・環境情報といった実行時の情報を、チケットに一緒に添付する方法です。\n\nコードは今日はほとんど出しません。最近はAIに聞けば大抵書けるので、大枠と「どこが壁だったか」を中心に話します。詳細はブログとGitHub、スライドはTestFlightで配布します。",
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
        HeaderSlide("今日話すこと") {
            Item("画面上のWidgetをタップして、対象のWidgetを選ぶ", accessory: .number(1))
            if shows(.second) {
                Item("静止画リングバッファ + デバイスで動画化して、不具合の動画を作る", accessory: .number(2))
            }
            if shows(.third) {
                Item("Widget階層・ログ・環境情報を一緒にチケットに添付する", accessory: .number(3))
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
