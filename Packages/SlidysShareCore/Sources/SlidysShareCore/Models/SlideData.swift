import Foundation

public enum ListBulletStyle: String, Codable, Hashable, CaseIterable, Sendable {
    case bullet
    case numbered
}

public enum ShareSlideType: Codable, Hashable {
    case titleList(title: String, items: [ListItem])
    case titleImage(title: String, imageData: Data)
    case centerText(text: String)
    case centerImage(imageData: Data)
    case code(title: String, code: String)
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
    public var imageQuality: ImageQuality
    public var listBulletStyle: ListBulletStyle

    public var displayTitle: String {
        switch type {
        case .centerText(let text): text
        case .titleList(let title, _): title
        case .titleImage(let title, _): title
        case .centerImage: "画像"
        case .code(let title, _): title
        }
    }

    public init(id: UUID = UUID(), type: ShareSlideType, imageQuality: ImageQuality = .low, listBulletStyle: ListBulletStyle = .bullet) {
        self.id = id
        self.type = type
        self.imageQuality = imageQuality
        self.listBulletStyle = listBulletStyle
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        type = try container.decode(ShareSlideType.self, forKey: .type)
        imageQuality = try container.decodeIfPresent(ImageQuality.self, forKey: .imageQuality) ?? .low
        listBulletStyle = try container.decodeIfPresent(ListBulletStyle.self, forKey: .listBulletStyle) ?? .bullet
    }
}

public struct SlideDeck: Codable, Hashable, Identifiable {
    public let id: UUID
    public var title: String
    public var pages: [SlidePageData]
    public var style: SlideStyle
    public var createdAt: Date
    public var updatedAt: Date

    public init(id: UUID = UUID(), title: String, pages: [SlidePageData] = [], style: SlideStyle = .default, createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = id
        self.title = title
        self.pages = pages
        self.style = style
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        pages = try container.decode([SlidePageData].self, forKey: .pages)
        style = try container.decodeIfPresent(SlideStyle.self, forKey: .style) ?? .default
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
    }
}
