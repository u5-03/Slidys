//
//  ReplayMotivationSlide.swift
//  FlutterKaigi2026Slide
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct ReplayMotivationSlide: View, PhasedScriptProviding {
    /// スピーカーノート(フェーズごとのセグメント。区切りがスライド内の「次を表示」位置)
    var scriptSegments: [String] {
        [
        "不具合が発生した時、それが起きたあとに動画を撮り直すのは手間です。",
        "再現が難しい不具合だと、そもそも再現しないこともあります。",
        "現在の iPadOS のプロジェクトのアプリでは、裏で直近 60 秒の静止画を撮り続けて持っておき、起票のときに動画にしています。再現しなくても「起きた瞬間」に動画にすれば記録は残ります",
        "これを Flutter で作れるか、3段階に分けて検証しました。",
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
        HeaderSlide(loc: "事象が起きてから動画を撮るのは手間") {
            Item(loc: "起きたあとに撮り直すのは手間。", keywords: ["撮り直すのは手間"], accessory: .number(1))
            if shows(.second) {
                Item(loc: "再現が難しいと、再現させるのに時間がかかる(そもそも再現しないことも)", keywords: ["再現しない"], accessory: .number(2))
            }
            if shows(.third) {
                Item(loc: "現在のiPadOSのプロジェクトのアプリ: 裏で静止画を撮り続けて直近60秒をリングバッファに → 起票時に動画化", keywords: ["リングバッファ"], accessory: .number(3))
            }
            if shows(.fourth) {
                Item(loc: "Flutterでも作れる？ 3段階に分けて検証", keywords: ["3段階"], accessory: .number(4))
            }
        }
    }
}

#Preview {
    SlidePreview {
        ReplayMotivationSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}
