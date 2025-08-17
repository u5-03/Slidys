//
//  RealityKitSystemSlide.swift
//  iOSDC2025Slide
//
//  Created by Claude on 2025/01/09.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct RealityKitSystemSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        HeaderSlide("RealityKit Systemの仕組み") {
            ScrollView {
                Item("Systemプロトコルとは？", accessory: .number(1)) {
                    Item("ECS（Entity Component System）アーキテクチャの一部", accessory: .bullet)
                    Item("フレームごとにEntityを処理する仕組み", accessory: .bullet)
                    Item("自動的にRealityKitランタイムに登録", accessory: .bullet)
                }
                Item("update(context:)メソッド", accessory: .number(2)) {
                    Item("毎フレーム自動的に呼ばれる", accessory: .bullet)
                    Item("約90Hz（Vision Pro）で更新", accessory: .bullet)
                    Item("SceneUpdateContextから必要な情報を取得", accessory: .bullet)
                }
                Item("HandGestureTrackingSystem", accessory: .number(3)) {
                    Item("struct HandGestureTrackingSystem: System", accessory: .bullet)
                    Item("init(scene:)でジェスチャー検出器を初期化", accessory: .bullet)
                    Item("update(context:)で手の状態を継続的に監視", accessory: .bullet)
                }
                Item("パフォーマンスの利点", accessory: .number(4)) {
                    Item("RealityKitが最適化された更新サイクルを管理", accessory: .bullet)
                    Item("必要な時だけ処理が実行される", accessory: .bullet)
                    Item("複数のSystemを効率的に並列実行", accessory: .bullet)
                }
            }
        }
    }
}

#Preview {
    SlidePreview {
        RealityKitSystemSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
