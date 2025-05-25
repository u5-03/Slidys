//
//  ImplementationStep2Slide.swift
//  Slidys
//
//  Created by Yugo Sugiyama on 2024/11/06.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct ImplementationStep2Slide: View {
    var body: some View {
        HeaderSlide("Step 2: Implement a Widget to display the Path") {
            Item("Prepare the Flutter Path object generated in Step 1", accessory: .number(1))
            Item("Draw the Path object as canvas.drawPath(path, paint) in the CustomPainter's paint method", accessory: .number(2))
            Item("Set the CustomPainter to a CustomPaint widget and display the SVG path on the screen", accessory: .number(3))
        }
    }
}

#Preview {
    SlidePreview {
        ImplementationStep2Slide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
