//
//  HowToUseSlide.swift
//
//
//  Created by Yugo Sugiyama on 2024/11/24.
//

import SwiftUI
import SlideKit

@Slide
public struct HowToUseSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    public init() {}

    public var body: some View {
        GeometryReader { proxy in
            let circleHeight = proxy.size.height * 1
            ZStack {
                ScrollView {
                    HeaderSlide("How to use this slide app") {
                        Item("Open slide you want to use", accessory: .number(1))
                        Item("How to proceed or return the slide", accessory: .number(2)) {
                            Item("In the case of a smartphone app, you can return or proceed with the slide by tapping the same area as the upper left and upper right circles of this page.", accessory: .number(1))
                            Item("In the case of macOS, you can operate by the key ← or →", accessory: .number(2))
                        }
                        Item("You can close by tapping the Close button on the upper right", accessory: .number(3))
                    }
                }
                Circle()
                    .frame(width: circleHeight, height: circleHeight)
                    .foregroundStyle(Color.black.opacity(0.1))
                    .position(x: 0, y: 0)
                Circle()
                    .frame(width: circleHeight, height: circleHeight)
                    .foregroundStyle(Color.black.opacity(0.1))
                    .position(x: proxy.size.width, y: 0)
            }
        }

    }
}

#Preview {
    SlidePreview {
        HowToUseSlide()
    }
}
