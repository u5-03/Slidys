//
//  TrackingSystemImplementationSlide.swift
//  iOSDC2025Slide
//
//  Created by Claude on 2025/01/09.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct TrackingSystemImplementationSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        VStack(spacing: 30) {
            Text("HandGestureTrackingSystemの実装")
                .font(.system(size: 80, weight: .heavy))
                .foregroundStyle(.themeColor)
                .padding(.bottom, 20)
            
            VStack(alignment: .leading, spacing: 25) {
                Text("1. EntityQueryで手のEntityを取得")
                    .font(.system(size: 50, weight: .bold))
                
                CodeBlock("""
                let handEntities = context.scene.performQuery(
                    EntityQuery(where: .has(HandTrackingComponent.self))
                )
                """)
                
                Text("2. HandTrackingComponentから情報を抽出")
                    .font(.system(size: 50, weight: .bold))
                    .padding(.top, 10)
                
                CodeBlock("""
                for entity in handEntities {
                    if let component = entity.components[HandTrackingComponent.self] {
                        let chirality = component.chirality  // .left or .right
                        let handSkeleton = component.handSkeleton
                    }
                }
                """)
                
                Text("3. ジェスチャー検出処理")
                    .font(.system(size: 50, weight: .bold))
                    .padding(.top, 10)
                
                CodeBlock("""
                let detectedGestures = unifiedDetector.detectGestures(
                    from: handTrackingComponents
                )
                """)
            }
            .padding(.horizontal, 60)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(80)
        .background(.slideBackgroundColor)
        .foregroundColor(.defaultForegroundColor)
    }
}

struct CodeBlock: View {
    let code: String
    
    init(_ code: String) {
        self.code = code
    }
    
    var body: some View {
        Text(code)
            .font(.system(size: 35, weight: .regular, design: .monospaced))
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
    }
}

#Preview {
    SlidePreview {
        TrackingSystemImplementationSlide()
    }
}