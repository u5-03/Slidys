//
//  MidiSlide.swift
//  iOSDC2024Slide
//
//  Created by yugo.sugiyama on 2024/08/03.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct MidiSlide: View {
    var body: some View {
        HeaderSlide("MIDI規格とは？") {
            Item("デバイスと電子ピアノなどの電子楽器間で音楽情報をやり取りするための規格", accessory: .number(1))
            Item("音の鳴り始めと終わり、音の強さ、音名などの情報をデジタルデータとして送受信", accessory: .number(2))
            Item("Apple PlatformではCore MIDIのframeworkを使って、利用することができる", accessory: .number(3)) {
                Item("今回はCore MIDIの3rd Party製のラッパーのMIDIKitというライブラリを使っています")
            }
        }
    }
}

#Preview {
    SlidePreview {
        MidiSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}

