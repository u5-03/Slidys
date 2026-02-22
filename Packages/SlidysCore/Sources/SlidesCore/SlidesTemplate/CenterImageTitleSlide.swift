//
//  CenterImageSlide.swift
//
//
//  Created by Yugo Sugiyama on 2024/11/10.
//

import SwiftUI
import SlideKit

@Slide
public struct CenterImageTitleSlide: View {
    let title: String
    let imageResource: ImageResource

    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    public init(title: String, imageResource: ImageResource) {
        self.title = title
        self.imageResource = imageResource
    }

    public var body: some View {
        HeaderSlide(.init(title)) {
            Image(imageResource)
                .resizable()
                .scaledToFit()
                .padding()
                .frame(maxWidth: .infinity)
                .background(.slideBackgroundColor)
        }
    }
}

#Preview {
    SlidePreview {
        CenterImageTitleSlide(title: "Title", imageResource: .icon)
    }
}

