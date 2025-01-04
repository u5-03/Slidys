//
//  ShowDemoSlide.swift
//  Slidys
//
//  Created by Yugo Sugiyama on 2024/11/06.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct ShowDemoSlide: View {
    var body: some View {
        VStack(spacing: 100) {
            Text("実装例をお見せします")
                .font(.largeFont)
            Text("コードは一部を除き、GitHubに\nあげているので、詳細はそちらで！")
                .font(.largeFont)
        }
        .foregroundStyle(.defaultForegroundColor)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.slideBackgroundColor)
    }
}

#Preview {
    SlidePreview {
        ShowDemoSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
