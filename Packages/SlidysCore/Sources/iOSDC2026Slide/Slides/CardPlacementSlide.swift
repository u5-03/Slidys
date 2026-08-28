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
        HeaderSlide("カード配置: どこがタップされたかはComponentで判定") {
            Item("配置は標準の視線+タップ", accessory: .number(1))
            Item("タップされたEntityが「どのゾーンか」は、名前の文字列ではなく自作Componentのタグで判定", accessory: .number(2))
            Item("持っているカードの種類で、置けるスロットだけハイライト", accessory: .number(3))
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
