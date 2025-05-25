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
    @State private var slideIndexController: SlideIndexController
    public let slideTheme = CustomSlideTheme()

    public init(slideConfiguration: SlideConfigurationProtocol) {
        self.slideConfiguration = slideConfiguration
        slideIndexController = slideConfiguration.slideIndexController
    }

    public var body: some View {
        NavigationStack {
            PresentationView(slideSize: slideConfiguration.size) {
                GeometryReader { proxy in
                    let circleHeight = proxy.size.height * 1
                    ZStack {
                        presentationContentView
                            .frame(maxHeight: .infinity)
#if !os(visionOS)
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
#endif
                    }
                }
            }
#if os(visionOS)
            .toolbar {
                ToolbarItem(placement: .bottomOrnament) {
                    HStack(alignment: .center) {
                        Button {
                            slideIndexController.back()
                        } label: {
                            Image(systemName: "chevron.left")
                        }
//                        .disabled(slideIndexController.currentIndex == 0)

                        Text("\(slideIndexController.currentIndex + 1)/\(slideIndexController.slides.count)")
                            .font(.largeTitle)

                        Button {
                            slideIndexController.forward()
                        } label: {
                            Image(systemName: "chevron.right")
                        }
                        .disabled(slideIndexController.currentIndex == slideIndexController.slides.count - 1)
                    }
                }
            }
#endif
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
