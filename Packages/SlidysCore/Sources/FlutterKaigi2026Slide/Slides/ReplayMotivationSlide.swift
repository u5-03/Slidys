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
        "2つ目、動画の話です。課題はシンプルで、事象が起きたあとに「動画を撮り直そう」とするのは手間です。",
        "しかも再現が難しい不具合だと、もう一度起こすところで時間がかかる。そもそも再現しないこともあります。",
        "iOS 版では最初 ReplayKit を使いましたが、画質や開始タイミングが不安定でした。そこで裏で静止画を撮り続けて直近60秒だけリングバッファで持ち、起票時に動画にする方式にしました。「バグが起きた瞬間」を、再現しなくても後から取り出せます。",
        "この「静止画リングバッファ + 動画化」を Flutter で作れるのか。フレーム取得、リングバッファ、動画エンコードの3段階に分けて検証しました。",
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
        HeaderSlide("事象が起きてから動画を撮るのは手間") {
            Item("起きたあとに撮り直すのは手間。撮る前に画面が変わっていることも", keywords: ["撮り直すのは手間"], accessory: .number(1))
            if shows(.second) {
                Item("再現が難しいと、もう一度起こすのに時間がかかる(そもそも再現しない)", keywords: ["再現しない"], accessory: .number(2))
            }
            if shows(.third) {
                Item("iOS版: 裏で静止画を撮り続けて直近60秒をリングバッファに → 起票時に動画化", keywords: ["リングバッファ"], accessory: .number(3))
            }
            if shows(.fourth) {
                Item("Flutterでも作れる？ フレーム取得・リングバッファ・動画化の3段階で検証", keywords: ["3段階"], accessory: .number(4))
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
