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
        HeaderSlide("HandLocationのJointにEntityを配置する") {
            ScrollView {
                VStack(alignment: .leading, spacing: 40) {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("1. RealityViewの基本構造")
                            .font(.regularFont)

                        CodeBlockView(
                            """
                            RealityView { content in
                                // ルートEntityを作成してシーンに追加
                                let rootEntity = Entity()
                                content.add(rootEntity)
                                
                                // 手のエンティティコンテナを作成
                                let handEntitiesContainerEntity = Entity()
                                rootEntity.addChild(handEntitiesContainerEntity)
                            }
                            """)
                    }

                    VStack(alignment: .leading, spacing: 15) {
                        Text("2. SpatialTrackingSessionで手の追跡を有効化(visionOS 2)")
                            .font(.regularFont)

                        CodeBlockView(
                            """
                            // 手の追跡を有効化
                            let session = SpatialTrackingSession()
                            let config = SpatialTrackingSession.Configuration(tracking: [.hand])
                            await session.run(config)

                            // AnchorEntityで関節を自動追跡
                            let anchorEntity = AnchorEntity( // visionOS2~
                                .hand(.left, location: .palm),
                                trackingMode: .predicted  // 予測補正で追跡遅延を低減
                            )

                            // 追加するだけで自動追跡開始
                            handEntitiesContainerEntity.addChild(anchorEntity)
                            """)
                    }

                    VStack(alignment: .leading, spacing: 15) {
                        Text("3. 関節マーカーの作成")
                            .font(.regularFont)

                        CodeBlockView(
                            """
                            // 球体マーカー用のEntityを作成
                            let sphereEntity = ModelEntity(
                                mesh: .generateSphere(radius: 0.005),
                                materials: [UnlitMaterial(color: .yellow)]
                            )

                            // AnchorEntityに追加(関節に追従)
                            anchorEntity.addChild(sphereEntity)
                            """)
                    }

                    VStack(alignment: .leading, spacing: 15) {
                        Text("4. ECSパターンでSystemからアクセス可能に")
                            .font(.regularFont)

                        CodeBlockView(
                            """
                            // カスタムのComponentを作成
                            var handComponent = HandTrackingComponent(chirality: .left)
                            handComponent.fingers[.thumbTip] = anchorEntity

                            // EntityにComponentを設定
                            handEntity.components.set(handComponent)

                            // これでSystemから検索・処理可能に！
                            """)
                    }
                }
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
