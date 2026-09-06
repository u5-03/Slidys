//
//  LimitationsSlide.swift
//  iOSDC2026Slide
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct LimitationsSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        HeaderSlide("再現してみてわかった制約") {
            Item("腕とディスクのオクルージョンが不完全(腕時計のようには隠れない)", keywords: ["オクルージョンが不完全"], accessory: .number(1))
            Item("手首トラッキングはよくロストする。速い動きは追従が遅れるし、カメラの死角に入ると追跡が止まる", keywords: ["頻繁にロスト"], accessory: .number(2))
            Item("光の演出をしても、現実の部屋を照らすことはできない(visionOS 26まで)", keywords: ["現実の部屋を照らすことはできない"], accessory: .number(3))
        }
    }
}

#Preview {
    SlidePreview {
        LimitationsSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}
