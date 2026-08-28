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
            Item("腕とディスクのオクルージョンが不完全(腕時計のようには隠れない)", accessory: .number(1))
            Item("手首トラッキングは頻繁にロストする。速い動きは追従が遅れる", accessory: .number(2))
            Item("シミュレータでは体験できない / 現実の部屋は照らせない", accessory: .number(3))
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
