//
//  ImplementationTextPathStepSlide.swift
//  Slidys
//
//  Created by Yugo Sugiyama on 2024/11/06.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct ImplementationTextPathStepSlide: View {
    var body: some View {
        HeaderSlide("Text drawing animation") {
            Item("Load single-path font asset and parsed text using text_to_path_maker package", accessory: .number(1))
            Item("Extranct each character's glyph path and measure their bounds to determine scaling", accessory: .number(2))
            Item("Transform Glyph paths to pixel space, including Y-axis inversion and baseline adjustment", accessory: .number(3))
            Item("Place the glyphs horizontally with specified letter spacing", accessory: .number(4))
            Item("Scale the combined path and centered to fit the target area", accessory: .number(4))
        }
    }
}









#Preview {
    SlidePreview {
        ImplementationTextPathStepSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
