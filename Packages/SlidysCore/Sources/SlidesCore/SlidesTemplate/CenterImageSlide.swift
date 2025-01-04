//
//  CenterImageSlide.swift
//
//
//  Created by Yugo Sugiyama on 2024/11/10.
//

import SwiftUI
import SlideKit

@Slide
public struct CenterImageSlide: View {
    let imageResource: ImageResource

    public init(imageResource: ImageResource) {
        self.imageResource = imageResource
    }

    public var body: some View {
        Image(imageResource)
            .resizable()
            .scaledToFit()
            .padding()
            .frame(maxWidth: .infinity)
            .background(.slideBackgroundColor)
    }
}

#Preview {
    SlidePreview {
        CenterImageSlide(imageResource: .icon)
    }
}

