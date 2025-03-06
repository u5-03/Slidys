//
//  QuizViewSlide.swift
//  SlidysCore
//
//  Created by yugo.sugiyama on 2025/02/20.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct QuizViewSlide: View {
    static let verticalAspectRatio: CGFloat = 9 / 16
    static let horizontalAspectRatio: CGFloat = 16.0 / 9

    var body: some View {
        GeometryReader { proxy in
            HStack(spacing: 0) {
                TodoListView()
                    .frame(width: proxy.size.width * 0.25)
                    .aspectRatio(QuizViewSlide.verticalAspectRatio, contentMode: .fit)
                VStack(spacing: 0) {
                    AppEventView()
                        .frame(width: proxy.size.width * 0.5, height: proxy.size.height * 0.4)
                        .aspectRatio(QuizViewSlide.horizontalAspectRatio, contentMode: .fit)
                    Spacer()
                    DataChartView()
                        .stroked(color: .black)
                        .frame(width: proxy.size.width * 0.5, height: proxy.size.height * 0.4)
                        .aspectRatio(QuizViewSlide.horizontalAspectRatio, contentMode: .fit)
                }
                .frame(width: proxy.size.width * 0.5, height: proxy.size.height)
                SolarSystemView()
                    .frame(width: proxy.size.width * 0.25)
                    .aspectRatio(QuizViewSlide.verticalAspectRatio, contentMode: .fit)
            }
            .frame(height: proxy.size.height)
        }
        .background(.slideBackgroundColor)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    SlidePreview {
        QuizViewSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
