//
//  EntityPlacementSlide.swift
//  iOSDC2025Slide
//
//  Created by Claude on 2025/01/09.
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct EntityPlacementSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        HeaderSlide("HandSkeletonにEntityを配置する") {
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("1. RealityViewの基本構造")
                            .font(.regularFont)
                        
                        CodeBlockView("""
                        RealityView { content in
                            // ルートEntityを作成してシーンに追加
                            let rootEntity = Entity()
                            content.add(rootEntity)
                            
                            // 手のエンティティコンテナを作成
                            let handEntitiesContainer = Entity()
                            rootEntity.addChild(handEntitiesContainer)
                        }
                        """)
                    }
                    
                    VStack(alignment: .leading, spacing: 15) {
                        Text("2. AnchorEntityで関節を自動追跡")
                            .font(.regularFont)
                        
                        CodeBlockView("""
                        // 手の関節にアンカーを設定
                        let joint = AnchoringComponent.Target.HandLocation.joint(for: .thumbTip)
                        let anchorEntity = AnchorEntity(
                            .hand(.left, location: joint),
                            trackingMode: .predicted
                        )
                        
                        // シーンに追加するだけで自動追跡開始
                        handEntitiesContainer.addChild(anchorEntity)
                        """)
                    }
                    
                    VStack(alignment: .leading, spacing: 15) {
                        Text("3. 関節マーカーの作成")
                            .font(.regularFont)
                        
                        CodeBlockView("""
                        // 球体マーカーを作成
                        let sphere = ModelEntity(
                            mesh: .generateSphere(radius: 0.005),
                            materials: [UnlitMaterial(color: .yellow)]
                        )
                        
                        // AnchorEntityに追加（関節に追従）
                        anchorEntity.addChild(sphere)
                        """)
                    }
                    
                    VStack(alignment: .leading, spacing: 15) {
                        Text("4. ECSパターンでSystemからアクセス可能に")
                            .font(.regularFont)
                        
                        CodeBlockView("""
                        // カスタムコンポーネントを作成
                        var handComponent = HandTrackingComponent(chirality: .left)
                        handComponent.fingers[.thumbTip] = anchorEntity
                        
                        // Entityにコンポーネントを設定
                        handEntity.components.set(handComponent)
                        
                        // これでSystemから検索・処理可能に！
                        """)
                    }
                }
                .padding(.horizontal, 60)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.slideBackgroundColor)
            .foregroundColor(.defaultForegroundColor)
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
