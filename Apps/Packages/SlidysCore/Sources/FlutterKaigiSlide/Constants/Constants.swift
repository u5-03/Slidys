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
