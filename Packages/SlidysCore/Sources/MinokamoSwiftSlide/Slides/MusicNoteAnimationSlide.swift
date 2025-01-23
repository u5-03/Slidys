//
//  MusicNoteAnimationSlide.swift
//  KanagawaSwiftSlide
//
//  Created by Yugo Sugiyama on 2024/09/08.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct MusicNoteAnimationSlide: View {
    var body: some View {
        HeaderSlide("例えばこんなアニメーション") {
            HStack {
                Spacer()
                GradientMusicStrokeAnimationView(lineWidth: 10, duration: 3)
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

