//
//  RcpUsageSlide.swift
//  iOSDC2026Slide
//
//  プロポーザルで「BlenderやRCP」と書いた件を、実際の使い分けとして正直に話すスライド。
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct RcpUsageSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        HeaderSlide("BlenderとRCPの使い分け(実際はこうなった)") {
            Item("形を作るのはBlender。RCPを使ったのは召喚エフェクトのシーンの調整だけ(3章で)", keywords: ["召喚エフェクトのシーンの調整だけ"], accessory: .number(1))
            Item("当初はRCPでコンポーネント付与も想定してたが、複雑な設定はコードの方が管理しやすくコードへ", keywords: ["コードへ"], accessory: .number(2))
        }
    }
}

#Preview {
    SlidePreview {
        RcpUsageSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}
