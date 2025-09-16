//
//  TrackingSystemImplementationSlide.swift
//  iOSDC2025Slide
//
//  Created by Claude on 2025/01/09.
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct TrackingSystemImplementationSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        HeaderSlide("HandGestureTrackingSystemの実装") {
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    Text("1. EntityQueryで手のEntityを取得")
                        .font(.regularFont)

                    CodeBlockView(
                        """
                        let handEntities = context.scene.performQuery(
                            EntityQuery(where: .has(HandTrackingComponent.self))
                        )
                        """)

                    Text("2. HandTrackingComponentから情報を抽出・整形")
                        .font(.regularFont)
                        .padding(.top, 10)

                    CodeBlockView(
                        """
                        for entity in handEntities {
                            if let component = entity.components[HandTrackingComponent.self] {
                                let chirality = component.chirality  // .left or .right
                                let handLocation = component.handLocation
                            }
                        }
                        """)

                    Text("3. ジェスチャー検出処理へ必要な情報を渡して、結果を受け取る")
                        .font(.regularFont)
                        .padding(.top, 10)

                    CodeBlockView(
                        """
                        let detectedGestures = GestureDetector.detectGestures(
                            from: handTrackingComponents,
                            targetGestures: targetGestures
                        )
                        """)
                }
            }
        }
    }
}

#Preview {
    SlidePreview {
        TrackingSystemImplementationSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
