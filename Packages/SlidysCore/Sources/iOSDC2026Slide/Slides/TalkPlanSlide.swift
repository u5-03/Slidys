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
        HeaderSlide("今日話すこと: カードバトル再現の3ステップ") {
            Item("BlenderやReality Composer Proを利用して、3Dモデルをアプリ上で表示できるようになるまでの流れ", accessory: .number(1))
            Item("Hand Gestureを活用してカードを引く、持つといったインタラクションの実装", accessory: .number(2))
            Item("カードの召喚エフェクトやオブジェクト移動アニメーションを使って、よりそれらしい体験を実現する工夫", accessory: .number(3))
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
