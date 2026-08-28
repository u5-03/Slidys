//
//  TalkPlanSlide.swift
//  iOSDC2026Slide
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct TalkPlanSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        HeaderSlide("今日話すこと") {
            Item("3Dモデルを用意して表示する(Blender / Reality Composer Pro)", accessory: .number(1))
            Item("Hand Gestureでカードを引く・持つ・置く", accessory: .number(2))
            Item("エフェクトとアニメーションでそれらしくする", accessory: .number(3))
        }
    }
}

#Preview {
    SlidePreview {
        TalkPlanSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}
