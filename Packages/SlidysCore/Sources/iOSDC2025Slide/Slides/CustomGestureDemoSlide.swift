//
//  CustomGestureDemoSlide.swift
//  iOSDC2025Slide
//
//  Created by Claude on 2025/01/09.
//

import SwiftUI
import SlideKit
import SlidesCore
#if canImport(HandGesturePackage)
import HandGesturePackage
#endif

@Slide
struct CustomGestureDemoSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        VStack(spacing: 40) {
            Text("Demo")
                .font(.system(size: 120, weight: .heavy))
                .foregroundStyle(.themeColor)
            
            Text("カスタムジェスチャーの検知")
                .font(.system(size: 80, weight: .bold))
                .foregroundStyle(.defaultForegroundColor)
            
#if canImport(HandGesturePackage)
            ImmersiveSpaceControlButton(fontSize: 60)
#else
            Text("visionOSでのみデモは開始できます")
                .font(.system(size: 40))
                .foregroundStyle(.gray)
#endif
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(80)
        .background(.slideBackgroundColor)
        .foregroundColor(.defaultForegroundColor)
    }
}

struct GestureItem: View {
    let emoji: String
    let name: String
    let description: String
    
    var body: some View {
        HStack(spacing: 30) {
            Text(emoji)
                .font(.system(size: 70))
            
            VStack(alignment: .leading, spacing: 5) {
                Text(name)
                    .font(.system(size: 45, weight: .bold))
                Text(description)
                    .font(.system(size: 35))
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
    }
}

#Preview {
    SlidePreview {
        CustomGestureDemoSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
