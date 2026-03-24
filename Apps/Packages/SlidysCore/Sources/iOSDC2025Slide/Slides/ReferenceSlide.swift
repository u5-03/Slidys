//
//  WrapUpSlide.swift
//  KanagawaSwiftSlide
//
//  Created by Yugo Sugiyama on 2024/09/09.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct ReferenceSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        HeaderSlide("参考情報") {
            Item("WWDC24: Explore object tracking for visionOS", accessory: .number(1))
            Item("https://developer.apple.com/videos/play/wwdc2024/10101/", accessory: .bullet)
            
            Item("WWDC24: Explore object tracking for visionOS", accessory: .number(2))
            Item("https://developer.apple.com/videos/play/wwdc2024/10101/", accessory: .bullet)

            Item("TAAT『Apple Vision Proのハンドトラッキングでスペースシップを操縦しよう』", accessory: .number(3))
            Item("https://note.com/taatn0te/n/n3fa336d21252", accessory: .bullet)
        }
    }
}

#Preview {
    SlidePreview {
        ReferenceSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}

