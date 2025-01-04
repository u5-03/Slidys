//
//  CircleMusicNoteView.swift
//  iOSDC2024Slide
//
//  Created by Yugo Sugiyama on 2024/08/12.
//

import SwiftUI
import PianoUI

// Ref: https://swiftui-lab.com/layout-protocol-part-2/
struct MusicNoteInfo {
    let keyType: KeyType
    let velocity: Int

    var displayScale: Double {
        return 1.0 + (Double(velocity) - 1.0) / 99.0
    }
}

struct Rotation: LayoutValueKey {
    static let defaultValue: Binding<Angle>? = nil
}

struct MusicNoteView: View {
    let color: Color
    let musicNoteInfos: [MusicNoteInfo]
    @State private var rotation: Angle = .zero

    var body: some View {
        Image(.musicNote)
            .renderingMode(.template)
            .resizable()
            .foregroundStyle(color)
            .aspectRatio(1, contentMode: .fit)
            .rotationEffect(rotation)
            .layoutValue(key: Rotation.self, value: $rotation)
    }
}

struct CircleMusicAnimatedNoteView: View {
    static let interval: TimeInterval = 0.3
    private let startDate = Date()
    let radius: CGFloat
    let musicNoteSize: CGSize
    let animation: Animation?
    let keyStrokes: [[PianoKeyStroke]]
    
    init(radius: CGFloat = 100, musicNoteSize: CGSize = .init(width: 50, height: 50), animation: Animation? = .easeInOut(duration: CircleMusicAnimatedNoteView.interval), keyStrokes: [[PianoKeyStroke]] = []) {
        self.radius = radius
        self.musicNoteSize = musicNoteSize
        self.animation = animation
        self.keyStrokes = keyStrokes
    }

    var body: some View {
        TimelineView(.periodic(from: startDate, by: CircleMusicAnimatedNoteView.interval)) { context in
            let elapsed = context.date.timeIntervalSince(startDate)
            let index = Int(elapsed / CircleMusicAnimatedNoteView.interval) % keyStrokes.count
            let keyStrokes = keyStrokes[index]
            let musicInfos = keyStrokes.map({ MusicNoteInfo(keyType: $0.key.keyType, velocity: $0.velocity) })
            CircleMusicNoteView(radius: radius, musicNoteSize: musicNoteSize, animation: animation, musicNoteInfos: musicInfos)
        }
    }
}

struct CircleMusicNoteView: View {
    @State private var rotatedAngle: Angle = .zero
    let radius: CGFloat
    let musicNoteSize: CGSize
    let animation: Animation?
    let musicNoteInfos: [MusicNoteInfo]
    let keyTypes = KeyType.allCases
    let singleAngle: Angle
    let angleStep: Int
    let shouldPointToCenter: Bool

    init(radius: CGFloat = 100, musicNoteSize: CGSize = .init(width: 50, height: 50), animation: Animation? = nil, musicNoteInfos: [MusicNoteInfo], shouldPointToCenter: Bool = true) {
        self.radius = radius
        self.musicNoteSize = musicNoteSize
        self.animation = animation
        self.musicNoteInfos = musicNoteInfos
        self.shouldPointToCenter = shouldPointToCenter
        singleAngle = .degrees(360 / Double(keyTypes.count))
        angleStep = Int(Angle.degrees(360).degrees / singleAngle.degrees)
    }

    var body: some View {
        ZStack {
            RotatingCircleLayout(radius: radius, rotatedAngle: rotatedAngle, shouldPointToCenter: true) {
                ForEach(KeyType.allCases) { keyType in
                    MusicNoteView(color: keyType.color, musicNoteInfos: musicNoteInfos)
                        .frame(width: musicNoteSize.width)
                        .animation(.easeInOut, body: { view in
                            view
                                .scaleEffect(
                                    .init(
                                        musicNoteInfos
                                            .first(where: {
                                                $0.keyType == keyType
                                            })?.displayScale ?? 1
                                    )
                                )
                        })
                        .rotationEffect(shouldPointToCenter ? singleAngle * CGFloat(keyType.keyIndex) + rotatedAngle : .degrees(0))
                }
            }
            .onAppear {
                withAnimation(.linear(duration: 10.0).repeatForever(autoreverses: false)) {
                    rotatedAngle = .degrees(-360)
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

struct RotatingCircleLayout: Layout {
    var radius: CGFloat
    var rotatedAngle: Angle
    let shouldPointToCenter: Bool
    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get {
            AnimatablePair(rotatedAngle.radians, radius)
        }
        set {
            rotatedAngle = Angle.radians(newValue.first)
            radius = newValue.second
        }
    }

    init(radius: CGFloat, rotatedAngle: Angle, shouldPointToCenter: Bool = false) {
        self.radius = radius
        self.rotatedAngle = rotatedAngle
        self.shouldPointToCenter = shouldPointToCenter
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        // 円形の直径を計算
        let maxDimension = subviews.reduce(0) { max($0, max($1.sizeThatFits(proposal).width, $1.sizeThatFits(proposal).height)) }
        return CGSize(width: maxDimension * 2, height: maxDimension * 2)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        let singleAngle = (Angle.degrees(360).radians / Double(subviews.count))

        for (index, subview) in subviews.enumerated() {
            let angle = singleAngle * CGFloat(index) + rotatedAngle.radians

            // Find a vector with an appropriate size and rotation.
            var point = CGPoint(x: 0, y: -radius).applying(CGAffineTransform(rotationAngle: angle))

            // Shift the vector to the middle of the region.
            point.x += bounds.midX
            point.y += bounds.midY

            // Place the subview.
            subview.place(at: point, anchor: .center, proposal: .unspecified)
        }
    }
}


#Preview {
    CircleMusicAnimatedNoteView(
        radius: 170,
        keyStrokes: KeyTemplate.allKeyTypes
    )
        .frame(width: 500, height: 500)
        .background(.black)
}

extension KeyType {
    var color: Color {
        switch self {
        case .c: return Color(hex: "E31E1D")
        case .cSharp: return Color(hex: "B11B36")
        case .d: return Color(hex: "DAB21B")
        case .dSharp: return Color(hex: "8CAE4E")
        case .e: return Color(hex: "3DA933")
        case .f: return Color(hex: "BB823F")
        case .fSharp: return Color(hex: "D05C2E")
        case .g: return Color(hex: "00ADD1")
        case .gSharp: return Color(hex: "2784B5")
        case .a: return Color(hex: "B34273")
        case .aSharp: return Color(hex: "916A98")
        case .b: return Color(hex: "DAA3AF")
        }
    }
}
