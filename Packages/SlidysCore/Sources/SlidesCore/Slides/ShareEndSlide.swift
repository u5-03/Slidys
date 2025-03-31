//
//  ContentSlide.swift
//  SlidysCore
//
//  Created by Yugo Sugiyama on 2025/03/01.
//

import SwiftUI
import SlideKit

@Slide
public struct ShareEndSlide: View {

    public init() {}

    public var body: some View {
        HeaderSlide(.init("You can download this slide app from TestFlight")) {
            VStack {
                Image(.qrCode)
                    .resizable()
                    .scaledToFit()
                HStack(spacing: 0) {
                    Text("This app depends on ")
                        .font(.smallFont)
                    Text("[SlideKit](https://github.com/mtj0928/SlideKit)")
                        .font(.smallFont)
                    Text("🦌")
                        .font(.smallFont)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}

#Preview {
    ShareEndSlide()
        .headerSlideStyle(CustomHeaderSlideStyle())
        .itemStyle(CustomItemStyle())
}
