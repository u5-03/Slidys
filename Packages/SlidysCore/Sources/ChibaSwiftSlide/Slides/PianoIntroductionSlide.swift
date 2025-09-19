//
//  PianoIntroductionSlide.swift
//  ChibaSwiftSlide
//
//  Created by Yugo Sugiyama on 2024/09/20.
//

import SwiftUI
import SlideKit
import PianoUI
import SlidesCore

@Slide
struct PianoIntroductionSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        VStack {
            Text("ピアノの発表でしたけど、スライド上で\nアニメーションで結構遊んだ")
                .font(.largeFont)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundStyle(.defaultForegroundColor)
                .background(.slideBackgroundColor)
            AnimatedPianoView(
                pianoStrokesList: [
                    [.init(key: .init(keyType: .c, octave: .fifth), velocity: 100, timestampNanoSecond: .now)],
                    [.init(key: .init(keyType: .aSharp, octave: .fourth), velocity: 100, timestampNanoSecond: .now)],
                    [.init(key: .init(keyType: .g, octave: .fourth), velocity: 100, timestampNanoSecond: .now)],
                    [.init(key: .init(keyType: .c, octave: .fifth), velocity: 100, timestampNanoSecond: .now)],
                    [.init(key: .init(keyType: .f, octave: .fourth), velocity: 100, timestampNanoSecond: .now)],
                    [.init(key: .init(keyType: .c, octave: .fifth), velocity: 100, timestampNanoSecond: .now)],
                    [.init(key: .init(keyType: .aSharp, octave: .fourth), velocity: 100, timestampNanoSecond: .now)],
                    [.init(key: .init(keyType: .c, octave: .fifth), velocity: 100, timestampNanoSecond: .now)],
                    [.init(key: .init(keyType: .f, octave: .fourth), velocity: 100, timestampNanoSecond: .now)],
                    [.init(key: .init(keyType: .g, octave: .fourth), velocity: 100, timestampNanoSecond: .now)],
                    [.init(key: .init(keyType: .g, octave: .fourth), velocity: 100, timestampNanoSecond: .now)],
                     [.init(key: .init(keyType: .aSharp, octave: .fourth), velocity: 100, timestampNanoSecond: .now)],
                    [.init(key: .init(keyType: .c, octave: .fifth), velocity: 100, timestampNanoSecond: .now)],
                ]
            )
            .frame(height: 400)
        }

    }
}

#Preview {
    SlidePreview {
        PianoIntroductionSlide()
    }
}

