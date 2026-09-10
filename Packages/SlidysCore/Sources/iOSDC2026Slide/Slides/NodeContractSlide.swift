//
//  NodeContractSlide.swift
//  iOSDC2026Slide
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct NodeContractSlide: View, PhasedScriptProviding {
    /// スピーカーノート(フェーズごとのセグメント。区切りがスライド内の「次を表示」位置)
    var scriptSegments: [String] {
        [
        "そして作ったモデルの中の特定の座標を取得したいなーいうと時に使えるのは「ロケーター」です。\nカードを置く5つのゾーン、デッキ、手首の固定点、ライフ表示の位置など、ディスクのオブジェクト内のこれらの座標が取得できないとアプリ側での処理ができないです。",
        "ロケーターは位置の目印として置く「形のないオブジェクト」で、BlenderではEmptyな空オブジェクトがこれにあたります。(EmptyViewと違って本当に空で、)今回は名前だけ付けて置いておきます。",
        "アプリ側はその名前で探すだけで、その座標を取得できます。モデルを作り直しても、ロケーターさえ残っていればコードの変更は不要です。",
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
        HeaderSlide("モデル内の部品の座標をコードから取得する") {
            Item("カード置き場やデッキ、手首の座標を取りたい", keywords: [], accessory: .number(1))
            if shows(.second) {
                Item("ロケーター = Blenderの空オブジェクト(Empty)を目印に", keywords: ["ロケーター"], accessory: .number(2))
            }
            if shows(.third) {
                Item("アプリは名前で探すだけ。コードは変更不要", keywords: ["コードは変更不要"], accessory: .number(3))
            }
        }
    }
}

#Preview {
    SlidePreview {
        NodeContractSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}
