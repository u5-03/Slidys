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
    @FocusState private var isFocused: Bool

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
                let circleHeight = proxy.size.height * 1
                ZStack {
                    presentationContentView
                        .frame(maxHeight: .infinity)
                    Circle()
                        .frame(width: circleHeight, height: circleHeight)
                        .foregroundStyle(Color.black.opacity(0.01))
                        .position(x: 0, y: 0)
                        .onTapGesture {
                            // SymbolQuizのViewなどでFocusが移動した時に、再度Focusを有効にする処理
                            isFocused = true
                            Task {
                                slideConfiguration.slideIndexController.back()
                            }
                        }
                    Circle()
                        .frame(width: circleHeight, height: circleHeight)
                        .foregroundStyle(Color.black.opacity(0.01))
                        .position(x: proxy.size.width, y: 0)
                        .onTapGesture {
                            isFocused = true
                            Task {
                                slideConfiguration.slideIndexController.forward()
                            }
                        }
                }
            }
        }
#if os(macOS)
        .focusable()
        .focused($isFocused)
        .focusEffectDisabled()
        .onKeyPress(.leftArrow) {
            isFocused = true
            Task {
                slideConfiguration.slideIndexController.back()
            }
            return .handled
        }
        .onKeyPress(.rightArrow) {
            isFocused = true
            Task {
                slideConfiguration.slideIndexController.forward()
            }
            return .handled
        }
#endif
    }
}
