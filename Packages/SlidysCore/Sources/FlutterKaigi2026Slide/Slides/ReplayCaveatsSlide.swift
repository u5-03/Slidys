//
//  ReplayCaveatsSlide.swift
//  FlutterKaigi2026Slide
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct ReplayCaveatsSlide: View, PhasedScriptProviding {
    /// スピーカーノート(フェーズごとのセグメント。区切りがスライド内の「次を表示」位置)
    var scriptSegments: [String] {
        [
        "注意点もあります。\ntoImage が拾うのは Flutter が描いたピクセルだけです。地図や WebView、カメラなどの PlatformView は黒か空白になります。ReplayKit が「実画面の録画」なのに対して、こちらは「シーンの録画」です。",
        "負荷対策として、fps は 8 程度に、pixelRatio は下げてまず小さく。解像度が負荷とファイルサイズの主因です。",
        "フレームはメモリではなくファイルへローテーション。960 枚をメモリに持たない。",
        "撮影中はジャンクが増えうるので、デバッグビルド限定で ON/OFF できる前提にしています。",
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
        HeaderSlide("作ってみてわかった注意点") {
            Item("toImage が拾うのは Flutter が描いたピクセルだけ(PlatformView は黒)", keywords: ["Flutter が描いたピクセルだけ"], accessory: .number(1))
            if shows(.second) {
                Item("fps は 8 程度、pixelRatio は小さく。解像度が負荷とサイズの主因", keywords: ["pixelRatio"], accessory: .number(2))
            }
            if shows(.third) {
                Item("フレームはメモリではなくファイルへローテーション", keywords: ["ファイルへローテーション"], accessory: .number(3))
            }
            if shows(.fourth) {
                Item("デバッグビルド限定・ON/OFF できる前提で", keywords: ["デバッグビルド限定"], accessory: .number(4))
            }
        }
    }
}

#Preview {
    SlidePreview {
        ReplayCaveatsSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}
