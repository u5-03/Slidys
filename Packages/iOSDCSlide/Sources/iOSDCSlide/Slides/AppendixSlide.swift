//
//  AppendixSlide.swift
//  iOSDC2024Slide
//
//  Created by Yugo Sugiyama on 2024/08/06.
//

import SwiftUI
import SlideKit
import SlidysCore

@Slide
struct AppendixSlide: View {
    var body: some View {
        HeaderSlide("さきほど↓の補足で...") {
            Item("「この電子ピアノは追加のアダプターを購入すれば、BluetoothでのMIDI通信も実現できます。」")
            Item("とありました")
            HStack(alignment: .center) {
                Spacer()
                Image(.newPiano)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                Spacer()
            }
        }
    }
}

#Preview {
    SlidePreview {
        AppendixSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
