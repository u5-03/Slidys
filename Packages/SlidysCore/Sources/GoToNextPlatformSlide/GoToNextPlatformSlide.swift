//
//  GoToNextPlatformSlide.swift
//  SlidysCore
//
//  Created by Yugo Sugiyama on 2025/03/01.
//

import SwiftUI
import SlideKit
import SlidesCore
import SymbolKit

public struct GoToNextPlatformSlideView: SlideViewProtocol {
    let configuration = SlideConfiguration()

    public init() {}

    public var body: some View {
        SlideBaseView(slideConfiguration: configuration)
    }
}

struct SlideConfiguration: SlideConfigurationProtocol {
    let slideIndexController = SlideIndexController() {
        CenterTextSlide(text: "突撃！隣のモバイルプラットフォーム！")
        ContentSlide(headerTitle: "1問目") {
                TodoListView()
//                    .frame(height: proxy.size.height)
                    .aspectRatio(QuizViewSlide.verticalAspectRatio, contentMode: .fit)
        }
        ContentSlide(headerTitle: "2問目") {
            DataChartView()
                .aspectRatio(QuizViewSlide.horizontalAspectRatio, contentMode: .fit)
        }
        ContentSlide(headerTitle: "3問目") {
            AppEventView()
                .aspectRatio(QuizViewSlide.horizontalAspectRatio, contentMode: .fit)
        }
        ContentSlide(headerTitle: "4問目") {
            GeometryReader { proxy in
                SolarSystemView()
                    .frame(width: proxy.size.width)
                    .aspectRatio(QuizViewSlide.verticalAspectRatio, contentMode: .fit)
            }
        }
        QuizViewSlide()
    }
}
