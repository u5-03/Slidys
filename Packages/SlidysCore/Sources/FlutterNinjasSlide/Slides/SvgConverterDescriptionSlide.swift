//
//  SvgConverterDescriptionSlideswift.swift
//  Slidys
//
//  Created by Yugo Sugiyama on 2024/11/06.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct SvgConverterDescriptionSlideswift: View {
    var body: some View {
        HeaderSlide("Custom conversion logic from SVG to Flutter Path") {
            Item("Use the xml package to load SVG files as text and parse them as XML", accessory: .number(1))
            Item("Extract <path> elements and get the d attribute (path data) of each element", accessory: .number(2))
            Item("Use the path_drawing package to convert the d attribute path data to Flutter Path objects", accessory: .number(3))
            Item("Use addPath() to integrate multiple Paths into one as needed", accessory: .number(4))
        }
    }
}

#Preview {
    SlidePreview {
        SvgConverterDescriptionSlideswift()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
