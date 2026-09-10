//
//  SummonSequenceSlide.swift
//  iOSDC2026Slide
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct SummonSequenceSlide: View, PhasedScriptProviding {
    /// スピーカーノート(フェーズごとのセグメント。区切りがスライド内の「次を表示」位置)
    var scriptSegments: [String] {
        [
        "召喚の演出は2つの場所で起きます。\nまずディスク上では、カードを置いたゾーンから周囲へ光のラインが走ります。",
        "フィールドではカードが出現して上昇し、放射状の光のバーストが弾けます。",
        "1秒後、光の中からモンスターがフェードインしながらせり上がってきます。",
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
        HeaderSlide("召喚シーケンスの全体像") {
            HStack(alignment: .top, spacing: 60) {
                VStack(alignment: .leading, spacing: 44) {
                    Item("置いたゾーンから周囲に光のライン", keywords: [], accessory: .number(1))
                    if shows(.second) {
                        Item("フィールドにカードが出現 + 光のバースト", keywords: [], accessory: .number(2))
                    }
                    if shows(.third) {
                        Item("光の中からモンスターが出現", keywords: [], accessory: .number(3))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // 上: ラインエフェクト / 下: モンスター出現の実機シーン(同じ枠サイズで縦に並べる)
                VStack(spacing: 24) {
                    captureImage(.summonLineCapture)
                    captureImage(.summonTaiyakiCapture)
                }
                .frame(width: 620)
                .frame(maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    /// 2枚を同じ枠サイズ・同じアスペクト比(16:10)で表示する(はみ出す分は中央基準でクロップ)
    private func captureImage(_ resource: ImageResource) -> some View {
        Color.clear
            .aspectRatio(16.0 / 10.0, contentMode: .fit)
            .overlay {
                Image(resource)
                    .resizable()
                    .scaledToFill()
            }
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.15), lineWidth: 2)
            }
    }
}

#Preview {
    SlidePreview {
        SummonSequenceSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}
