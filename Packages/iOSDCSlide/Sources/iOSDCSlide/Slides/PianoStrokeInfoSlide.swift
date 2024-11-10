//
//  PianoStrokeInfoSlide.swift
//  iOSDC2024Slide
//
//  Created by yugo.sugiyama on 2024/08/03.
//

import SwiftUI
import SlideKit
import PianoUI
import SlidysCore

@Slide
struct PianoStrokeInfoSlide: View {
//    @Phase var phase: SlidePhase
    @State var phase: SlidePhase = .twoThree

    enum SlidePhase: Int, PhasedState {
        case initial
        case two
        case twoOne
        case twoTwo
        case twoTwoOne
        case twoThree
    }

    var body: some View {
        HeaderSlide("ピアノ打鍵時に取得できる情報") {
            Item("タイムスタンプ", accessory: .number(1))
            if phase.isAfter(.two) {
                Item("データ(3Byte)", accessory: .number(2)) {
                    if phase.isAfter(.twoOne) {
                        Item("鍵盤を押した or 離した", accessory: .number(1))
                    }
                    if phase.isAfter(.twoTwo) {
                        Item("音の強さ", accessory: .number(2))
                    }
                    if phase.isAfter(.twoThree) {
                        Item("音名/弾いた鍵盤の位置(Note番号): 0~127の数字", accessory: .number(3)) {
                            if phase.isAfter(.twoTwoOne) {
                                Item("ピアノの中央の鍵盤(真ん中のド/第4オクターブのド/C4)→60", accessory: .number(1))
                            }
                        }
                        PianoView(pianoStrokes: [.init(key: .init(noteNumber: 60), velocity: 100, timestampNanoSecond: .now, isOn: true)])
                    }
                }
            }
        }
    }
}

#Preview {
    SlidePreview() {
        PianoStrokeInfoSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
