//
//  PianoViewStructureSlide.swift
//  iOSDC2024Slide
//
//  Created by Yugo Sugiyama on 2024/08/06.
//

import SwiftUI
import SlideKit
import PianoUI
import SlidesCore

@Slide
struct PianoViewStructureSlide: View {
    var body: some View {
        HeaderSlide("ピアノUIの仕組み") {
            Item("PianoKeyView", accessory: .number(1)) {
                Item("White(白鍵盤)", accessory: .number(1))
                Item("Black(黒鍵盤)", accessory: .number(2))
            }
            Item("Layout Protocolを使用し、白黒の2種類のPianoKeyViewを並べ、PianoViewを実装", accessory: .number(2))
            PianoView(pianoStrokes: [])
                .frame(height: 270)
        }
    }
}

#Preview {
    SlidePreview {
        PianoViewStructureSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
