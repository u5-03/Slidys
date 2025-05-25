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
    private let qrCodeType: QrCodeType

    public init(qrCodeType: QrCodeType) {
        self.qrCodeType = qrCodeType
    }

    public var body: some View {
        HeaderSlide(.init("You can download this slide app from TestFlight")) {
            VStack {
                qrCodeType.view
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
    ShareEndSlide(qrCodeType: .native)
        .headerSlideStyle(CustomHeaderSlideStyle())
        .itemStyle(CustomItemStyle())
    ShareEndSlide(qrCodeType: .flutter)
        .headerSlideStyle(CustomHeaderSlideStyle())
        .itemStyle(CustomItemStyle())
    ShareEndSlide(qrCodeType: .all)
        .headerSlideStyle(CustomHeaderSlideStyle())
        .itemStyle(CustomItemStyle())
}
