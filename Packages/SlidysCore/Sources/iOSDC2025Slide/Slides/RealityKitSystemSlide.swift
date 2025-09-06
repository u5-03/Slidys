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
        HeaderSlide("RealityKit Systemの仕組み") {
            ScrollView {
                Item("Systemプロトコルとは？", accessory: .number(1)) {
                    Item("ECS(Entity Component System)アーキテクチャの一部", accessory: .bullet) {
                        Item("Entity: 表示するオブジェクトを格納", accessory: .number(1))
                        Item("Component: Entityに付与する性質や情報", accessory: .number(2))
                        Item("System: Entity/Componentを処理するロジックを記載", accessory: .number(3))
                    }
                    Item("フレームごとにEntity/Componentを処理する仕組み", accessory: .bullet)
                }
                Item("update(context:)メソッド", accessory: .number(2)) {
                    Item("毎フレーム自動的に呼ばれる", accessory: .bullet)
                    Item("SceneUpdateContextから必要な情報を取得", accessory: .bullet)
                }
                Item("HandGestureTrackingSystem", accessory: .number(3)) {
                    Item("struct HandGestureTrackingSystem: System", accessory: .bullet)
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
