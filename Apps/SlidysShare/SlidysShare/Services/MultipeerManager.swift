import Foundation
import MultipeerConnectivity
import SlidysShareCore
import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

struct ReceivedReaction: Identifiable, Sendable {
    let id: UUID
    let type: ReactionType
    let timestamp: Date
}

@MainActor
@Observable
final class MultipeerManager: NSObject, SlideConnectionProtocol {
    private(set) var connectionState: ConnectionState = .disconnected
    private(set) var receivedEvent: SlideEvent?
    private(set) var receivedReactions: [ReceivedReaction] = []
    private(set) var isHost: Bool = false
    var onPeerConnected: (@MainActor @Sendable (MCPeerID) -> Void)?

    private let serviceType = "slidys-share"
    private var myPeerID: MCPeerID
    private var session: MCSession?
    private var advertiser: MCNearbyServiceAdvertiser?
    private var browser: MCNearbyServiceBrowser?
    private var reactionCleanupTask: Task<Void, Never>?

    private static var defaultPeerName: String {
        #if canImport(UIKit)
        UIDevice.current.name
        #elseif canImport(AppKit)
        Host.current().localizedName ?? "Mac"
        #endif
    }

    override init() {
        self.myPeerID = MCPeerID(displayName: Self.defaultPeerName)
        super.init()
    }

    // MARK: - SlideConnectionProtocol

    func startHosting(displayName: String = "スライド送信者") {
        myPeerID = MCPeerID(displayName: displayName)
        isHost = true

        let session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .none)
        session.delegate = self
        self.session = session

        advertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: serviceType)
        advertiser?.delegate = self
        advertiser?.startAdvertisingPeer()
        connectionState = .connecting
        startReactionCleanup()
    }

    func startBrowsing() {
        isHost = false
        let session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .none)
        session.delegate = self
        self.session = session
        connectionState = .connecting
        startReactionCleanup()

        #if os(macOS)
        // macOS uses programmatic browser (no MCBrowserViewController)
        browser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: serviceType)
        browser?.delegate = self
        browser?.startBrowsingForPeers()
        #endif
        // iOS/visionOS: session only — MCBrowserViewController handles browsing
    }

    func send(event: SlideEvent) throws {
        guard let session, !session.connectedPeers.isEmpty else { return }
        let data = try JSONEncoder().encode(event)
        try session.send(data, toPeers: session.connectedPeers, with: .reliable)
    }

    func send(event: SlideEvent, to peer: MCPeerID) throws {
        guard let session else { return }
        let data = try JSONEncoder().encode(event)
        try session.send(data, toPeers: [peer], with: .reliable)
    }

    func disconnect() {
        session?.disconnect()
        advertiser?.stopAdvertisingPeer()
        browser?.stopBrowsingForPeers()
        advertiser = nil
        browser = nil
        session = nil
        receivedEvent = nil
        receivedReactions = []
        reactionCleanupTask?.cancel()
        reactionCleanupTask = nil
        onPeerConnected = nil
        isHost = false
        connectionState = .disconnected
    }

    func clearReceivedEvent() {
        receivedEvent = nil
    }

    func addLocalReaction(_ type: ReactionType) {
        let reaction = ReceivedReaction(id: UUID(), type: type, timestamp: Date())
        receivedReactions.append(reaction)
    }

    func removeReaction(id: UUID) {
        receivedReactions.removeAll { $0.id == id }
    }

    // MARK: - Reaction Cleanup

    private func startReactionCleanup() {
        reactionCleanupTask?.cancel()
        reactionCleanupTask = Task { @MainActor [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard let self else { return }
                let cutoff = Date().addingTimeInterval(-3)
                self.receivedReactions.removeAll { $0.timestamp < cutoff }
            }
        }
    }

    // MARK: - Browser ViewController

    #if os(iOS) || os(visionOS)
    func makeBrowserViewController() -> MCBrowserViewController? {
        guard let session else { return nil }
        return MCBrowserViewController(serviceType: serviceType, session: session)
    }
    #endif
}

// MARK: - MCSessionDelegate

extension MultipeerManager: MCSessionDelegate {
    nonisolated func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        Task { @MainActor in
            switch state {
            case .connected:
                self.connectionState = .connected
                if self.isHost {
                    self.onPeerConnected?(peerID)
                }
            case .connecting:
                if session.connectedPeers.isEmpty {
                    self.connectionState = .connecting
                }
            case .notConnected:
                if session.connectedPeers.isEmpty {
                    self.connectionState = .disconnected
                }
            @unknown default:
                break
            }
        }
    }

    nonisolated func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        guard let event = try? JSONDecoder().decode(SlideEvent.self, from: data) else { return }
        Task { @MainActor in
            switch event {
            case .reaction(let type):
                let reaction = ReceivedReaction(id: UUID(), type: type, timestamp: Date())
                self.receivedReactions.append(reaction)
                // Host relays reactions to all other connected peers
                if self.isHost {
                    let otherPeers = session.connectedPeers.filter { $0 != peerID }
                    if !otherPeers.isEmpty {
                        try? session.send(data, toPeers: otherPeers, with: .reliable)
                    }
                }
            default:
                self.receivedEvent = event
            }
        }
    }

    nonisolated func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    nonisolated func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    nonisolated func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}

// MARK: - MCNearbyServiceAdvertiserDelegate

extension MultipeerManager: MCNearbyServiceAdvertiserDelegate {
    nonisolated func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        Task { @MainActor in
            invitationHandler(true, self.session)
        }
    }
}

// MARK: - MCNearbyServiceBrowserDelegate

extension MultipeerManager: MCNearbyServiceBrowserDelegate {
    nonisolated func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        Task { @MainActor in
            guard let session = self.session else { return }
            browser.invitePeer(peerID, to: session, withContext: nil, timeout: 30)
        }
    }

    nonisolated func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {}
}

// MARK: - MultipeerBrowserView

#if os(iOS) || os(visionOS)
struct MultipeerBrowserView: UIViewControllerRepresentable {
    let browser: MCBrowserViewController
    let onFinished: () -> Void
    let onCancelled: () -> Void

    func makeUIViewController(context: Context) -> MCBrowserViewController {
        browser.delegate = context.coordinator
        return browser
    }

    func updateUIViewController(_ uiViewController: MCBrowserViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onFinished: onFinished, onCancelled: onCancelled)
    }

    class Coordinator: NSObject, MCBrowserViewControllerDelegate {
        let onFinished: () -> Void
        let onCancelled: () -> Void

        init(onFinished: @escaping () -> Void, onCancelled: @escaping () -> Void) {
            self.onFinished = onFinished
            self.onCancelled = onCancelled
        }

        func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
            onFinished()
        }

        func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
            onCancelled()
        }
    }
}
#endif

#if os(macOS)
struct MultipeerBrowserView: View {
    let manager: MultipeerManager
    let onFinished: () -> Void
    let onCancelled: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("ピアを検索中...")
                .font(.headline)
            ProgressView()
            Text("接続状態: \(stateText)")
                .foregroundStyle(.secondary)
            Button("キャンセル") {
                onCancelled()
            }
        }
        .padding(40)
        .onChange(of: manager.connectionState) { _, newState in
            if newState == .connected {
                onFinished()
            }
        }
    }

    private var stateText: String {
        switch manager.connectionState {
        case .disconnected: return "未接続"
        case .connecting: return "接続中..."
        case .connected: return "接続済み"
        }
    }
}
#endif
