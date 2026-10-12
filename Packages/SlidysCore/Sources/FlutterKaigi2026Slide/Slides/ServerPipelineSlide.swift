//
//  ServerPipelineSlide.swift
//  FlutterKaigi2026Slide
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct ServerPipelineSlide: View, PhasedScriptProviding {
    /// スピーカーノート(フェーズごとのセグメント。区切りがスライド内の「次を表示」位置)
    var scriptSegments: [String] {
        [
        "(時間が押していたらこのページはスキップ)\n起票後は、付けたラベルをトリガーに GitHub Actions を動かして、AI の下調べなどの後処理をしています。",
        "ラベルの種類を見て、タスク管理の Projects に入れるか、バグ管理の Projects に入れるかを振り分けています。",
        "小ネタとして、ラベルを同時に付けると Actions がキャンセルされるので、2段階で付けています。",
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
        HeaderSlide(loc: "起票後はGitHub Actionsにおまかせ(発展)") {
            Item(loc: "ラベルをトリガーに Actions で後処理(AI の下調べなど)", keywords: ["ラベルをトリガー"], accessory: .number(1))
            if shows(.second) {
                Item(loc: "ラベルの種類で、タスク管理 / バグ管理どちらの Projects に入れるかを判定", keywords: ["ラベルの種類"], accessory: .number(2))
            }
            if shows(.third) {
                Item(loc: "小ネタ: ラベルは2段階で付ける(同時付与だと concurrency で run がキャンセルされる)", keywords: ["2段階"], accessory: .number(3))
            }
        }
    }
}

#Preview {
    SlidePreview {
        ServerPipelineSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}
