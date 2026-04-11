import Foundation

public enum ReactionType: String, Codable, CaseIterable, Sendable {
    case thumbsUp
    case clap
    case heart
    case fire
    case rocket

    public var emoji: String {
        switch self {
        case .thumbsUp: return "\u{1F44D}"
        case .clap: return "\u{1F44F}"
        case .heart: return "\u{2764}\u{FE0F}"
        case .fire: return "\u{1F525}"
        case .rocket: return "\u{1F680}"
        }
    }

    public var sfSymbolName: String {
        switch self {
        case .thumbsUp: return "hand.thumbsup.fill"
        case .clap: return "hands.clap.fill"
        case .heart: return "heart.fill"
        case .fire: return "flame.fill"
        case .rocket: return "paperplane.fill"
        }
    }
}
