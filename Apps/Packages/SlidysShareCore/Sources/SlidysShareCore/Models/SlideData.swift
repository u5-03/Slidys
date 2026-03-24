import Foundation

public enum ShareSlideType: Codable, Hashable {
    case titleList(title: String, items: [ListItem])
    case titleImage(title: String, imageData: Data)
    case centerText(text: String)
}

public struct ListItem: Codable, Hashable, Identifiable {
    public let id: UUID
    public var text: String
    public var isIndented: Bool

    public init(id: UUID = UUID(), text: String, isIndented: Bool = false) {
        self.id = id
        self.text = text
        self.isIndented = isIndented
    }
}

public struct SlidePageData: Codable, Hashable, Identifiable {
    public let id: UUID
    public var type: ShareSlideType

    public var displayTitle: String {
        switch type {
        case .centerText(let text): text
        case .titleList(let title, _): title
        case .titleImage(let title, _): title
        }
    }

    public init(id: UUID = UUID(), type: ShareSlideType) {
        self.id = id
        self.type = type
    }
}

public struct SlideDeck: Codable, Hashable, Identifiable {
    public let id: UUID
    public var title: String
    public var pages: [SlidePageData]
    public var createdAt: Date
    public var updatedAt: Date

    public init(id: UUID = UUID(), title: String, pages: [SlidePageData] = [], createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = id
        self.title = title
        self.pages = pages
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
