//
//  DeckDrawSlide.swift
//  iOSDC2026Slide
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct DeckDrawSlide: View {
    /// スピーカーノート(発表者用の原稿。ノートWindowに表示される)
    var script: String {
        "ドローは2段階のジェスチャーにしました。人差し指と中指でデッキに触れた後、そのまま指を離すか引き抜くとカードが1枚ドローできます。\n引いたカードは右手の指の間に追従します。\nこれでこのカードに全てをかけることもできます。"
    }

    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }
    @Environment(\.revealsAllPhases) private var revealsAllPhases
    @Environment(\.previewPhaseStep) private var previewPhaseStep
    @Phase private var phase: SlidePhase

    enum SlidePhase: Int, PhasedState {
        case initial, second
    }

    /// フェーズ表示の判定。通常は@Phaseの進行、スピーカーノートのプレビューでは
    /// previewPhaseStep(段階の直接指定)、一覧サムネイルでは全表示になる。
    private func shows(_ step: SlidePhase) -> Bool {
        if revealsAllPhases { return true }
        if let previewPhaseStep { return previewPhaseStep >= step.rawValue }
        return phase.isAfter(step)
    }

    var body: some View {
        HeaderSlide("デッキからカードを引く(ドロー)") {
            // フェーズで項目が増減しても画像の大きさ・位置が動かないよう、
            // 項目は上詰め・画像は下端の最終位置に固定する(Spacerが余白を吸収)。
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: ListTextStyle.iosdc2026.contentSpacing) {
                    Item("2本指でデッキに触れて、抜く動作でドロー", keywords: [], accessory: .number(1))
                    if shows(.second) {
                        Item("引いたカードは指の間に追従", keywords: [], accessory: .number(2))
                    }
                }
                Spacer(minLength: 24)
                // ドロー動作の実機シーン(下端に横長で配置、高さ固定)
                Image(.deckDrawCapture)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.15), lineWidth: 2)
                    }
                    .frame(height: 460)
                    .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    SlidePreview {
        DeckDrawSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}
