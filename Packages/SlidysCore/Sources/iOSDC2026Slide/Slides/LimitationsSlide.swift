//
//  LimitationsSlide.swift
//  iOSDC2026Slide
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct LimitationsSlide: View {
    /// スピーカーノート(発表者用の原稿。ノートWindowに表示される)
    var script: String {
        "一方で、再現してみてわかった制約もあります。\nまず腕とディスクの重なり。現実の腕が仮想のディスクを隠す処理が不完全で、腕時計のようには馴染みません。\nそして手首のトラッキングですが、たまにロストしますし、速い動きには追従が遅れ、カメラの死角に入ると止まります。また仮想の光は仮想のオブジェクトにしか当たらないので、現実の部屋は1ミリも明るくなりません。「部屋全体が光る」は原理的に再現できない。\n(ただWWDC26でPhysical Space Lightingが発表されたようなので、次期visionOSでは解消されているかもしれません。)"
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
        HeaderSlide("再現してみてわかった制約") {
            Item("腕とディスクのオクルージョンが不完全", keywords: ["オクルージョンが不完全"], accessory: .number(1))
            if shows(.second) {
                Item("手首トラッキングはロストする", keywords: ["ロストする"], accessory: .number(2))
            }
            if shows(.third) {
                Item("現実の部屋は照らせない(visionOS 26まで)", keywords: ["現実の部屋は照らせない"], accessory: .number(3))
            }
        }
    }
}

#Preview {
    SlidePreview {
        LimitationsSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}
