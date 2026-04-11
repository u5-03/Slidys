import Foundation

public enum ConnectionState: Sendable, Equatable {
    case disconnected
    case connecting
    case connected
}

public struct ReceivedReaction: Identifiable, Sendable {
    public let id: UUID
    public let type: ReactionType
    public let timestamp: Date

    public init(id: UUID = UUID(), type: ReactionType, timestamp: Date = Date()) {
        self.id = id
        self.type = type
        self.timestamp = timestamp
    }
}

@MainActor
public protocol SlideConnectionProtocol: AnyObject {
    var connectionState: ConnectionState { get }
    var receivedEvent: SlideEvent? { get }
    var receivedReactions: [ReceivedReaction] { get }

    func startHosting(displayName: String)
    func startBrowsing()
    func send(event: SlideEvent) throws
    func disconnect()
    func clearReceivedEvent()
    func addLocalReaction(_ type: ReactionType)
    func removeReaction(id: UUID)
}
