//
//  HandSkeletonStructureSlide.swift
//  iOSDC2025Slide
//
//  Created by Claude on 2025/01/09.
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct HandSkeletonStructureSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        HeaderSlide("HandSkeletonの仕組み") {
            ScrollView {
                Item("HandSkeletonとは？", accessory: .number(1)) {
                    Item("ARKitが提供する手の骨格モデル", accessory: .bullet)
                    Item("27個の関節点(ジョイント)で構成", accessory: .bullet)
                }
                Item("取得可能な関節情報", accessory: .number(2)) {
                    Item("手首(wrist)", accessory: .bullet)
                    Item(
                        "各指の関節(metacarpal(中手骨), proximal(基節骨), intermediate(中節骨), distal(末節骨), tip(指先))",
                        accessory: .bullet)
                    Item("前腕(forearmArm)", accessory: .bullet)
                }
                Item("各関節から取得できるデータ", accessory: .number(3)) {
                    Item("位置(position): SIMD3<Float>", accessory: .bullet)
                    Item("向き(orientation): simd_quatf", accessory: .bullet)
                    Item("親関節からの相対位置", accessory: .bullet)
                }
                Item("座標系", accessory: .number(4)) {
                    Item("右手系座標(右:+X, 上:+Y, 手前:+Z)", accessory: .bullet)
                    Item("単位はメートル", accessory: .bullet)
                }
            }
        }
    }
}

#Preview {
    SlidePreview {
        HandSkeletonStructureSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
