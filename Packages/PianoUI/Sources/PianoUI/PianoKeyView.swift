//
//  PianoKeyView.swift
//  Slidys
//
//  Created by Yugo Sugiyama on 2024/10/27.
//

import SwiftUI

enum PianoKeyView {
    static let keyCornerRadius: CGFloat = 4
    static let strokeSleepDuration: Duration = .milliseconds(100)
    struct White: View {
        let pianoKey: PianoKey
        let keyStrokedType: KeyStrokedType
        let didTriggerKeyStrokeEvent: ((PianoKeyStroke) -> Void)?
        @AppStorage(UserDefaultsKey.defaultStrokeVelocity.rawValue)
        private var defaultStrokeVelocity = UserDefaults.standard.defaultStrokeVelocity
        @AppStorage(UserDefaultsKey.soundScaleUnit.rawValue)
        private var selectedKeyDisplayType = UserDefaults.standard.keyDisplayType
        @AppStorage(UserDefaultsKey.selectedThemeColor.rawValue)
        private var selectedThemeColor = UserDefaults.standard.selectedThemeColor
        @AppStorage(UserDefaultsKey.shouldShowSoundKey.rawValue)
        private var shouldShowSoundKey = UserDefaults.standard.shouldShowSoundKey
        @State private var isStroked = false

        init(pianoKey: PianoKey, keyStrokedType: KeyStrokedType, didTriggerKeyStrokeEvent: ((PianoKeyStroke) -> Void)? = nil) {
            self.pianoKey = pianoKey
            self.keyStrokedType = keyStrokedType
            self.didTriggerKeyStrokeEvent = didTriggerKeyStrokeEvent
        }

        var body: some View {
            ZStack(alignment: .bottom) {
                UnevenRoundedRectangle(
                    cornerRadii: .init(
                        bottomLeading: PianoKeyView.keyCornerRadius,
                        bottomTrailing: PianoKeyView.keyCornerRadius
                    ),
                    style: .circular
                )
                .fill(.white)
                .clipped()
                .id(pianoKey)
                if keyStrokedType.isStroked {
                    selectedThemeColor
                        .opacity(Double(keyStrokedType.velocityPercent) / 100)
                        .clipShape(
                            UnevenRoundedRectangle(
                                cornerRadii: .init(
                                    bottomLeading: PianoKeyView.keyCornerRadius,
                                    bottomTrailing: PianoKeyView.keyCornerRadius
                                ),
                                style: .circular
                            )
                        )
                }
                if isStroked {
                    selectedThemeColor
                        .opacity(Double(defaultStrokeVelocity) / 100)
                        .clipShape(
                            UnevenRoundedRectangle(
                                cornerRadii: .init(
                                    bottomLeading: PianoKeyView.keyCornerRadius,
                                    bottomTrailing: PianoKeyView.keyCornerRadius
                                ),
                                style: .circular
                            )
                        )
                }
                VStack {
//                    if shouldShowSoundKey {
                        Text(pianoKey.keyDisplayValue(keyDisplayType: selectedKeyDisplayType))
                            .lineLimit(1)
                            .foregroundStyle(.gray)
                            .minimumScaleFactor(0.02)
                            .padding([.bottom, .horizontal], 4)
//                    } else if pianoKey.isC {
//                        Text(pianoKey.keyDisplayValue(keyDisplayType: selectedKeyDisplayType))
//                            .lineLimit(1)
//                            .foregroundStyle(.gray)
//                            .minimumScaleFactor(0.02)
//                            .padding([.bottom, .horizontal], 4)
//                    }
                }
            }
            .aspectRatio(AspectRatioConstants.whiteKeyAspectRatio, contentMode: .fit)
#if os(visionOS)
            .onTapGesture {
                Task {
                    didTriggerKeyStrokeEvent?(
                        .init(
                            key: pianoKey,
                            velocity: UserDefaults.standard.defaultStrokeVelocity,
                            timestampNanoSecond: .now,
                            isOn: true
                        )
                    )
                    isStroked = true
                    try? await Task.sleep(for: strokeSleepDuration)
                    didTriggerKeyStrokeEvent?(
                        .init(
                            key: pianoKey,
                            velocity: UserDefaults.standard.defaultStrokeVelocity,
                            timestampNanoSecond: .now,
                            isOn: false
                        )
                    )
                    isStroked = false
                }
            }
            .hoverEffect { effect, isActive, _ in
                effect.opacity(isActive ? 0.9 : 1)
            }
#else
//            .simultaneousGesture(
//                DragGesture(minimumDistance: 0)
//                    .onChanged({ _ in
//                        didTriggerKeyStrokeEvent?(
//                            .init(
//                                key: pianoKey,
//                                velocity: UserDefaults.standard.defaultStrokeVelocity,
//                                timestampNanoSecond: .now,
//                                isOn: true
//                            )
//                        )
//                        isStroked = true
//                    })
//                    .onEnded({ _ in
//                        didTriggerKeyStrokeEvent?(
//                            .init(
//                                key: pianoKey,
//                                velocity: UserDefaults.standard.defaultStrokeVelocity,
//                                timestampNanoSecond: .now,
//                                isOn: false
//                            )
//                        )
//                        isStroked = false
//                    })
//            )
#endif
        }
    }

