//
//  Constants.swift
//  HakodateSwiftSlide
//
//  Created by Yugo Sugiyama on 2026/02/20.
//

import SwiftUI

enum Constants {
    static let presentationName = "Hakodate.swift"
}

extension Font {
    static let extraLargeFont: Font = .system(size: 140, weight: .bold)
    static let largeFont: Font = .system(size: 100, weight: .bold)
    static let midiumFont: Font = .system(size: 80, weight: .bold)
}

extension ShapeStyle where Self == Color {
    static var defaultForegroundColor: Color { return .init(hex: "DDDDDD") }
    static var slideBackgroundColor: Color { return .init(hex: "383944") }
    static var strokeColor: Color { return .init(hex: "F48F23") }
    static var themeColor: Color { return .init(hex: "2388F4") }
}
