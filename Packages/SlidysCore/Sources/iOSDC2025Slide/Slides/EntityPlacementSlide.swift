//
//  EntityPlacementSlide.swift
//  iOSDC2025Slide
//
//  Created by Claude on 2025/01/09.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct EntityPlacementSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }
    
    var body: some View {
        HeaderSlide("HandSkeletonにEntityを配置する") {
            ScrollView {
                Item("RealityViewの基本構造", accessory: .number(1)) {
                    Item("SwiftUIビューとRealityKitを統合", accessory: .bullet)
                    Item("3D空間にEntityを配置・管理", accessory: .bullet)
                }
                Item("AnchorEntityによる手の追跡", accessory: .number(2)) {
                    Item("AnchorEntity(.hand(.left/.right, location: .joint))", accessory: .bullet)
                    Item("各関節に自動的に追従", accessory: .bullet)
                    Item("リアルタイムでの位置更新", accessory: .bullet)
                }
                Item("マーカーEntityの作成", accessory: .number(3)) {
                    Item("ModelEntity(mesh: .generateSphere(radius: 0.005))", accessory: .bullet)
                    Item("各関節ごとに異なる色を設定可能", accessory: .bullet)
                    Item("SimpleMaterialで視覚的にわかりやすく", accessory: .bullet)
                }
                Item("HandTrackingComponentの追加", accessory: .number(4)) {
                    Item("カスタムコンポーネントでメタデータを管理", accessory: .bullet)
                    Item("左右の手、関節名などを保持", accessory: .bullet)
                }
            }
        }
    }
}

#Preview {
    SlidePreview {
        EntityPlacementSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
