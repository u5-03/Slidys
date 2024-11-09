//
//  PianoView.swift
//  Slidys
//
//  Created by Yugo Sugiyama on 2024/10/27.
//

import SwiftUI

public struct PianoLayout: Layout {
    let pianoKeys: [PianoKey]
    private let keyMargin: CGFloat = 1
    private let whiteKeyCount = KeyType.allCases.filter(\.isWhiteKey).count * Octave.allCases.count

    public func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Self.Subviews,
        cache: inout Self.Cache
    ) -> CGSize {
        let whiteKeyWidth = (proposal.height ?? 0) / AspectRatioConstants.whiteKeyAspectRatio.height * AspectRatioConstants.whiteKeyAspectRatio.width
        let width = whiteKeyWidth * CGFloat(whiteKeyCount) + CGFloat(whiteKeyCount - 1) * keyMargin
        return proposal.replacingUnspecifiedDimensions(by:
                .init(
                    width: width,
                    height: proposal.height ?? 0
                )
        )
    }

    // Assigns positions to each of the layout’s subviews.
    public func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Self.Subviews,
        cache: inout Self.Cache
    ) {
        guard !subviews.isEmpty else { return }
        let whiteKeyWidth = bounds.height / AspectRatioConstants.whiteKeyAspectRatio.height * AspectRatioConstants.whiteKeyAspectRatio.width
        let blackKeyWidth = whiteKeyWidth / AspectRatioConstants.whiteKeyAspectRatio.width * AspectRatioConstants.blackKeyAspectRatio.width

        // For some reason, the leading part is cut off from the screen by the width of the white keys * 0.5, so adjust it manually.
        var whiteKeyX: CGFloat = bounds.minX + whiteKeyWidth / 2
        subviews.indices.forEach { index in
            let pianoKey = pianoKeys[index]
            if pianoKey.isWhiteKey {
                // Place only if subview is within view range
                guard whiteKeyX + whiteKeyWidth > bounds.minX, whiteKeyX < bounds.maxX else { return }
                // Place subview
                subviews[index].place(
                    at: CGPoint(x: whiteKeyX, y: bounds.minY),
                    anchor: .top,
                    proposal: .init(
                        width: whiteKeyWidth,
                        height: whiteKeyWidth * AspectRatioConstants.whiteKeyAspectRatio.width * AspectRatioConstants.whiteKeyAspectRatio.height
                    )
                )
                // Shift the y coordinate by the height of the placed View
                whiteKeyX += whiteKeyWidth
                // Calculate the spacing between the next View and add it to the y coordinate
                let nextIndex = subviews.index(after: index)
                if nextIndex < subviews.endIndex {
                    whiteKeyX += keyMargin
                }
            } else {
                let blackKeyOffset = blackKeyWidth * pianoKey.keyType.keyOffsetRatio
                // For some reason, the leading part is cut off from the screen by the width of the white keys * 0.5, so adjust it manually by minus (whiteKeyWidth / 2) .
                let blackKeyX = whiteKeyX - whiteKeyWidth / 2 - (keyMargin / 2) - blackKeyWidth / 2 + blackKeyOffset
                // Place only if subview is within view range
                guard blackKeyX + blackKeyWidth > bounds.minX, blackKeyX < bounds.maxX else { return }
                subviews[index].place(
                    // Adjust the black keys by 0.5 more than the amount of the white keys that you adjusted manually.
                    at: CGPoint(x: blackKeyX, y: bounds.minY),
                    anchor: .topLeading,
                    proposal: .init(
                        width: blackKeyWidth,
                        height: nil // Calculate height by aspectRatio
                    )
                )
            }
        }
    }
}

public struct PianoView: View {
    private let pianoKeys = PianoKey.allCases

    public let pianoStrokes: [PianoKeyStroke]
    private let centerDisplayKey: PianoKey
    public let didTriggerKeyStrokeEvent: ((PianoKeyStroke) -> Void)?

    public init(pianoStrokes: [PianoKeyStroke] = [],
                centerDisplayKey: PianoKey = PianoKey(keyType: .c, octave: .fourth), didTriggerKeyStrokeEvent: ((PianoKeyStroke) -> Void)? = nil) {
        self.pianoStrokes = pianoStrokes
        self.centerDisplayKey = centerDisplayKey
        self.didTriggerKeyStrokeEvent = didTriggerKeyStrokeEvent
    }

    public var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                PianoLayout(pianoKeys: pianoKeys) {
                    ForEach(pianoKeys) { pianoKey in
                        if pianoKey.keyType.isWhiteKey {
                            PianoKeyView.White(
                                pianoKey: pianoKey,
                                keyStrokedType: pianoStrokes.first(where: { $0.noteNumber == pianoKey.noteNumber })?.asKeyStrokedType ?? .unstroked,
                                didTriggerKeyStrokeEvent: { keyStroke in
                                    didTriggerKeyStrokeEvent?(keyStroke)
                                }
                            )
                            .shadow(radius: 2)
                            .id(pianoKey)
                        } else {
                            PianoKeyView.Black(
                                pianoKey: pianoKey,
                                keyStrokedType: pianoStrokes.first(where: { $0.noteNumber == pianoKey.noteNumber })?.asKeyStrokedType ?? .unstroked,
                                didTriggerKeyStrokeEvent: { keyStroke in
                                    didTriggerKeyStrokeEvent?(keyStroke)
                                }
                            )
                            .shadow(radius: 10)
                            .zIndex(1)
                        }
                    }
                }
            }
            .ignoresSafeArea(edges: .horizontal)
            .onAppear {
                proxy.scrollTo(
                    centerDisplayKey,
                    anchor: .center
                )
            }
        }
    }
}


#Preview {
    PianoView(
        pianoStrokes: [
            .init(key: .init(keyType: .c, octave: .fourth), velocity: PianoKeyStroke.minVelocity, timestampNanoSecond: .now, isOn: true),
            .init(key: .init(keyType: .cSharp, octave: .fourth), velocity: 10, timestampNanoSecond: .now, isOn: true),
            .init(key: .init(keyType: .d, octave: .fourth), velocity: 30, timestampNanoSecond: .now, isOn: true),
            .init(key: .init(keyType: .dSharp, octave: .fourth), velocity: 50, timestampNanoSecond: .now, isOn: true),
            .init(key: .init(keyType: .e, octave: .fourth), velocity: 70, timestampNanoSecond: .now, isOn: true),
            .init(key: .init(keyType: .f, octave: .fourth), velocity: 90, timestampNanoSecond: .now, isOn: true),
            .init(key: .init(keyType: .fSharp, octave: .fourth), velocity: 110, timestampNanoSecond: .now, isOn: true),
            .init(key: .init(keyType: .g, octave: .fourth), velocity: PianoKeyStroke.maxVelocity, timestampNanoSecond: .now, isOn: true),
        ]
    )
}


