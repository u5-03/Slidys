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
            // 去年のプロポーザル画像と、実際の登壇写真を横並びで
            HStack(spacing: 48) {
                appealImage(.proposal2025)
                appealImage(.iosdcDemo)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    /// プロポーザル画像(1200×630)と同じアスペクト比の枠に入れ、
    /// 縦長の写真は上下をセンタークロップして高さを揃える
    private func appealImage(_ resource: ImageResource) -> some View {
        Color.clear
            .aspectRatio(1200.0 / 630.0, contentMode: .fit)
            .overlay {
                Image(resource)
                    .resizable()
                    .scaledToFill()
            }
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.15), lineWidth: 2)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

@Slide
struct TrackingGestureListSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        HeaderSlide("ジェスチャーやトラッキングまわりの構成") {
            Item("検知の基礎はHandGestureKit: 関節の位置や指の形などを指定する", keywords: [], accessory: .number(1))
            Item("今回載せたのは、手首装着のトラッキング、ジェスチャー\n(3本指で手札を表示 / 2本指ドローで選択中のカード保持)など", keywords: [], accessory: .number(2))
            Item("ディスクの位置は手首の座標にディスクのロケーターの位置を合わせて配置", keywords: [], accessory: .number(3))
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
