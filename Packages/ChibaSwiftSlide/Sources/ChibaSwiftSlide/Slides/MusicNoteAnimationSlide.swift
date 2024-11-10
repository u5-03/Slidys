//
//  MusicNoteAnimationSlide.swift
//  ChibaSwiftSlide
//
//  Created by Yugo Sugiyama on 2024/09/08.
//

import SwiftUI
import SlideKit
import SlidysCore

@Slide
struct MusicNoteAnimationSlide: View {
    var body: some View {
        HeaderSlide("例えばこんなアニメーション") {
            HStack {
                Spacer()
                GradientMusicStrokeAnimationView(lineWidth: 10, duration: 5)
                    .aspectRatio(1, contentMode: .fit)
                    .frame(alignment: .center)
                Spacer()
            }
        }
    }
}

#Preview {
    SlidePreview {
        MusicNoteAnimationSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}

