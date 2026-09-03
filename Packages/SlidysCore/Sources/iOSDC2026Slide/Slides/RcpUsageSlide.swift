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
            Item("形を作るのはBlender。RCPはパッケージ形式(.rkassets)だけ", keywords: ["パッケージ形式(.rkassets)だけ"], accessory: .number(1))
            Item("当初はRCPでコンポーネント付与も想定 → 動的な要素ばかりでコードへ", keywords: ["コードへ"], accessory: .number(2))
            Item("RCPのGUIが活きたのは召喚エフェクト(3章で)", keywords: ["召喚エフェクト"], accessory: .number(3))
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