    struct Black: View {
        let pianoKey: PianoKey
        let keyStrokedType: KeyStrokedType
        let didTriggerKeyStrokeEvent: ((PianoKeyStroke) -> Void)?
        @State private var isStroked = false
        @AppStorage(UserDefaultsKey.defaultStrokeVelocity.rawValue)
        private var defaultStrokeVelocity = UserDefaults.standard.defaultStrokeVelocity

        init(pianoKey: PianoKey, keyStrokedType: KeyStrokedType, didTriggerKeyStrokeEvent: ((PianoKeyStroke) -> Void)? = nil) {
            self.pianoKey = pianoKey
            self.keyStrokedType = keyStrokedType
            self.didTriggerKeyStrokeEvent = didTriggerKeyStrokeEvent
        }

        var body: some View {
            ZStack {
                UnevenRoundedRectangle(
                    cornerRadii: .init(
                        bottomLeading: PianoKeyView.keyCornerRadius,
                        bottomTrailing: PianoKeyView.keyCornerRadius
                    ),
                    style: .circular
                )
                .fill(.black)
                if keyStrokedType.isStroked {
                    Color.gray.opacity(Double(keyStrokedType.velocityPercent) / 100 )
                        .clipShape(
                            UnevenRoundedRectangle(
                                cornerRadii: .init(
                                    bottomLeading: PianoKeyView.keyCornerRadius,
                                    bottomTrailing: PianoKeyView.keyCornerRadius
                                ),
                                style: .circular
                            )
                        )
                }
                if isStroked {
                    Color.gray.opacity(Double(defaultStrokeVelocity) / 100 )
                        .clipShape(
                            UnevenRoundedRectangle(
                                cornerRadii: .init(
                                    bottomLeading: PianoKeyView.keyCornerRadius,
                                    bottomTrailing: PianoKeyView.keyCornerRadius
                                ),
                                style: .circular
                            )
                        )
                }
            }
            .aspectRatio(AspectRatioConstants.blackKeyAspectRatio, contentMode: .fit)
#if os(visionOS)
            .onTapGesture {
                Task {
                    didTriggerKeyStrokeEvent?(
                        .init(
                            key: pianoKey,
                            velocity: UserDefaults.standard.defaultStrokeVelocity,
                            timestampNanoSecond: .now,
                            isOn: true
                        )
                    )
                    isStroked = true
                    try? await Task.sleep(for: strokeSleepDuration)
                    didTriggerKeyStrokeEvent?(
                        .init(
                            key: pianoKey,
                            velocity: UserDefaults.standard.defaultStrokeVelocity,
                            timestampNanoSecond: .now,
                            isOn: false
                        )
                    )
                    isStroked = false
                }
            }
            .hoverEffect { effect, isActive, _ in
                // When scaleEffect is set, onTapGesture does not work
                effect.opacity(isActive ? 0.9 : 1)
            }
#else
//            .simultaneousGesture(
//                DragGesture(minimumDistance: 0)
//                    .onChanged({ _ in
//                        didTriggerKeyStrokeEvent?(
//                            .init(
//                                key: pianoKey,
//                                velocity: UserDefaults.standard.defaultStrokeVelocity,
//                                timestampNanoSecond: .now,
//                                isOn: true
//                            )
//                        )
//                        isStroked = true
//                    })
//                    .onEnded({ _ in
//                        didTriggerKeyStrokeEvent?(
//                            .init(
//                                key: pianoKey,
//                                velocity: UserDefaults.standard.defaultStrokeVelocity,
//                                timestampNanoSecond: .now,
//                                isOn: false
//                            )
//                        )
//                        isStroked = false
//                    })
//            )
#endif
        }
    }
}

#Preview {
    HStack {
        PianoKeyView.White(pianoKey: .init(keyType: .c, octave: .first), keyStrokedType: .stroked(percent: 30))
            .frame(width: 40, height: 200)
        PianoKeyView.Black(pianoKey: .init(keyType: .a, octave: .eighth), keyStrokedType: .stroked(percent: 30))
            .frame(width: 40, height: 200)
    }
    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: .infinity)
}


