//
//  ReferenceSlide.swift
//  iOSDC2026Slide
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct ReferenceSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        HeaderSlide("参考情報") {
            Item("SpatialTrackingSession | Apple Developer Documentation", accessory: .number(1))
            Item("https://developer.apple.com/documentation/realitykit/spatialtrackingsession", accessory: .bullet)

            Item("ParticleEmitterComponent | Apple Developer Documentation", accessory: .number(2))
            Item("https://developer.apple.com/documentation/realitykit/particleemittercomponent", accessory: .bullet)

            Item("Meet ARKit for spatial computing - WWDC23", accessory: .number(3))
            Item("https://developer.apple.com/videos/play/wwdc2023/10082/", accessory: .bullet)

            Item("【iOSDC2025】手話ジェスチャーの検知と翻訳~ハンドトラッキングの可能性と限界~", accessory: .number(4))
            Item("https://ulog.sugiy.com/iosdc2025-vision-hand-gesture-tracking/", accessory: .bullet)
        }
    }
}

#Preview {
    SlidePreview {
        ReferenceSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
