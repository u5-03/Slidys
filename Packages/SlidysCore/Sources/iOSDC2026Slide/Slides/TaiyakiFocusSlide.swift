//
//  TaiyakiFocusSlide.swift
//  iOSDC2026Slide
//
//  iOS/iPadOS への応用例。右側にフォーカスUI付きのビューを埋め込み、その場でデモできる。
//  (商品紹介などの用途の話はスライドに載せず、原稿で軽く触れる)
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct TaiyakiFocusSlide: View {
    /// スピーカーノート(発表者用の原稿。ノートWindowに表示される)
    var script: String {
        "ここまではvisionOSの話でしたが、同じ仕組みはiOS/iPadOSでも使えます。\n2Dの写真より3Dモデルのほうが伝えられる情報は圧倒的に多いです。\n見てほしいポイントにアンカーを置いておけば、タップでその部位にズームして詳細を見せるような体験が作れます。\nモデルを回すと手前を向いた部位にだけボタンが出て、タップするとズームして解説が出ます。\nAIのおかげで、3Dオブジェクトを作るハードルも大きく下がっています。このような体験によって、もしかすると皆さんのプロダクトで新しい価値をユーザーに届けることができるかもしれません。"
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
        HeaderSlide("同じ仕組みはiOS/iPadOSでも使える") {
            HStack(alignment: .top, spacing: 60) {
                VStack(alignment: .leading, spacing: 44) {
                    Item("2Dより3Dの方が伝わるものもある", keywords: [], accessory: .number(1))
                    if shows(.second) {
                        Item("アンカーを置けば、タップで部位の解説へ", keywords: ["アンカー"], accessory: .number(2))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                TaiyakiFocusView(mode: .full, fontScale: 2.5, modelScale: 1)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .frame(width: 900)
                    .frame(maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    SlidePreview {
        TaiyakiFocusSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}
