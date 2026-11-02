//
//  DiagnosticsMotivationSlide.swift
//  FlutterKaigi2026Slide
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct DiagnosticsMotivationSlide: View, PhasedScriptProviding {
    /// スピーカーノート(フェーズごとのセグメント。区切りがスライド内の「次を表示」位置)
    var scriptSegments: [String] {
        [
        "3つ目、環境情報やログの話です。冒頭にも言いましたが、OS やデバイス、ビルド番号をいちいち手で入力するのは大変です。抜けたり間違えたりもします。",
        "一方で直す側は、ログや Widget 階層があると、報告の文章だけよりずっと正確に状況を分析できます。",
        "つまり、人間が書くと抜ける・面倒・不正確な情報は、全部機械に拾わせる。人には判断が要るタイトルと一言だけ書いてもらう、という方針です。",
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
        HeaderSlide(loc: "環境情報の手入力は大変、ログがあると分析が正確") {
            Item(loc: "OS・デバイス・ビルド番号の手入力は大変で、抜けたり間違えたりする", keywords: ["手入力は大変"], accessory: .number(1))
            if shows(.second) {
                Item(loc: "ログや Widget 階層があると、直す側はより正確に状況分析できる", keywords: ["より正確に状況分析"], accessory: .number(2))
            }
            if shows(.third) {
                Item(loc: "機械が拾える情報は全部機械に。人が書くのはタイトルと一言だけ", keywords: ["全部機械に"], accessory: .number(3))
            }
        }
    }
}

#Preview {
    SlidePreview {
        DiagnosticsMotivationSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}
