//
//  MarkStrokeAnimation.swift
//  KanagawaSwiftSlide
//
//  Created by Yugo Sugiyama on 2024/09/22.
//

import SwiftUI
import SymbolKit

struct PathAnimatableShape {
    var fromAnimationProgress: CGFloat = 0
    var toAnimationProgress: CGFloat = 0
    let shape: any Shape
}

extension PathAnimatableShape: Shape {
    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get {
            return AnimatablePair(fromAnimationProgress, toAnimationProgress)
        }
        set {
            fromAnimationProgress = newValue.first
            toAnimationProgress = newValue.second
        }
    }

    func path(in rect: CGRect) -> Path {
        return shape.path(in: rect)
            .trimmedPath(
                from: fromAnimationProgress,
                to: toAnimationProgress
            )
    }
}

enum PathAnimationPhase: CaseIterable {
    case move // 0->0.1, 0.1 move, 0.1->0
    case moveReversed
    case fill

    static let startFragmentRatio = -pathFragmentRatio
    private static let pathFragmentRatio = 0.1

    var duration: TimeInterval {
        return 1.5
    }

    var animation: Animation {
        return .easeInOut(duration: duration).delay(0.1)
    }

    var nextPhase: PathAnimationPhase? {
        guard let index = PathAnimationPhase.allCases.firstIndex(where: { $0 == self }), index + 1 <= PathAnimationPhase.allCases.count - 1 else { return nil }
        return PathAnimationPhase.allCases[index + 1]
    }

    var defaultFromAnimationProgress: CGFloat {
        switch self {
        case .move: return -Self.pathFragmentRatio
        case .moveReversed: return 1
        case .fill: return 0
        }
    }

    var DefaultToAnimationProgress: CGFloat {
        switch self {
        case .move: return 0
        case .moveReversed: return 1 + Self.pathFragmentRatio
        case .fill: return 0
        }
    }

    var fromAnimationProgress: CGFloat {
        switch self {
        case .move: return 1
        case .moveReversed: return -Self.pathFragmentRatio
        case .fill: return 0
        }
    }

    var toAnimationProgress: CGFloat {
        switch self {
        case .move: return 1 + Self.pathFragmentRatio
        case .moveReversed: return 0
        case .fill: return 1
        }
    }
}

struct PathAnimationShapeView: View {
    let lineWidth: CGFloat
    let lineColor: Color
    let duration: Duration
    let shape: any Shape
    let isPaused: Bool
    @State private var fromAnimationProgress: CGFloat = PathAnimationPhase.startFragmentRatio
    @State private var toAnimationProgress: CGFloat = 0
    @State private var lastFrameDate: Date?

    init(
        shape: any Shape,
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

    func animate(phase: PathAnimationPhase) {
        fromAnimationProgress = phase.defaultFromAnimationProgress
        toAnimationProgress = phase.DefaultToAnimationProgress
        withAnimation(phase.animation) {
            fromAnimationProgress = phase.fromAnimationProgress
            toAnimationProgress = phase.toAnimationProgress
        } completion: {
            if let nextPhase = phase.nextPhase {
                animate(phase: nextPhase)
            }
        }
    }

    var body: some View {
        ZStack {
            PathAnimatableShape(
                fromAnimationProgress: 0,
                toAnimationProgress: 1,
                shape: shape
            )
                .stroke(Color(.darkGray), style: .init(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
            PathAnimatableShape(
                fromAnimationProgress: fromAnimationProgress,
                toAnimationProgress: toAnimationProgress,
                shape: shape
            )
            .stroke(lineColor, style: .init(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
        }
        .padding()
        .background(.black)
        .onAppear {
            animate(phase: .move)
        }
    }
}


#Preview {
    VStack {
        PathAnimationShapeView(
            shape: SugiyShape(),
            lineWidth: 30,
            lineColor: .white,
            duration: .seconds(5),
            isPaused: false
        )
        .aspectRatio(1, contentMode: .fit)
        .padding()
    }
}
