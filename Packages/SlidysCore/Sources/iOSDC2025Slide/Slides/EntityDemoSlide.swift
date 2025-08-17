//
//  EntityDemoSlide.swift
//  iOSDC2025Slide
//
//  Created by Claude on 2025/01/09.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct EntityDemoSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        VStack(spacing: 40) {
            Text("Demo")
                .font(.system(size: 120, weight: .heavy))
                .foregroundStyle(.themeColor)
            
            Text("手の関節にEntityを表示")
                .font(.system(size: 80, weight: .bold))
                .foregroundStyle(.defaultForegroundColor)
            
            VStack(alignment: .leading, spacing: 30) {
                HStack {
                    Image(systemName: "hand.raised.fill")
                        .font(.system(size: 60))
                    Text("各関節に球体のマーカーを配置")
                        .font(.system(size: 50))
                }
                HStack {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    Text("リアルタイムで手の動きに追従")
                        .font(.system(size: 50))
                }
                HStack {
                    Image(systemName: "sparkles")
                        .font(.system(size: 60))
                        .foregroundColor(.yellow)
                    Text("27個の関節点が可視化")
                        .font(.system(size: 50))
                }
            }
            .padding(.horizontal, 60)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(80)
        .background(.slideBackgroundColor)
        .foregroundColor(.defaultForegroundColor)
    }
}

#Preview {
    SlidePreview {
        EntityDemoSlide()
    }
}