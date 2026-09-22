//
//  LogBufferSlide.swift
//  FlutterKaigi2026Slide
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct LogBufferSlide: View, PhasedScriptProviding {
    /// スピーカーノート(フェーズごとのセグメント。区切りがスライド内の「次を表示」位置)
    var scriptSegments: [String] {
        [
        "移植の最大の差分がログです。iOS では OSLogStore から直近のログを後から取れますが、Flutter にはそれに相当する OS の API がありません。",
        "なので main() で仕込みます。debugPrint を差し替え、Zone の print フックで print も捕まえ、FlutterError.onError と PlatformDispatcher.onError でエラーも流し込む。",
        "流し込む先はアプリ内のリングバッファで、直近 1000 行だけ保持します。起動時から溜め続けるのがポイントで、起票時にはそれをテキストにして添付するだけです。",
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

    private func shows(_ step: SlidePhase) -> Bool {
        if revealsAllPhases { return true }
        if let previewPhaseStep { return previewPhaseStep >= step.rawValue }
        return phase.isAfter(step)
    }

    var body: some View {
        HeaderSlide("最大の差分: ログは自分で溜める") {
            Item("Flutter には iOS の OSLogStore 相当の API がない", keywords: ["OSLogStore 相当の API がない"], accessory: .number(1))
            if shows(.second) {
                Item("main() で debugPrint / print / onError をフックして流し込む", keywords: ["main() で"], accessory: .number(2))
            }
            if shows(.third) {
                Item("起動時からアプリ内リングバッファに直近 1000 行を保持し、起票時に添付", keywords: ["起動時から"], accessory: .number(3))
            }
        }
    }
}

#Preview {
    SlidePreview {
        LogBufferSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}
