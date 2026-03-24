//
//  PianoSlide.swift
//  Slidys
//
//  Created by Yugo Sugiyama on 2024/10/27.
//

import SwiftUI
import SlideKit
import SlidesCore
import PianoUI

@Slide
struct PianoSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        VStack {
            Text("FlutterのPianoUI")
                .font(.smallFont)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundStyle(.defaultForegroundColor)
                .background(.slideBackgroundColor)
            FlutterView(type: .piano)
                .frame(height: 350)
            Text("SwiftUIのPianoUI")
                .font(.smallFont)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundStyle(.defaultForegroundColor)
                .background(.slideBackgroundColor)
            PianoView()
                .frame(height: 350)
        }
        .foregroundStyle(.defaultForegroundColor)
        .background(.slideBackgroundColor)
    }
}

#Preview {
    SlidePreview {
        PianoSlide()
    }
}

