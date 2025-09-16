//
//  TalkPlanSlide.swift
//  KanagawaSwiftSlide
//
//  Created by Yugo Sugiyama on 2024/09/09.
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
            Item("RealityKitを使って手の部位にマーカーを表示する方法", accessory: .number(1))
            Item("SpatialTrackingSession/AnchorEntityを用いたハンドトラッキングの基礎", accessory: .number(2))
            Item("カスタムジェスチャーの検知手法", accessory: .number(3))
        }
    }
}

#Preview {
    SlidePreview {
        TalkPlanSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
