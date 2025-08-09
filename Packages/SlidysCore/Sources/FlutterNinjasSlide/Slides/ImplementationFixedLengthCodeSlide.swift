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
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        CodeSlide(title: "Code for fixed length Path animation", code: CodeConstants.fixedLengthAnimationCode)
    }
}

#Preview {
    SlidePreview {
        ImplementationFixedLengthCodeSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
