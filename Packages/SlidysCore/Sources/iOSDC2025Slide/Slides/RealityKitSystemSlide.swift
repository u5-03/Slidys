//
//  RealityKitSystemSlide.swift
//  iOSDC2025Slide
//
//  Created by Claude on 2025/01/09.
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct RealityKitSystemSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        HeaderSlide("RealityKitでの実装") {
            ScrollView {
                Item("ECS(Entity/Component/System)とは？", accessory: .number(1)) {
                    Item("Entity: 3D空間のオブジェクト(球体、文字、手など)", accessory: .number(1))
                    Item("Component: Entityの機能(見た目、動き、物理ルールなど)", accessory: .number(2))
                    Item("System: 特定のComponentに紐づいたEntityを毎フレーム処理するロジック", accessory: .number(3))
                }
                Item("System Protocolのupdate(context:)メソッド", accessory: .number(2)) {
                    Item("毎フレーム自動的に呼ばれる", accessory: .bullet)
                    Item("SceneUpdateContextから必要な情報を取得", accessory: .bullet)
                }
                Item("HandGestureTrackingSystem", accessory: .number(3)) {
                    Item("Systemに準拠した自作のSystem", accessory: .bullet)
                    Item("update(context:)で手の状態を継続的にチェック", accessory: .bullet)
                    Item("部位の位置や向きから、指定したハンドジェスチャーを検出する", accessory: .bullet)
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
