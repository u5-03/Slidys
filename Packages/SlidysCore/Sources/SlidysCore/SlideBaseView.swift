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
            ZStack {
                presentationContentView
                HStack(spacing: 0) {
                    Rectangle()
                        .foregroundStyle(Color.black.opacity(0.01))
                        .simultaneousGesture(
                            TapGesture()
                                .onEnded { _ in
                                    slideConfiguration.slideIndexController.back()
                                }
                        )
                    Color.clear
                        .containerRelativeFrame(.horizontal) { length, _ in
                            return length * 0.8
                        }
                    Rectangle()
                        .foregroundStyle(Color.black.opacity(0.01))
                        .simultaneousGesture(
                            TapGesture()
                                .onEnded { _ in
                                    slideConfiguration.slideIndexController.forward()
                                }
                        )
                }
            }
        }
    }
}
