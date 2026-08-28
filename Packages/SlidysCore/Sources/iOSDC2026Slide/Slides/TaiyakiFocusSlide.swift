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
                    Item("2Dの写真より、3Dモデルでの表示は情報量が多い", accessory: .number(1))
                    Item("実在するものなら、実際の空間に投影してより高い解像度で確認できる", accessory: .number(2))
                    Item("見てほしいポイントにアンカー → タップでその部位の詳細へ", accessory: .number(3))
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                TaiyakiFocusView(mode: .full)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .frame(width: 760)
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
