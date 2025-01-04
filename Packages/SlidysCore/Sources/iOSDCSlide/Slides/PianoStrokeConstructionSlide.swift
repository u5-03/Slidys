//
//  PianoStrokeConstructionSlide.swift
//  iOSDC2024Slide
//
//  Created by yugo.sugiyama on 2024/08/03.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct PianoStrokeConstructionSlide: View {
    var body: some View {
        HeaderSlide("音楽情報(PianoKeyStroke)の実装") {
            Item("key: PianoKey(Struct)", accessory: .number(1)) {
                Item("keyType: KeyType(enum)", accessory: .number(1)) {
                    Item("C(ド)~B(シ)", accessory: .number(1))
                }
                Item("octave: Octave(enum)", accessory: .number(2)) {
                    Item("第-1~第9オクターブ", accessory: .number(1))
                }
            }
            Item("velocity: Double(音の強さ)", accessory: .number(2))
            Item("timestamp: Date", accessory: .number(3))
            Item("isOn: Bool(鍵盤を押している or 離している)", accessory: .number(4))
        }
    }
}

#Preview {
    SlidePreview {
        PianoStrokeConstructionSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
