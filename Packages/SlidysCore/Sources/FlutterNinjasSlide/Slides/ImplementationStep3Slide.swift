//
//  ImplementationStep3Slide.swift
//  Slidys
//
//  Created by Yugo Sugiyama on 2024/11/06.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct ImplementationStep3Slide: View {
    var body: some View {
        HeaderSlide("ステップ3 Pathを進捗率によって、Pathを部分的に表示できるようにする") {
            Item("PathオブジェクトからcomputeMetrics()でPathMetricの配列を取得する", accessory: .number(1)) {
                Item("PathMetricは、パスの長さや区間情報の情報を持つ", accessory: .number(1))
            }
            Item("PathMetricのextractPath(0, totalLength * progress)を使って、進捗率（progress: 0.0〜1.0）に応じた部分パスを生成する", accessory: .number(2))
            Item("そのPathをaddPath()で1つのPathにする", accessory: .number(3))
            Item("パスをCustomPainterのcanvas.drawPathで描画する", accessory: .number(4))
        }
    }
}

#Preview {
    SlidePreview {
        ImplementationStep3Slide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
