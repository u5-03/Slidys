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
        "作ってみてわかった注意点です。\n撮影はネイティブで画面ごと撮るので、PlatformView も写ります。ただ、DRM 付きの動画やパスワード欄など、OS が保護している部分は黒くなります。",
        "秒数・解像度・fps は、プロジェクトに合わせて調整してください。まずは 8fps・小さめの解像度からがおすすめです。",
        "フレームはメモリに溜めず、ファイルに書いて古い順に消します。",
        "録画のような負荷が重い処理は、重たい機能を実行する時にはDebugMenuなどでOFF にできるようにしておくパフォーマンスに影響もしにくいです",
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
        HeaderSlide(loc: "作ってみてわかった注意点") {
            Item(loc: "撮影はネイティブで画面ごと。PlatformView も写る", keywords: ["ネイティブで画面ごと"], accessory: .number(1))
            if shows(.second) {
                Item(loc: "秒数・解像度・fps はプロジェクトに合わせて調整", keywords: ["プロジェクトに合わせて調整"], accessory: .number(2))
            }
            if shows(.third) {
                Item(loc: "フレームはファイルに溜め、古い順に消す", keywords: ["ファイルに溜め"], accessory: .number(3))
            }
            if shows(.fourth) {
                Item(loc: "負荷が重い処理は、実行時に OFF にできるようにする", keywords: ["OFF にできる"], accessory: .number(4))
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
