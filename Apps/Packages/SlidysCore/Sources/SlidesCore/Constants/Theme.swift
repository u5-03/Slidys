//
//  Theme.swift
//  SlidysCore
//
//  Created by Yugo Sugiyama on 2024/11/09.
//

import SwiftUI

public extension Font {
    static let extraLargeFont: Font = .system(size: 140, weight: .bold)
    static let largeFont: Font = .system(size: 100, weight: .bold)
    static let mediumFont: Font = .system(size: 72, weight: .bold)
    static let smallFont: Font = .system(size: 60, weight: .bold)
    static let regularFont: Font = .system(size: 45, weight: .semibold)
    static let bodyFont: Font = .system(size: 40, weight: .regular)
    static let tinyFont: Font = .system(size: 36, weight: .bold)
    static let captionFont: Font = .system(size: 32, weight: .regular)
    static let codeFont: Font = .system(size: 35, weight: .regular, design: .monospaced)
}

public extension ShapeStyle where Self == Color {
    static var defaultForegroundColor: Color { return .init(hex: "DDDDDD") }
    static var slideBackgroundColor: Color { return .init(hex: "383944") }
    static var strokeColor: Color { return .init(hex: "F48F23") }
    static var themeColor: Color { return .init(hex: "2388F4") }
}
