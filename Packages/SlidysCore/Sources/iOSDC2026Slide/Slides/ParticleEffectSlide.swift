//
//  ParticleEffectSlide.swift
//  iOSDC2026Slide
//
//  召喚バーストの説明 + 右側に実機キャプチャ(白飛びドームとスパークル)。
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct ParticleEffectSlide: View, PhasedScriptProviding {
    /// スピーカーノート(フェーズごとのセグメント。区切りがスライド内の「次を表示」位置)
    var scriptSegments: [String] {
        [
        "足元の光のバーストは、Reality Composer ProのGUIで作ったパーティクルです。\n線・スパークル・光の球の3つのエミッタを重ねていて、プレビューしながら挙動を微調整できるのはGUIならではのメリットです。",
        "まぶしい光の定番は、光をにじませる「ブルーム」という加工ですが、visionOSにはありません。\nそこで、ぼんやり光る粒をたくさん重ねて、中心を真っ白に飛ばしています。人の目は真っ白な部分を強い光と感じるので、これで十分光って見えます。",
        "パーティクルや光の球が床を突き抜ける問題は、OcclusionMaterialという見えない壁で下半分を隠して解決しました。",
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
        HeaderSlide("召喚バーストはRCPで作ったパーティクル") {
            HStack(alignment: .top, spacing: 60) {
                VStack(alignment: .leading, spacing: 44) {
                    Item("線・スパークル・光の球の3エミッタをRCPで調整", keywords: [], accessory: .number(1))
                    if shows(.second) {
                        Item("ブルームが無いので、光の粒を重ねて白く光らせる", keywords: ["白く"], accessory: .number(2))
                    }
                    if shows(.third) {
                        Item("見えない壁で下半分を隠して半球ドームに", keywords: ["見えない壁"], accessory: .number(3))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(.summonBurstCapture)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.15), lineWidth: 2)
                    }
                    .frame(width: 700)
                    .frame(maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    SlidePreview {
        ParticleEffectSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}
