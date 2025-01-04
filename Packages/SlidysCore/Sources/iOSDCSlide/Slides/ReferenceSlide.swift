//
//  ReferenceSlide.swift
//  iOSDC2024Slide
//
//  Created by Yugo Sugiyama on 2024/08/09.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct ReferenceSlide: View {
    var body: some View {
        HeaderSlide("参考資料") {
            Item("Core Midi", accessory: .number(1)) {
                Item("https://developer.apple.com/documentation/coremidi/")
            }
            Item("MidiKit", accessory: .number(2)) {
                Item("https://github.com/orchetect/MIDIKit")
            }
            Item("MIDIKit online documentation", accessory: .number(3)) {
                Item("https://orchetect.github.io/MIDIKit/documentation/midikit/")
            }
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

