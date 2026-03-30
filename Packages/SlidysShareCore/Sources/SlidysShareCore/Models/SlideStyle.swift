import Foundation

public struct SlideStyle: Codable, Hashable, Sendable {
    public var textColor: CodableColor
    public var backgroundColor: CodableColor
    public var accentColor: CodableColor

    public init(
        textColor: CodableColor,
        backgroundColor: CodableColor,
        accentColor: CodableColor
    ) {
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.accentColor = accentColor
    }

    public static let `default` = SlideStyle(
        textColor: CodableColor(red: 0, green: 0, blue: 0, opacity: 1),
        backgroundColor: CodableColor(red: 1, green: 1, blue: 1, opacity: 1),
        accentColor: CodableColor(red: 0, green: 0.478, blue: 1, opacity: 1)
    )
}
