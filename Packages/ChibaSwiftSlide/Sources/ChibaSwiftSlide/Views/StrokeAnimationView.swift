//
//  StrokeAnimationView.swift
//  ChibaSwiftSlide
//
//  Created by Yugo Sugiyama on 2024/09/08.
//

import SwiftUI

struct StrokeAnimatableShape<S: Shape> {
    var animationProgress: CGFloat = 0
    let shape: S
}

extension StrokeAnimatableShape: Shape {
    var animatableData: CGFloat {
        get { animationProgress }
        set {
            if animationProgress >= 1.0 { return }
            animationProgress = newValue
        }
    }

    func path(in rect: CGRect) -> Path {
        return shape.path(in: rect)
            .trimmedPath(from: 0, to: animationProgress)
    }
}

struct StrokeAnimationShapeView<S: Shape>: View {
    let lineWidth: CGFloat
    let lineColor: Color
    let duration: Duration
    let shape: S
    let isPaused: Bool
    @State private var animationProgress: CGFloat = 0
    @State private var lastFrameDate: Date?

    init(
        shape: S,
        lineWidth: CGFloat = 1,
        lineColor: Color = .black,
        duration: Duration = .seconds(10),
        isPaused: Bool = false
    ) {
        self.lineWidth = lineWidth
        self.lineColor = lineColor
        self.duration = duration
        self.isPaused = isPaused
        self.shape = shape
    }

    var body: some View {
        TimelineView(.animation(paused: isPaused)) { context in
            StrokeAnimatableShape(
                animationProgress: animationProgress,
                shape: shape
            )
                .stroke(lineColor, lineWidth: lineWidth)
                .onChange(of: context.date) { oldValue, newValue in
                    if lastFrameDate == nil {
                        lastFrameDate = newValue
                    } else {
                        let deltaTime = newValue.timeIntervalSince(oldValue)
                        animationProgress += deltaTime / CGFloat(duration.components.seconds)
                    }
                }
                .onChange(of: isPaused) { oldValue, newValue in
                    lastFrameDate = nil
                }
        }
    }
}


#Preview {
    VStack {
        StrokeAnimationShapeView(
            shape: UhooiShape(),
            duration: .seconds(5),
            isPaused: false
        )
        .aspectRatio(1, contentMode: .fit)
        StrokeAnimationShapeView(
            shape: PeanutsShape(),
            duration: .seconds(5),
            isPaused: false
        )
        .aspectRatio(1, contentMode: .fit)
        StrokeAnimationShapeView(
            shape: ChibaShape(),
            duration: .seconds(5),
            isPaused: false
        )
        .aspectRatio(1, contentMode: .fit)
    }
}
