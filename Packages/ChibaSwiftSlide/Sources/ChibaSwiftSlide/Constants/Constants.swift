//
//  Constants.swift
//  ChibaSwiftSlide
//
//  Created by Yugo Sugiyama on 2024/09/08.
//

import SwiftUI

enum Constants {
    static let presentationName = "iOSDCのスライドで使ったアニメーションを深掘る"
    static let strokeAnimatableShapeCodeCode = """
struct StrokeAnimatableShape<S: Shape> {
    var animationProgress: CGFloat = 0
    let shape: S
}

extension StrokeAnimatableShape: Shape {
    var animatableData: CGFloat {
        get { animationProgress }
        set { animationProgress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        return shape.path(in: rect)
            .trimmedPath(from: 0, to: animationProgress)
    }
} 
"""
    static let strokeAnimationShapeViewCode = """
struct StrokeAnimationShapeView<S: Shape>: View {
    @State private var animationProgress: CGFloat = 0
...
    let shape: S
...
    var body: some View {
        StrokeAnimatableShape(shape: shape)
            .stroke(lineColor, lineWidth: lineWidth)
                .onAppear {
                    withAnimation(.linear(duration: seconds)) {
                        strokeAnimatableShape.animatableData = 1.0
                    }
                }
    }
}
"""
}

extension Font {
    static let extraLargeFont: Font = .system(size: 140, weight: .bold)
    static let largeFont: Font = .system(size: 100, weight: .bold)
    static let midiumFont: Font = .system(size: 80, weight: .bold)
}

extension ShapeStyle where Self == Color {
    static var defaultForegroundColor: Color { return .init(hex: "DDDDDD") }
    static var slideBackgroundColor: Color { return .init(hex: "383944") }
    static var strokeColor: Color { return .init(hex: "F48F23") }
    static var themeColor: Color { return .init(hex: "2388F4") }
}


