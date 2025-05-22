//
//  ImplementationContentMoveSlide.swift
//  Slidys
//
//  Created by Yugo Sugiyama on 2024/11/06.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct ImplementationContentMoveSlide: View {
    var body: some View {
        HeaderSlide("Content move animation along a Path") {
            Item("Pass the widget you want to run move-animation along path", accessory: .number(1))
            Item("With getTangentForOffset(), get the coordinates at the last computeMetric object", accessory: .number(2))
            Item("Position the content to the coordinates", accessory: .number(3))
            Item("By animating the path, the coordinates will change and also move the content along the path", accessory: .number(4))
            Item("If necessary, we can change content rotations or detailed coordinates using offset", accessory: .number(4))
        }
    }
}

#Preview {
    SlidePreview {
        ImplementationContentMoveSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
