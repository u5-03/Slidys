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
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        HeaderSlide("同じ仕組みはiOS/iPadOSでも使える") {
            HStack(alignment: .top, spacing: 60) {
                VStack(alignment: .leading, spacing: 44) {
                    Item("2Dよりも3Dで表示した方が確認しやすい場合もある", keywords: [], accessory: .number(1))
                    Item("見てほしいポイントにアンカーを置き、タップで部位の詳細を表示することもできる", keywords: ["アンカー"], accessory: .number(2))
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
