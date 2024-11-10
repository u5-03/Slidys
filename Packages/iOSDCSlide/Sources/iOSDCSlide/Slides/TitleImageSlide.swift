//
//  TitleImageSlide.swift
//  iOSDC2024Slide
//
//  Created by Yugo Sugiyama on 2024/08/01.
//

import SwiftUI
import SlideKit
import SlidysCore

@Slide
struct TitleImageSlide: View {
    var body: some View {
        VStack(alignment: .center) {
            Text("結婚したので、パートナーの電子ピアノが\n我が家にやってきた")
                .font(.system(size: 100, weight: .heavy))
            Image(.newPiano)
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
        .padding(30)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundStyle(.defaultForegroundColor)
        .background(.slideBackgroundColor)
    }
}

#Preview {
    SlidePreview {
        TitleImageSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
