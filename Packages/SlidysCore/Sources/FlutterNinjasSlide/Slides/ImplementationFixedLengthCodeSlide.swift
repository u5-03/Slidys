//
//  ImplementationFixedLengthCodeSlide.swift
//  Slidys
//
//  Created by Yugo Sugiyama on 2024/11/06.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct ImplementationFixedLengthCodeSlide: View {
    var body: some View {
        CodeSlide(title: "固定長のPathのアニメーションのコード", code: CodeConstants.fixedLengthAnimationCode)
    }
}

#Preview {
    SlidePreview {
        ImplementationFixedLengthCodeSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
