//
//  TrackingSetupSlide.swift
//  iOSDC2026Slide
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
        HeaderSlide("ハンドトラッキングのセットアップ") {
            Item("ARKitSessionで権限リクエスト + SpatialTrackingSessionで.hand/.worldを有効化", accessory: .number(1)) {
                Item("このあたりはiOSDC2025の発表と同じ構成です(詳細はそちらで)", accessory: .bullet)
            }
            Item("手の関節ごとにAnchorEntityを張り付けて位置を追跡", accessory: .number(2)) {
                Item("左手: 手首(デバイス装着) / 3指の先端(ピンチ判定) / 付け根3関節(手のひらの向き)", accessory: .bullet)
                Item("右手: 人差し指・中指の先端(ドロー判定+カード保持) / 付け根2関節(カードの向き)", accessory: .bullet)
            }
            Item("ピンチ判定はHandGestureKitのareFingerTipsTouchingを利用", accessory: .number(3)) {
                Item("2関節の距離がしきい値以下かを見るだけの軽量API", accessory: .bullet)
            }
        }
    }
}

#Preview {
    SlidePreview {
        TrackingSetupSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
