//
//  IntroductionSlide.swift
//
//
//  Created by Yugo Sugiyama on 2024/11/10.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct IntroductionSlide: View {
    var body: some View {
        HeaderSlide("SlideKit") {
            Item("SlideKit helps you make presentation slides by SwiftUI")
            Item("The followings are provided") {
                Item("Views", accessory: .number(2))
                Item("Structures")
                Item("Utilities")
            }
            .background(Color.blue)
        }
        .headerSlideStyle(CustomHeaderSlideStyle())
        .background(Color.green)
    }
}

struct CustomHeaderStyleSlide_Previews: PreviewProvider {
    static var previews: some View {
        SlidePreview {
            IntroductionSlide()
        }
    }
}
