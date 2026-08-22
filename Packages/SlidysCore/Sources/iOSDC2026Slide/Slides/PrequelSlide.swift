//
//  PrequelSlide.swift
//  iOSDC2026Slide
//
//  Swift愛好会 vol.92 で発表した SwiftUI 版召喚エフェクトが前日譚であることを伝えるスライド。
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct PrequelSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        HeaderSlide("実はこの発表には前日譚があります") {
            Item("2025年3月のSwift愛好会 vol.92で、SwiftUIでカードと召喚エフェクトを再現するデモを発表しました", accessory: .number(1))
            Item("当時はSwiftUI上の2D表現(このカードUIは今回も使っています)", accessory: .number(2))
            Item("今回はその続編: 舞台をApple Vision Proの空間に移して、カードバトルの体験そのものを再現します", accessory: .number(3))
            // TODO: 当時のデモ動画 or スクリーンショットがあればここに追加
        }
    }
}

#Preview {
    SlidePreview {
        PrequelSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
