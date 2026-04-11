import Foundation
import Observation
import SlidysShareCore

@MainActor
@Observable
final class FakeSlideConnection: SlideConnectionProtocol {
    var connectionState: ConnectionState = .connected
    var receivedEvent: SlideEvent?
    var receivedReactions: [ReceivedReaction] = []

    func startHosting(displayName: String) {}
    func startBrowsing() {}
    func send(event: SlideEvent) throws {}
    func disconnect() {}
    func clearReceivedEvent() { receivedEvent = nil }
    func addLocalReaction(_ type: ReactionType) {
        receivedReactions.append(ReceivedReaction(type: type))
    }
    func removeReaction(id: UUID) {
        // No-op: keep reactions in array for screenshots.
        // The animation sets opacity to 0 after 2.5s, so capture must happen before that.
    }
}
