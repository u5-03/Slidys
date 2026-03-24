import Foundation

public enum ConnectionState: Sendable {
    case disconnected
    case connecting
    case connected
}

public protocol SlideConnectionProtocol: AnyObject {
    var connectionState: ConnectionState { get }
    var receivedEvent: SlideEvent? { get }

    func startHosting()
    func startBrowsing()
    func send(event: SlideEvent) throws
    func disconnect()
}
