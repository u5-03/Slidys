//
//  WidgetTreeSlide.swift
//  FlutterKaigi2026Slide
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct WidgetTreeSlide: View, PhasedScriptProviding {
    /// スピーカーノート(フェーズごとのセグメント。区切りがスライド内の「次を表示」位置)
    var scriptSegments: [String] {
        [
        "Widget 階層は、要素ピッカーとまったく同じ走査で取れます。rootElement から Element ツリーを再帰的に歩くだけです。",
        "各 Element で、Widget のクラス名、RenderBox のサイズ、identifier を 1 行ずつ書き出して、深さでインデントします。右のアプリの「階層を見る」で実際の出力が見られます。",
        "これをテキストファイルとして Issue に添付します。「意図した階層になっているか」「余計な Widget が挟まっていないか」をコード無しで確認できる、レイアウト崩れの一次資料になります。",
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
        HeaderSlide("Widget階層は要素ピッカーと同じ走査で取れる") {
            HStack(alignment: .top, spacing: 60) {
                VStack(alignment: .leading, spacing: 44) {
                    Item("rootElement から Element ツリーを再帰的に歩く", keywords: ["同じ走査"], accessory: .number(1))
                    if shows(.second) {
                        Item("クラス名・サイズ・identifier を深さでインデントして1行ずつ", keywords: ["インデント"], accessory: .number(2))
                    }
                    if shows(.third) {
                        Item("テキストで添付。レイアウト崩れの一次資料になる", keywords: ["一次資料"], accessory: .number(3))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                PhoneFrameView {
                    FlutterView(type: .widgetTree)
                }
                .frame(maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    SlidePreview {
        WidgetTreeSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}
