//
//  MotivationSlide.swift
//  FlutterKaigi2026Slide
//
//  終盤で「なぜこれを作ったのか」を話す。技術の話の後に、課題意識を 3 つにまとめて置く。
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct MotivationSlide: View, PhasedScriptProviding {
    /// スピーカーノート(フェーズごとのセグメント。区切りがスライド内の「次を表示」位置)
    var scriptSegments: [String] {
        [
        "なぜ作ったのか、課題意識は3つです。\n1つ目、情報が足りないチケットで起きる、確認のやりとりを無くしたい。",
        "2つ目、AI で開発のアウトプットが増えた分、QAの負荷を減らしたい。",
        "3つ目、AIに直させるときにバグチケットの情報からできる限り修正しやすいコンテキストの情報を渡せるようにしたかったという点です。",
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
        HeaderSlide(loc: "なぜ作ったのか(課題意識)") {
            Item(loc: "コミュニケーションコストの削減。情報不足による確認のやりとりを無くしたい", keywords: ["コミュニケーションコストの削減"], accessory: .number(1))
            if shows(.second) {
                Item(loc: "AI で増えるエンジニアのアウトプットに対して、QA の負荷を減らしたい", keywords: ["QA の負荷"], accessory: .number(2))
            }
            if shows(.third) {
                Item(loc: "AI に修正させるための正確なコンテキストとして、そのまま渡せるチケットにしたい", keywords: ["AI に修正させる"], accessory: .number(3))
            }
        }
    }
}

#Preview {
    SlidePreview {
        MotivationSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}
