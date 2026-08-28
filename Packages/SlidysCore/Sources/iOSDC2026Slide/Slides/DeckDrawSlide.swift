//
//  DeckDrawSlide.swift
//  iOSDC2026Slide
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct DeckDrawSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        HeaderSlide("デッキからカードを引く(ドロー)") {
            Item("2段階: 人差し指+中指でデッキに触れる=構え → 離す/抜く=発火", accessory: .number(1))
            Item("束から1枚スライドさせて抜く、あの動作の再現", accessory: .number(2))
            Item("引いたカードは右手の指の間に追従", accessory: .number(3))
        }
    }
}

#Preview {
    SlidePreview {
        DeckDrawSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}
