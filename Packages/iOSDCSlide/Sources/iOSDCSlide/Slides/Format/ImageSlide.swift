//
//  ImageSlide.swift
//  iOSDC2024Slide
//
//  Created by Yugo Sugiyama on 2024/08/18.
//

import SwiftUI
import SlideKit

@Slide
struct ImageSlide: View {
    let imageName: String

    var body: some View {
        Group {
            Image(imageName)
                .resizable()
                .scaledToFit()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.slideBackgroundColor)

    }
}

#Preview {
    SlidePreview {
        ImageSlide(imageName: "ipadAppCapture")
    }
}
