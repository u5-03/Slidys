//
//  FlutterKaigiSlideView.swift
//  Slidys
//
//  Created by Yugo Sugiyama on 2024/11/10.
//

import SwiftUI
import SlideKit

public struct FlutterKaigiSlideView: View {
    static let configuration = SlideConfiguration()

    var presentationContentView: some View {
        SlideRouterView(slideIndexController: Self.configuration.slideIndexController)
            .slideTheme(Self.configuration.theme)
            .foregroundColor(.black)
            .background(.white)
    }

    public init() {}

    public var body: some View {
        PresentationView(slideSize: Self.configuration.size) {
            ZStack {
                presentationContentView
                HStack(spacing: 0) {
                    Rectangle()
                        .foregroundStyle(Color.black.opacity(0.01))
                        .simultaneousGesture(
                            TapGesture()
                                .onEnded { _ in
                                    Self.configuration.slideIndexController.back()
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
                                    Self.configuration.slideIndexController.forward()
                                }
                        )
                }
            }
        }
    }
}
