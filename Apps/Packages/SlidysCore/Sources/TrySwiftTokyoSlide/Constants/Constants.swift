//
//  Created by yugo.sugiyama on 2025/03/28
//  Copyright ©Sugiy All rights reserved.
//

import Foundation

enum Constants {
    static let strokeAnimatableShapeCodeCode = """
struct StrokeAnimatableShape {
    var animationProgress: CGFloat = 0
    let shape: any Shape
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
struct StrokeAnimationShapeView: View {
    @State private var animationProgress: CGFloat = 0
...
    let shape: any Shape
...
    var body: some View {
        StrokeAnimatableShape(
            animationProgress: viewModel.animationProgress,
            shape: shape
        )
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
