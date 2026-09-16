//
//  MultipeerDuelTransport.swift
//  YugiohDuelDiskPackage
//
//  MultipeerConnectivity による実機 2 台向けトランスポート。
//  - host: MCNearbyServiceAdvertiser で待ち受け、相手が未確定の間だけ最初の招待を受諾する。
//  - guest: MCNearbyServiceBrowser で探索し、相手が未確定の間だけ最初に見つけたピアを招待する(タイムアウト 30 秒)。
//  参加者は最大 2 名(自分 + 相手 1 名)。候補(pending)と接続済み(connected)を `MultipeerPeerGate` で
//  MCPeerID 単位に追跡し、どちらかが埋まっている間は新たな招待を受諾も送信もしない。
//  受信データは connected のピアからのものだけ受け付ける。
//
//  ペア名(`pairName`): 同じ部屋に多数のデバイスがいても、同じペア名を入力した者同士だけが接続されるようにする。
//  host は広告の discoveryInfo にペア名を載せ、guest は一致するホストだけを招待する(招待 context にも自分のペア名を載せる)。
//  host は招待 context のペア名が一致するときだけ受諾する。判定は `MultipeerPairMatcher` に切り出してある。
//  一致しない相手は gate に触れない(候補として占有しない)。
//
//  切断 / 招待失敗で相手がいなくなったら、`stop()` されるまで役割に応じた探索・広告を再開する:
//  - host: 広告を止めて再開する(次の招待を受諾できる状態に戻す)。
//  - guest: 探索を止めて再開する。再開により、まだ見えているピアも含めて `foundPeer` が再配信されるので、
//    そこで再招待する(明示的な再招待ループは持たず、`foundPeer` に一本化)。
//  再接続時も `.connected` を再度 yield するため、上位(DuelMatchSession)は hello + snapshot を送り直す。
//
//  スレッド安全性: MCSession / Advertiser / Browser のデリゲートは任意のキューから呼ばれる。
//  可変状態(`advertiser` / `browser` / `isStarted` / `gate`)はすべて `lock` 保護下でのみ読み書きし、
//  デリゲートへ再入し得る MC 系 API(disconnect / stop* / start* / invite)はロックの外で呼ぶ。
//

#if canImport(MultipeerConnectivity)
import Foundation
import MultipeerConnectivity

public final class MultipeerDuelTransport: NSObject, DuelTransport, @unchecked Sendable {
    public typealias Role = DuelMultipeerRole

    /// Bonjour サービスタイプ(15 文字以内 / 小文字英数字とハイフン)。
    public static let serviceType = "slidys-duel"
    /// guest 側の招待タイムアウト(秒)。
    public static let invitationTimeout: TimeInterval = 30
    /// `MCPeerID.displayName` の上限(UTF-8 バイト数)。
    static let maxDisplayNameBytes = 63

    public let role: Role
    /// ペア名(`sanitizedPairName` 済み)。同じペア名の相手とだけ接続する。"" は「ペア名なし」。
    public let pairName: String
    public let events: AsyncStream<DuelTransportEvent>

    private let continuation: AsyncStream<DuelTransportEvent>.Continuation
    private let localPeerID: MCPeerID
    private let session: MCSession

    // 以下は `lock` 保護下でのみ読み書きする(ファイル冒頭「スレッド安全性」参照)。
    private let lock = NSLock()
    private var advertiser: MCNearbyServiceAdvertiser?
    private var browser: MCNearbyServiceBrowser?
    private var isStarted = false
    private var gate = MultipeerPeerGate<MCPeerID>()

    /// 現在接続中の相手の表示名(未接続なら nil)。
    public var connectedPeerName: String? {
        lock.lock(); defer { lock.unlock() }
        return gate.connected?.displayName
    }

    public init(role: Role, displayName: String, pairName: String = "") {
        self.role = role
        self.pairName = Self.sanitizedPairName(pairName)
        self.localPeerID = MCPeerID(displayName: Self.sanitizedDisplayName(displayName))
        self.session = MCSession(peer: localPeerID, securityIdentity: nil, encryptionPreference: .required)
        let (stream, continuation) = AsyncStream<DuelTransportEvent>.makeStream()
        self.events = stream
        self.continuation = continuation
        super.init()
        session.delegate = self
    }

    deinit {
        lock.lock()
        let advertiser = self.advertiser
        let browser = self.browser
        self.advertiser = nil
        self.browser = nil
        lock.unlock()
        Self.tearDown(advertiser: advertiser, browser: browser)
        session.disconnect()
        continuation.finish()
    }

