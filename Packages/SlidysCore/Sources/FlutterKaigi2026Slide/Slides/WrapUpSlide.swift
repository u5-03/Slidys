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
        "まとめです。\nWidget / Element / RenderObject の3つのツリーは、実行時の「観測対象」として使えます。普段は隠れていますが、覗く API は公開されています。",
        "アクセシビリティ対応、つまり identifier を付けておくことが、そのままデバッグ資産になります。a11y を入れる動機がひとつ増えます。",
        "Dart には動画エンコーダがありません。なので静止画のリングバッファは Flutter、動画化はデバイスに任せる。「できました」より「ここが壁で、こう割り切った」が今日一番伝えたかったところです。",
        "そして、報告は「タップ + 一言」、収集は機械に。デバッグ専用・パッケージ不要・数百行から始められるので、まず要素ピッカーだけでも試してみてください。",
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
        HeaderSlide("まとめ") {
            Item("3つのツリーは実行時の「観測対象」として使える", keywords: ["観測対象"], accessory: .number(1))
            if shows(.second) {
                Item("アクセシビリティ対応(identifier)がそのままデバッグ資産になる", keywords: ["デバッグ資産"], accessory: .number(2))
            }
            if shows(.third) {
                Item("Dart に動画エンコーダは無い → 静止画は Flutter、動画化はデバイスに", keywords: ["動画化はデバイスに"], accessory: .number(3))
            }
            if shows(.fourth) {
                Item("報告は「タップ + 一言」、収集は機械に。数百行から始められる", keywords: ["タップ + 一言"], accessory: .number(4))
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
