//
//  ImplementationContentMoveSlide.swift
//  Slidys
//
//  Created by Yugo Sugiyama on 2024/11/06.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct ImplementationContentMoveSlide: View {
    var body: some View {
        HeaderSlide("Textのdrawアニメーション") {
            Item("PathオブジェクトからcomputeMetrics()でPathMetric(サブパス情報)を取得する", accessory: .number(1))
            Item("PathMetricのgetTangentForOffset()を使って、Path上の任意の位置(offset)での座標を取得する", accessory: .number(2))
            Item("offset値はPathの全長やアニメーションの進捗率から、アニメーションの進捗に応じた位置を動的に決定できる", accessory: .number(3))
            Item("取得した座標を使い、ウィジェットやアイコンをPath上に沿って移動・回転させることができる", accessory: .number(4))
        }
    }
}

#Preview {
    SlidePreview {
        ImplementationContentMoveSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
