//
//  HandLocationStructureSlide.swift
//  iOSDC2025Slide
//
//  Created by Claude on 2025/01/09.
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct HandLocationStructureSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        HeaderSlide("HandLocationの仕組み") {
            ScrollView {
                Item("HandLocationとは？", accessory: .number(1)) {
                    Item("RealityKitの手の位置アンカー用API", accessory: .bullet)
                    Item("手の特定部位にオブジェクトを配置するための仕組み", accessory: .bullet)
                }
                Item("利用可能な位置", accessory: .number(2)) {
                    Item(".palm (手のひら)", accessory: .bullet)
                    Item(".wrist (手首)", accessory: .bullet)
                    Item(".indexFingerTip (人差し指の先端)", accessory: .bullet)
                    Item(".thumbTip (親指の先端)", accessory: .bullet)
                    Item("などなど", accessory: .bullet)
                }
                Item("座標系", accessory: .number(3)) {
                    Item("右手系の座標(右:+X, 上:+Y, 手前:+Z)", accessory: .bullet)
                    Item("単位はメートル", accessory: .bullet)
                }
            }
        }
    }
}

#Preview {
    SlidePreview {
        HandLocationStructureSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
