//
//  ImplementationFixedLengthStepSlide.swift
//  Slidys
//
//  Created by Yugo Sugiyama on 2024/11/06.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct ImplementationFixedLengthStepSlide: View {
    var body: some View {
        HeaderSlide("Pathの長さを固定したままのアニメーション") {
            Item("Path全体の長さをPathMetricで取得し、Pathの長さや進捗率から表示範囲を計算する", accessory: .number(1))
            Item("ループでPathMetricを順に処理し、それぞれの表示範囲を計算する", accessory: .number(2)) {
                Item("この表示範囲で、全体の表示範囲に含まれている範囲のPathのみ、addPathする", accessory: .number(1))
                Item("範囲外のPathはaddPathしないようにする", accessory: .number(3))
            }
            Item("抽出した部分Pathを合成し、アニメーションを実行する", accessory: .number(3))
        }
    }
}

#Preview {
    SlidePreview {
        ImplementationFixedLengthStepSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
