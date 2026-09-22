//
//  ElementPickerFlowSlide.swift
//  FlutterKaigi2026Slide
//
//  右に実機の Flutter 画面を埋め込み、話しながらその場で Widget をタップして選ぶ。
//  左はそこでできることの手順。
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct ElementPickerFlowSlide: View, PhasedScriptProviding {
    /// スピーカーノート(フェーズごとのセグメント。区切りがスライド内の「次を表示」位置)
    var scriptSegments: [String] {
        [
        "右のアプリで実際にやってみます。「要素を選ぶ」を押すと選択モードに入って、画面の上に透明なレイヤーが重なります。",
        "この状態で報告したい Widget をタップすると、その Widget が枠で囲まれて identifier が表示されます。",
        "カードの中のボタンのように入れ子になっている場合は、タップ位置を含む一番小さい、つまり一番具体的な要素が選ばれます。",
        "「この要素にする」で identifier が確定して、起票画面に戻ります。iOS の accessibilityIdentifier と同じ発想です。",
        ]
    }

    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }
    @Environment(\.revealsAllPhases) private var revealsAllPhases
    @Environment(\.previewPhaseStep) private var previewPhaseStep
    @Phase private var phase: SlidePhase

    enum SlidePhase: Int, PhasedState {
        case initial, second, third, fourth
    }

    private func shows(_ step: SlidePhase) -> Bool {
        if revealsAllPhases { return true }
        if let previewPhaseStep { return previewPhaseStep >= step.rawValue }
        return phase.isAfter(step)
    }

    var body: some View {
        HeaderSlide("タップした Widget が枠で囲まれる") {
            HStack(alignment: .top, spacing: 60) {
                VStack(alignment: .leading, spacing: 44) {
                    Item("「要素を選ぶ」で選択モードに入る", accessory: .number(1))
                    if shows(.second) {
                        Item("報告したい Widget をタップ → 枠と identifier が出る", keywords: ["タップ"], accessory: .number(2))
                    }
                    if shows(.third) {
                        Item("入れ子なら、タップ位置を含む一番小さい要素が選ばれる", keywords: ["一番小さい要素"], accessory: .number(3))
                    }
                    if shows(.fourth) {
                        Item("「この要素にする」で identifier が確定し、起票画面へ", keywords: ["identifier"], accessory: .number(4))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                PhoneFrameView {
                    FlutterView(type: .elementPicker)
                }
                .frame(maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    SlidePreview {
        ElementPickerFlowSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}
