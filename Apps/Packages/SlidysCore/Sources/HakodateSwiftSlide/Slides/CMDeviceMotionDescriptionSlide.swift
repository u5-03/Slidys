//
//  CMDeviceMotionDescriptionSlide.swift
//  HakodateSwiftSlide
//
//  Created by Yugo Sugiyama on 2024/09/08.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct CMDeviceMotionDescriptionSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        HeaderSlide("CMDeviceMotionで取得できる情報(一部抜粋)") {
            Item("attitude: 姿勢/向き ← このアプリで利用しているのはこれだけ！", accessory: .number(1))
            Item("rotationRate: 角速度", accessory: .number(2))
            Item("gravity: 重力加速度ベクトル", accessory: .number(3))
            Item("userAcceleration: ユーザー加速度", accessory: .number(4))
            Item("magneticField: 磁場", accessory: .number(5))
            Item("heading: 方位", accessory: .number(6))
            Item("sensorLocation: 左右どちらのイヤホンか", accessory: .number(7))
            Item("timestamp: タイムスタンプ", accessory: .number(8))
        }
    }
}

#Preview {
    SlidePreview {
        CMDeviceMotionDescriptionSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}

