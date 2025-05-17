//
//  ImplementationTextPathStepSlide.swift
//  Slidys
//
//  Created by Yugo Sugiyama on 2024/11/06.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct ImplementationTextPathStepSlide: View {
    var body: some View {
        HeaderSlide("Textのdrawアニメーション") {
            Item("PathオブジェクトからcomputeMetrics()でPathMetric(サブパス情報)を取得する", accessory: .number(1))
            Item("PathMetricのgetTangentForOffset()を使って、Path上の任意の位置(offset)での座標(position)や進行方向の角度(angle)を取得する", accessory: .number(2))
            Item("offset値はPathの全長(length)にprogress値(0.0〜1.0)を掛けて計算することで、アニメーションの進捗に応じた位置を動的に決定できる", accessory: .number(3))
            Item("取得した座標にPositionedなどで表示したいWidgetなどを配置する", accessory: .number(4))
        }
    }
}

#Preview {
    SlidePreview {
        ImplementationTextPathStepSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
