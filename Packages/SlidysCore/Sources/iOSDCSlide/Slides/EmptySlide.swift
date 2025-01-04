//
//  EmptySlide.swift
//  iOSDC2024Slide
//
//  Created by Yugo Sugiyama on 2024/08/01.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct EmptySlide: View {
    var body: some View {
        Color.slideBackgroundColor
    }
}

#Preview {
    SlidePreview {
        EmptySlide()
    }
}
