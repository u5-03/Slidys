//
//  SlideBaseView.swift
//
//
//  Created by Yugo Sugiyama on 2024/11/10.
//

import SwiftUI
import SlideKit

public protocol SlideConfigurationProtocol {
    var size: CGSize { get }
    var slideIndexController: SlideIndexController { get }
}

public extension SlideConfigurationProtocol {
    var size: CGSize {
        return SlideSize.standard16_9
    }
}

public struct SlideBaseView: View {
    var presentationContentView: some View {
        SlideRouterView(slideIndexController: slideConfiguration.slideIndexController)
            .slideTheme(slideTheme)
            .foregroundColor(.black)
            .background(.white)
    }

    public let slideConfiguration: SlideConfigurationProtocol
    public let slideTheme = CustomSlideTheme()

    public init(slideConfiguration: SlideConfigurationProtocol) {
        self.slideConfiguration = slideConfiguration
    }

    public var body: some View {
        PresentationView(slideSize: slideConfiguration.size) {
            GeometryReader { proxy in
                let circleHeight = proxy.size.height * 1.5
                ZStack {
                    presentationContentView
#if os(macOS)
                    // Toolbarに重ならないための仮対応
                        .padding(.top, 60)
#endif
                    Circle()
                        .frame(width: circleHeight, height: circleHeight)
                        .foregroundStyle(Color.black.opacity(0.01))
                        .position(x: 0, y: 0)
                        .onTapGesture {
                            slideConfiguration.slideIndexController.back()
                        }
                    Circle()
                        .frame(width: circleHeight, height: circleHeight)
                        .foregroundStyle(Color.black.opacity(0.01))
                        .position(x: proxy.size.width, y: 0)
                        .onTapGesture {
                            slideConfiguration.slideIndexController.forward()
                        }
                }
            }
        }
    }
}
