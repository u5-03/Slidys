//
//  CopernicanTheoryView.swift
//  SlidysCore
//
//  Created by yugo.sugiyama on 2025/02/13.
//

import SwiftUI

enum Planet: CaseIterable {
    case mercury
    case venus
    case earth
    case mars
    case jupiter
    case saturn
}

extension Planet {
    /// 地球の公転周期を 1 とした場合の各惑星の公転周期比率
    var orbitalPeriod: CGFloat {
        switch self {
        case .mercury: return 0.24
        case .venus: return 0.62
        case .earth: return 1.0
        case .mars: return 1.88
        case .jupiter: return 11.86
        case .saturn: return 29.46
        }
    }

    /// 各惑星の英語名の頭文字
    var planetName: String {
        switch self {
        case .mercury: return "M"
        case .venus: return "V"
        case .earth: return "E"
        case .mars: return "M"
        case .jupiter: return "J"
        case .saturn: return "S"
        }
    }

    var planetColor: Color {
        switch self {
        case .mercury: return .blue
        case .venus: return .yellow
        case .earth: return .green
        case .mars: return .red
        case .jupiter: return .brown
        case .saturn: return .gray
        }
    }
}

struct CopernicanTheoryView: View {
    @State private var angle: Angle = .degrees(0)

    var body: some View {
        CopernicanTheoryChildView(angle: angle)
            .onAppear {
                withAnimation(Animation.linear(duration: 1000).repeatForever(autoreverses: false)) {
                    angle = .degrees(-360)
                }
            }

    }
}

struct CopernicanTheoryChildView: View {
    var angle: Angle

    var body: some View {
        GeometryReader { proxy in
            let length = min(proxy.size.width, proxy.size.height)
            ZStack(alignment: .center) {
                Circle()
                    .foregroundStyle(.red)
                    .overlay {
                        Text("S")
                            .foregroundStyle(.white)
                    }
                    .frame(width: length * 0.1, height: length * 0.1)
                ForEach(Array(Planet.allCases.enumerated()), id: \.element) { (index, planet) in
                    let orbitAngle = angle.degrees / planet.orbitalPeriod
                    let centerPoint = CGPoint(x: proxy.size.width / 2, y: proxy.size.height / 2)

                    let orbitRadius = length * 0.05 + (length * CGFloat(index + 1) * 0.07)
                    let planetWidth = length * 0.05

                    let point = CGPoint(
                        x: centerPoint.x + cos(orbitAngle) * orbitRadius,
                        y: centerPoint.y + sin(orbitAngle) * orbitRadius
                    )

                    Circle()
                        .stroke()
                        .frame(width: orbitRadius * 2, height: orbitRadius * 2)
                    Circle()
                        .fill(planet.planetColor)
                        .frame(width: planetWidth, height: planetWidth)
                        .position(.init(x: point.x, y: point.y))
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }
}

extension CopernicanTheoryChildView: Animatable {
    var animatableData: Angle.AnimatableData {
        get {
            angle.animatableData
        }
        set {
            angle.animatableData = newValue
        }
    }
}

#Preview {
    CopernicanTheoryView()
}