    /// `MCPeerID` の制約(空不可 / UTF-8 で 63 バイト以内)に合わせて表示名を整える。
    /// バイト単位で切ると多バイト文字を分断して 64〜65 バイトになり得るため、Character 単位で末尾から削る。
    static func sanitizedDisplayName(_ displayName: String) -> String {
        var name = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        while name.utf8.count > maxDisplayNameBytes {
            name.removeLast()
        }
        return name.isEmpty ? "Duelist" : name
    }

    /// ペア名を整える(前後の空白・改行を除き、20 文字を超える分は末尾から削る)。空文字 = ペア名なし。
    static func sanitizedPairName(_ pairName: String) -> String {
        MultipeerPairMatcher.sanitizedPairName(pairName)
    }

    // MARK: - DuelTransport

    public func start() {
        lock.lock()
        guard !isStarted else { lock.unlock(); return }
        isStarted = true
        gate.reset()
        var advertiser: MCNearbyServiceAdvertiser?
        var browser: MCNearbyServiceBrowser?
        switch role {
        case .host:
            // discoveryInfo は Bonjour TXT レコードに載るので短く保つ(ペア名 + 表示名のみ)。
            let info = MultipeerPairMatcher.discoveryInfo(pairName: pairName, displayName: localPeerID.displayName)
            let a = MCNearbyServiceAdvertiser(peer: localPeerID, discoveryInfo: info, serviceType: Self.serviceType)
            a.delegate = self
            self.advertiser = a
            advertiser = a
        case .guest:
            let b = MCNearbyServiceBrowser(peer: localPeerID, serviceType: Self.serviceType)
            b.delegate = self
            self.browser = b
            browser = b
        }
        lock.unlock()
        // ロック外で開始(デリゲートへの再入を避ける)。
        advertiser?.startAdvertisingPeer()
        browser?.startBrowsingForPeers()
    }

    public func stop() {
        lock.lock()
        isStarted = false
        let advertiser = self.advertiser
        let browser = self.browser
        self.advertiser = nil
        self.browser = nil
        let wasConnected = gate.connected != nil
        gate.reset()
        lock.unlock()
        Self.tearDown(advertiser: advertiser, browser: browser)
        // gate を先に空にしているので、この disconnect による `.notConnected` 通知は無視される。
        session.disconnect()
        if wasConnected {
            continuation.yield(.disconnected)
        }
    }

    public func send(_ event: DuelEvent) {
        lock.lock()
        let peer = gate.connected
        lock.unlock()
        guard let peer, session.connectedPeers.contains(peer) else { return }
        do {
            let data = try DuelWireCodec.encode(event)
            try session.send(data, toPeers: [peer], with: .reliable)
        } catch {
            // 送信失敗は握りつぶす(切断は MCSession の state 変化で通知される)。
            debugLog("send failed: \(error)")
        }
    }

    // MARK: - 内部

    private static func tearDown(advertiser: MCNearbyServiceAdvertiser?, browser: MCNearbyServiceBrowser?) {
        advertiser?.stopAdvertisingPeer()
        advertiser?.delegate = nil
        browser?.stopBrowsingForPeers()
        browser?.delegate = nil
    }

    /// 相手が確定したので広告 / 探索を一時停止する。オブジェクトは保持し、切断後に再開できるようにする。
    private func pauseDiscovery() {
        lock.lock()
        let advertiser = self.advertiser
        let browser = self.browser
        lock.unlock()
        advertiser?.stopAdvertisingPeer()
        browser?.stopBrowsingForPeers()
    }

    /// 相手がいなくなったので広告 / 探索を再開する(停止 → 開始)。
    /// guest は再開によって `foundPeer` が再配信されるので、そこで再招待する。
    private func restartDiscovery() {
        lock.lock()
        let advertiser = self.advertiser
        let browser = self.browser
        lock.unlock()
        advertiser?.stopAdvertisingPeer()
        advertiser?.startAdvertisingPeer()
        browser?.stopBrowsingForPeers()
        browser?.startBrowsingForPeers()
    }

    private func debugLog(_ message: @autoclosure () -> String) {
        #if DEBUG
        print("[MultipeerDuelTransport(\(role))] \(message())")
        #endif
    }
}

// MARK: - MCSessionDelegate

