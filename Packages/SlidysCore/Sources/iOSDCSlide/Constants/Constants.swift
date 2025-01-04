//
//  Constants.swift
//  iOSDC2024Slide
//
//  Created by Yugo Sugiyama on 2024/08/01.
//

import SwiftUI
import PianoUI

enum Constants {
    static let presentationName = "我が家に電子ピアノがやってきたので、\nピアノと連携するアプリを作ってみた！"
}

extension Font {
    static let largeFont: Font = .system(size: 100, weight: .bold)
    static let midiumFont: Font = .system(size: 80, weight: .bold)
}

extension ShapeStyle where Self == Color {
    static var defaultForegroundColor: Color { return .init(hex: "DDDDDD") }
    static var slideBackgroundColor: Color { return .init(hex: "383944") }
    static var strokeColor: Color { return .init(hex: "F48F23") }
    static var themeColor: Color { return .init(hex: "2388F4") }
}

public enum AspectRatioConstants {
    public static let keyAspectRatio = CGSize(width: 1.5, height: 10)
    public static let keyboardAspectRatio = CGSize(width: 1.5, height: 10)
}

public enum KeyTemplate {
    public static let openingKeyStrokes: [[PianoKeyStroke]] = [
        [.init(key: .init(keyType: .c, octave: .fifth), velocity: 100, timestampNanoSecond: .now)],
        [.init(key: .init(keyType: .aSharp, octave: .fourth), velocity: 100, timestampNanoSecond: .now)],
        [.init(key: .init(keyType: .g, octave: .fourth), velocity: 100, timestampNanoSecond: .now)],
        [.init(key: .init(keyType: .c, octave: .fifth), velocity: 100, timestampNanoSecond: .now)],
        [.init(key: .init(keyType: .f, octave: .fourth), velocity: 100, timestampNanoSecond: .now)],
        [.init(key: .init(keyType: .c, octave: .fifth), velocity: 100, timestampNanoSecond: .now)],
        [.init(key: .init(keyType: .aSharp, octave: .fourth), velocity: 100, timestampNanoSecond: .now)],
        [.init(key: .init(keyType: .c, octave: .fifth), velocity: 100, timestampNanoSecond: .now)],
        [.init(key: .init(keyType: .f, octave: .fourth), velocity: 100, timestampNanoSecond: .now)],
        [.init(key: .init(keyType: .g, octave: .fourth), velocity: 100, timestampNanoSecond: .now)],
        [.init(key: .init(keyType: .g, octave: .fourth), velocity: 100, timestampNanoSecond: .now)],
         [.init(key: .init(keyType: .aSharp, octave: .fourth), velocity: 100, timestampNanoSecond: .now)],
        [.init(key: .init(keyType: .c, octave: .fifth), velocity: 100, timestampNanoSecond: .now)],
    ]

    public static let allKeyTypes: [[PianoKeyStroke]] = KeyType.allCases
        .map { [PianoKeyStroke(key: .init(keyType: $0, octave: .fourth), velocity: 100, timestampNanoSecond: .now)] }
}

