//
//  CardPlacementSlide.swift
//  iOSDC2026Slide
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct CardPlacementSlide: View, PhasedScriptProviding {
    /// スピーカーノート(フェーズごとのセグメント。区切りがスライド内の「次を表示」位置)
    var scriptSegments: [String] {
        [
        "最後にカードを盤面に置く操作です。置く操作はvisionOS標準の視線+タップ、または選択したカードを右手に持ち替えて、置き場に重ねても置けます。",
        "ポイントは、タップされたEntityがどのゾーンかの判定を、名前の文字列比較ではなく自作Componentのタグで行っていることです。タップで返ってくるのは末端のEntityなので、そこから親の階層をたどって、Componentを持つEntityがあるかどうかで判定します。名前の文字列で探すより、モデルの構造変更に強くて安全です。",
        "さらに、持っているカードの種類に応じて、置けるスロットだけをハイライトしています。そのため魔法カードやトラップカードを選択している時はモンスターカードのスロットはハイライトされません。",
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
        HeaderSlide("カード配置・配置先の判定") {
            HStack(alignment: .top, spacing: 60) {
                VStack(alignment: .leading, spacing: 44) {
                    Item("視線 + タップ、またはカードを重ねて配置", keywords: [], accessory: .number(1))
                    if shows(.second) {
                        Item("配置先の判定はComponentタグで", keywords: ["Component"], accessory: .number(2))
                    }
                    if shows(.third) {
                        Item("置けるスロットだけハイライト", keywords: ["置けるスロットだけ"], accessory: .number(3))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(.blenderDiskPlacement)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.15), lineWidth: 2)
                    }
                    .frame(width: 860)
                    .frame(maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    SlidePreview {
        CardPlacementSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}
