//
//  CardPlacementSlide.swift
//  iOSDC2026Slide
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct CardPlacementSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        HeaderSlide("カード配置: タップ先の判定") {
            Item("配置は標準の視線+タップ", keywords: [], accessory: .number(1))
            Item("どのゾーンかは自作Componentのタグで判定(名前の文字列比較はしない)", keywords: ["Component"], accessory: .number(2))
            Item("持っているカードの種類で、置けるスロットだけハイライト", keywords: ["置けるスロットだけ"], accessory: .number(3))
        }
    }
}

#Preview {
    SlidePreview {
        CardPlacementSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}
