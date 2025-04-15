//
//  TitleSlide.swift
//  iOSDC2024Slide
//
//  Created by Yugo Sugiyama on 2024/08/01.
//

import SwiftUI
import SlideKit
import PianoUI
import SlidesCore
import SymbolKit

@Slide
struct TitleSlide: View {
    private let title = "Blurってなに？"
    private let dateString = "2025/04/26"
    private let eventName = "Nagoya.swift#1"
    private let authorName = "Sugiy/すぎー"
    private let interval: TimeInterval = 0.2
    private let startDate = Date()

    var body: some View {
        VStack(spacing: 0) {
            Text(title)
                .font(.system(size: 160, weight: .heavy))
                .minimumScaleFactor(0.1)
                .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(.themeColor)
            Spacer()
                .frame(height: 28)
            VStack(alignment: .trailing, spacing: 32) {
                HStack(spacing: 20) {
                    Spacer()
                    Text(dateString)
                        .font(.system(size: 80, weight: .heavy))
                        .frame(alignment: .trailing)
                    Text(eventName)
                        .font(.system(size: 80, weight: .heavy))
                        .frame(alignment: .trailing)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.leading)
                HStack(alignment: .top, spacing: 20) {
                    StrokeAnimationShapeView(
                        shape: SugiyShape(),
                        lineWidth: 6,
                        lineColor: .strokeColor,
                        duration: .seconds(4),
                        shapeAspectRatio: SugiyShape.aspectRatio,
                        viewModel: .init(animationType: .progressiveDraw)
                    )
                    .padding()
                    Spacer()
                    Text(authorName)
                        .font(.system(size: 100, weight: .heavy))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    Image(.icon)
                        .resizable()
                        .frame(width: 160, height: 160)
                        .aspectRatio(contentMode: .fit)
                        .clipShape(Circle())
                }
            }
        }
        .frame(maxHeight: .infinity)
        .padding(80)
        .background(.slideBackgroundColor)
        .foregroundColor(.defaultForegroundColor)
    }

    var shouldHideIndex: Bool { true }
}

#Preview {
    SlidePreview {
        TitleSlide()
    }
}
