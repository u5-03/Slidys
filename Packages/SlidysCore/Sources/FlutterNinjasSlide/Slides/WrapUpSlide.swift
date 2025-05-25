//
//  WrapUpSlide.swift
//  Slidys
//
//  Created by Yugo Sugiyama on 2024/11/09.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct WrapUpSlide: View {
    var body: some View {
        HeaderSlide("Wrap up") {
            Item("Explained how to animate Flutter Paths", accessory: .number(1))
            Item("Simple topic, but one that has many applications", accessory: .number(2))
            Item("As an application, we played the Japan Symbol Quiz to guess the Japan symbol", accessory: .number(3)) {
                Item("Did you have fun?", accessory: .number(1))
            }
            Item("There are a few other quizzes available too", accessory: .number(4)) {
                Item("If you want to take the quizzes, please catch me after this session.", accessory: .number(1))
            }
        }
    }
}

#Preview {
    SlidePreview {
        WrapUpSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
