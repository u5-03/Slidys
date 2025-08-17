//
//  CustomGestureDemoSlide.swift
//  iOSDC2025Slide
//
//  Created by Claude on 2025/01/09.
//

import SwiftUI
import SlideKit
import SlidesCore

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
            
            VStack(spacing: 35) {
                GestureItem(emoji: "✌️", name: "ピースサイン", description: "人差し指と中指を立てる")
                GestureItem(emoji: "👍", name: "サムズアップ", description: "親指を立てる")
                GestureItem(emoji: "👉", name: "ポインティング", description: "人差し指で指す")
                GestureItem(emoji: "✋", name: "フラットハンド", description: "手のひらを開く")
                GestureItem(emoji: "✊", name: "グー", description: "握りこぶし")
            }
            .padding(.horizontal, 100)
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
}