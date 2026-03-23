import Foundation
import MultipeerConnectivity
import SlidysShareCore
import SwiftUI

@Observable
final class MultipeerManager: NSObject, SlideConnectionProtocol {
    private(set) var connectionState: ConnectionState = .disconnected
    private(set) var receivedEvent: SlideEvent?

    private let serviceType = "slidys-share"
    private let myPeerID = MCPeerID(displayName: UIDevice.current.name)
    private var session: MCSession?
    private var advertiser: MCNearbyServiceAdvertiser?
    private var browser: MCNearbyServiceBrowser?

    override init() {
        super.init()
    }

    // MARK: - SlideConnectionProtocol

    func startHosting() {
        let session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .none)
        session.delegate = self
        self.session = session

        advertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: serviceType)
        advertiser?.delegate = self
        advertiser?.startAdvertisingPeer()
        connectionState = .connecting
    }

    func startBrowsing() {
        let session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .none)
        session.delegate = self
        self.session = session

        browser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: serviceType)
        browser?.delegate = self
        browser?.startBrowsingForPeers()
        connectionState = .connecting
    }

    func send(event: SlideEvent) throws {
        guard let session, !session.connectedPeers.isEmpty else { return }
        let data = try JSONEncoder().encode(event)
        try session.send(data, toPeers: session.connectedPeers, with: .reliable)
    }

    func disconnect() {
        session?.disconnect()
        advertiser?.stopAdvertisingPeer()
        browser?.stopBrowsingForPeers()
        advertiser = nil
        browser = nil
        session = nil
        connectionState = .disconnected
    }

    // MARK: - Browser ViewController

    func makeBrowserViewController() -> MCBrowserViewController? {
        guard let session else { return nil }
        return MCBrowserViewController(serviceType: serviceType, session: session)
    }
}

// MARK: - MCSessionDelegate

extension MultipeerManager: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        Task { @MainActor in
            switch state {
            case .connected:
                self.connectionState = .connected
            case .connecting:
                self.connectionState = .connecting
            case .notConnected:
                self.connectionState = .disconnected
            @unknown default:
                break
            }
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        guard let event = try? JSONDecoder().decode(SlideEvent.self, from: data) else { return }
        Task { @MainActor in
            self.receivedEvent = event
        }
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}

// MARK: - MCNearbyServiceAdvertiserDelegate

extension MultipeerManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, session)
    }
}

// MARK: - MCNearbyServiceBrowserDelegate

extension MultipeerManager: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        guard let session else { return }
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 30)
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {}
}

// MARK: - MultipeerBrowserView

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
