//
//  ImageSlide.swift
//  iOSDC2024Slide
//
//  Created by Yugo Sugiyama on 2024/08/18.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct ImageSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    let imageResource: ImageResource

    var body: some View {
        Group {
            Image(imageResource)
                .resizable()
                .scaledToFit()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.slideBackgroundColor)

    }
}

#Preview {
    SlidePreview {
        ImageSlide(imageResource: .ipadAppCapture)
    }
}
