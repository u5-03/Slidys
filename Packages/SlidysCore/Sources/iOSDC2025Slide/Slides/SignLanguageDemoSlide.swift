//
//  SignLanguageDemoSlide.swift
//  iOSDC2025Slide
//
//  Created by Claude on 2025/01/09.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct SignLanguageDemoSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        VStack(spacing: 40) {
        Text("Demo")
            .font(.system(size: 120, weight: .heavy))
            .foregroundStyle(.themeColor)
        Text("手話ジェスチャーの検知\n冒頭の手話の答え合わせ")
            .font(.system(size: 80, weight: .bold))
            .foregroundStyle(.defaultForegroundColor)
        }
        .padding(.horizontal, 100)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(80)
        .background(.slideBackgroundColor)
        .foregroundColor(.defaultForegroundColor)
    }
}

#Preview {
    SlidePreview {
        SignLanguageDemoSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
