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
        "発展として、起票した後の話です。Issue に付けたラベルをトリガーに GitHub Actions で後処理を回しています。Project への自動振り分け、AI による下調べなどです。",
        "GitHub 側のリポジトリ、Issue テンプレート、Actions は iOS と Flutter で共通です。書き換えるのはクライアントだけ。マーカーとラベルの規約さえ守れば同じ運用に乗れます。",
        "小ネタですが、ラベルは2段階で付けています。作成と同時に全部付けると labeled イベントが同時に発火して、Actions の concurrency で後続の run がキャンセルされる。なので重要なラベルだけ 5 秒遅らせて付けています。",
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
        HeaderSlide("起票後はGitHub Actionsにおまかせ(発展)") {
            Item("ラベルをトリガーに Project へ振り分け・AI 下調べ", keywords: ["ラベルをトリガー"], accessory: .number(1))
            if shows(.second) {
                Item("repo / Issue テンプレート / Actions は iOS と Flutter で共通。書き換えるのはクライアントだけ", keywords: ["書き換えるのはクライアントだけ"], accessory: .number(2))
            }
            if shows(.third) {
                Item("小ネタ: ラベルは2段階で付ける(同時付与だと concurrency で run がキャンセルされる)", keywords: ["2段階"], accessory: .number(3))
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
