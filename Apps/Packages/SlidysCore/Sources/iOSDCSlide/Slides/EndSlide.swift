//
//  EndSlide.swift
//  iOSDC2024Slide
//
//  Created by Yugo Sugiyama on 2024/08/08.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct EndSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    @State private var eTextOffset: CGFloat = -EndSlide.defaultOffset
    @State private var nTextOffset: CGFloat = -EndSlide.defaultOffset
    @State private var dTextOffset: CGFloat = -EndSlide.defaultOffset
    private let duration: CGFloat = 0.5
    private static let defaultOffset: CGFloat = 1100

    func textMusicNoteView(text: String, musicNoteOffset: CGFloat) -> some View {
        ZStack {
            Image(.musicNote)
                .resizable()
                .scaledToFit()
                .foregroundStyle(Color.black)
                .padding()
                .frame(height: 1000)
                .offset(x: 20, y: musicNoteOffset)
            Text(text)
                .foregroundStyle(.white)
                .font(.system(size: 150, weight: .bold))
                .offset(x: -140, y: 230)
        }
    }

    var body: some View {
        HStack(spacing: -200) {
            textMusicNoteView(text: "E", musicNoteOffset: eTextOffset)
            textMusicNoteView(text: "N", musicNoteOffset: nTextOffset)
            textMusicNoteView(text: "D", musicNoteOffset: dTextOffset)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.white)
        .task {
            try? await Task.sleep(for: .seconds(1))
            withAnimation(.bouncy(duration: duration)) {
                eTextOffset = 0
            }
            try? await Task.sleep(for: .seconds(1))
            withAnimation(.bouncy(duration: duration, extraBounce: 0.2)) {
                nTextOffset = 0
            }
            try? await Task.sleep(for: .seconds(1))
            withAnimation(.easeOut(duration: duration * 1.5)) {
                dTextOffset = EndSlide.defaultOffset
            } completion: {
                Task {
                    try? await Task.sleep(for: .milliseconds(500))
                    withAnimation(.spring(duration: duration, bounce: 0.6) ) {
                        dTextOffset = 0
                    }
                }
            }
        }
    }
}

#Preview {
    SlidePreview {
        EndSlide()
    }
}
