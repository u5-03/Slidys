//
//  Constants.swift
//  Slidys
//
//  Created by Yugo Sugiyama on 2024/10/27.
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
    static let mediumFont: Font = .system(size: 80, weight: .bold)
    static let smallFont: Font = .system(size: 60, weight: .bold)
    static let tinyFont: Font = .system(size: 36, weight: .bold)
}

extension ShapeStyle where Self == Color {
    static var defaultForegroundColor: Color { return .init(hex: "DDDDDD") }
    static var slideBackgroundColor: Color { return .init(hex: "383944") }
    static var strokeColor: Color { return .init(hex: "F48F23") }
    static var themeColor: Color { return .init(hex: "2388F4") }
}



