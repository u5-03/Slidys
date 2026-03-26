import SwiftUI

extension Font {
    static let largeFont: Font = .system(size: 100, weight: .bold)
}

extension ShapeStyle where Self == Color {
    static var defaultForegroundColor: Color { Color(red: 0.867, green: 0.867, blue: 0.867) }
    static var slideBackgroundColor: Color { Color(red: 0.220, green: 0.224, blue: 0.267) }
}
