//
//  Created by yugo.a.sugiyama on 2025/09/15
//  Copyright ©Sugiy All rights reserved.
//


import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct HandGestureKitSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        HeaderSlide("HandGestureKit爆誕") {
            Item("RealityKitを使って手の関節にマーカーを表示する方法", accessory: .number(1))
            Item("SpatialTrackingSession/AnchorEntityを用いたハンドトラッキングの基礎", accessory: .number(2))
            Item("カスタムジェスチャーの検知手法", accessory: .number(3))
        }
    }
}

#Preview {
    SlidePreview {
        HandGestureKitSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}

