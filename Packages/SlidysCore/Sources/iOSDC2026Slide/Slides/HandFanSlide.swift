//
//  HandFanSlide.swift
//  iOSDC2026Slide
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct HandFanSlide: View, PhasedScriptProviding {
    /// スピーカーノート(フェーズごとのセグメント。区切りがスライド内の「次を表示」位置)
    var scriptSegments: [String] {
        [
        "次に手札の表示の仕組みについて説明します。手札は、左手の親指・人差し指・中指の3本を合わせている間だけ、扇状に表示されます。",
        "なぜ3本かというと、visionOS標準の親指と人差し指の2本指ピンチはタップ操作として予約されているので、それと混同しないようにするためです。",
        "3本の指先を合わせると指先は1点に集まって、角度や向きが取れなくなります。なので扇の角度や向きを計算するために、指の付け根のナックルも利用しています。",
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
        HeaderSlide("左手の3本指「つまみ」で手札を表示") {
            HStack(alignment: .top, spacing: 60) {
                VStack(alignment: .leading, spacing: 44) {
                    Item("3本指を合わせている間だけ、手札を表示", keywords: ["3本指"], accessory: .number(1))
                    if shows(.second) {
                        Item("標準の2本指ピンチと区別", keywords: [], accessory: .number(2))
                    }
                    if shows(.third) {
                        Item("手札の向きや角度は付け根(ナックル)も利用", keywords: ["付け根(ナックル)"], accessory: .number(3))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // 3本指つまみで手札の扇を持っている実機シーン
                Image(.handFanCapture)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.15), lineWidth: 2)
                    }
                    .frame(width: 620)
                    .frame(maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    SlidePreview {
        HandFanSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}
