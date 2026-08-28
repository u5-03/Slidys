//
//  TrackingSetupSlide.swift
//  iOSDC2026Slide
//
//  Hand Gesture章の導入2枚。
//  1枚目: 去年(iOSDC2025)の発表のアピール(プロポーザル画像)
//  2枚目: 今回使っているジェスチャーの一覧
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct TrackingSetupSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        HeaderSlide("土台は去年のHandGestureKitそのまま") {
            Image(.proposal2025)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.15), lineWidth: 2)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

@Slide
struct TrackingGestureListSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        HeaderSlide("ジェスチャーまわりの構成") {
            Item("検知の基礎はHandGestureKit: 関節ごとのAnchor + 指先距離の判定", accessory: .number(1))
            Item("今回載せたのは4つ: 手首装着 / 3本指の手札 / ドロー / 視線+タップ配置", accessory: .number(2))
            Item("今回のアプリ側で、指の付け根(ナックル)のアンカーを追加。理由は後ほど", accessory: .number(3))
        }
    }
}

#Preview("去年のアピール") {
    SlidePreview {
        TrackingSetupSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}

#Preview("ジェスチャー一覧") {
    SlidePreview {
        TrackingGestureListSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}