extension MultipeerDuelTransport: MCSessionDelegate {
    public func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connecting:
            lock.lock()
            gate.markConnecting(peerID)
            lock.unlock()
        case .connected:
            lock.lock()
            let result = gate.markConnected(peerID)
            lock.unlock()
            switch result {
            case .accepted:
                // 相手が決まったら探索・広告は止める(最大 2 名)。
                pauseDiscovery()
                continuation.yield(.connected(peerName: peerID.displayName))
            case .duplicate:
                break
            case .rejected:
                // 相手が埋まっているのに別ピアが接続した(3 人目)。セッションから切り離す。
                debugLog("rejected extra peer \(peerID.displayName)")
                session.cancelConnectPeer(peerID)
            }
        case .notConnected:
            lock.lock()
            let result = gate.markDisconnected(peerID)
            let shouldRestart = isStarted && (result.wasConnected || result.wasPending) && result.isEmpty
            lock.unlock()
            if result.wasConnected {
                continuation.yield(.disconnected)
            }
            if shouldRestart {
                // 招待タイムアウト / 拒否 / 切断のいずれでも、次の相手を受け付けられる状態に戻す。
                debugLog("peer \(peerID.displayName) gone; restarting discovery")
                restartDiscovery()
            }
        @unknown default:
            break
        }
    }

    public func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        lock.lock()
        let connected = gate.connected
        lock.unlock()
        // 接続済みの相手以外からのデータは捨てる。
        guard let connected, connected == peerID else {
            debugLog("dropped data from unexpected peer \(peerID.displayName)")
            return
        }
        guard data.count <= DuelWireLimits.maxPayloadBytes else {
            let message = "payload too large: \(data.count) bytes (max \(DuelWireLimits.maxPayloadBytes))"
            debugLog(message)
            continuation.yield(.protocolError(message))
            return
        }
        do {
            let event = try DuelWireCodec.decode(data)
            continuation.yield(.received(event))
        } catch DuelWireCodec.CodecError.unsupportedVersion(let version) {
            let message = "unsupported wire version \(version) (expected \(DuelWireMessage.currentVersion))"
            debugLog(message)
            continuation.yield(.protocolError(message))
        } catch {
            let message = "decode failed: \(error)"
            debugLog(message)
            continuation.yield(.protocolError(message))
        }
    }

    public func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}

    public func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}

    public func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}

// MARK: - MCNearbyServiceAdvertiserDelegate (host)

extension MultipeerDuelTransport: MCNearbyServiceAdvertiserDelegate {
    public func advertiser(
        _ advertiser: MCNearbyServiceAdvertiser,
        didReceiveInvitationFromPeer peerID: MCPeerID,
        withContext context: Data?,
        invitationHandler: @escaping (Bool, MCSession?) -> Void
    ) {
        // ペア名が一致しない相手は拒否する(gate には触れない = 候補として占有しない)。
        let remotePairName = MultipeerPairMatcher.pairName(fromInvitationContext: context)
        guard MultipeerPairMatcher.matches(local: pairName, remote: remotePairName) else {
            debugLog("declined invitation from \(peerID.displayName): pair \"\(remotePairName)\" != \"\(pairName)\"")
            invitationHandler(false, nil)
            return
        }
        // 候補も接続済みもいない間だけ受諾し、受諾したピアを候補に登録する。
        lock.lock()
        let accepted = gate.accept(peerID)
        lock.unlock()
        invitationHandler(accepted, accepted ? session : nil)
    }

    public func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        lock.lock()
        isStarted = false
        lock.unlock()
        let message = "advertising failed: \(error.localizedDescription)"
        debugLog(message)
        continuation.yield(.protocolError(message))
        continuation.yield(.disconnected)
    }
}

// MARK: - MCNearbyServiceBrowserDelegate (guest)

extension MultipeerDuelTransport: MCNearbyServiceBrowserDelegate {
    public func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        // ペア名が一致しないホストは無視する(招待せず、gate にも触れない = 候補として占有しない)。
        let remotePairName = MultipeerPairMatcher.pairName(fromDiscoveryInfo: info)
        guard MultipeerPairMatcher.matches(local: pairName, remote: remotePairName) else {
            debugLog("ignored peer \(peerID.displayName): pair \"\(remotePairName)\" != \"\(pairName)\"")
            return
        }
        // 候補も接続済みもいない間だけ招待し、招待したピアを候補に登録する。
        lock.lock()
        let shouldInvite = gate.accept(peerID)
        lock.unlock()
        guard shouldInvite else { return }
        browser.invitePeer(
            peerID,
            to: session,
            withContext: MultipeerPairMatcher.invitationContext(for: pairName),
            timeout: Self.invitationTimeout
        )
    }

    public func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        // 招待中のピアが見えなくなったら候補を取り消し、次の `foundPeer` を受け付けられるようにする。
        lock.lock()
        gate.forgetPending(peerID)
        lock.unlock()
    }

    public func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        lock.lock()
        isStarted = false
        lock.unlock()
        let message = "browsing failed: \(error.localizedDescription)"
        debugLog(message)
        continuation.yield(.protocolError(message))
        continuation.yield(.disconnected)
    }
}
#endif
