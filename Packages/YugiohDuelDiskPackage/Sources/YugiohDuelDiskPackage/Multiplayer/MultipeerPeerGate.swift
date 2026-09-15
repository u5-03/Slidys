//
//  MultipeerPeerGate.swift
//  YugiohDuelDiskPackage
//
//  「参加者は最大 2 名(自分 + 相手 1 名)」を守るための純粋な状態機械。
//  `MultipeerDuelTransport` が `lock` 保護下で保持し、招待の受諾 / 送信と
//  MCSession の状態遷移(connecting / connected / notConnected)をここへ流し込む。
//  MultipeerConnectivity に依存しないので、実機なしで単体テストできる。
//
//  - `pending`: 招待を受諾(host)/ 送信(guest)して接続待ちのピア
//  - `connected`: 接続済みのピア。データはこのピアからのものだけ受け付ける
//  どちらかが埋まっている間は新たな招待を受諾も送信もしない。
//

import Foundation

public struct MultipeerPeerGate<PeerID: Equatable>: Equatable {
    /// `markConnected` の結果。
    public enum ConnectResult: Equatable {
        /// 相手として確定した(`.connected` を上位へ通知すべき)。
        case accepted
        /// 既に接続済みの同じピア(重複通知。何もしない)。
        case duplicate
        /// 相手が埋まっているのに別のピアが接続した(切り離すべき 3 人目)。
        case rejected
    }

    /// `markDisconnected` の結果。
    public struct DisconnectResult: Equatable {
        /// 接続済みの相手が切れた(`.disconnected` を上位へ通知すべき)。
        public var wasConnected: Bool
        /// 接続待ちの候補が失敗した(招待タイムアウト / 拒否)。上位へは通知せず探索を続ける。
        public var wasPending: Bool
        /// 相手が誰もいなくなった(探索 / 広告を再開すべき)。
        public var isEmpty: Bool
    }

    public private(set) var pending: PeerID?
    public private(set) var connected: PeerID?

    public init() {}

    /// 新しい招待を受諾(host)/ 送信(guest)してよいか。候補も接続済みもいないときだけ true。
    public static func canAccept(pending: PeerID?, connected: PeerID?) -> Bool {
        pending == nil && connected == nil
    }

    /// 現在の状態で新しい招待を受諾 / 送信してよいか。
    public var canAccept: Bool {
        Self.canAccept(pending: pending, connected: connected)
    }

    /// 招待の受諾(host)/ 送信(guest)を試みる。受け入れられれば候補に登録して true。
    @discardableResult
    public mutating func accept(_ peer: PeerID) -> Bool {
        guard canAccept else { return false }
        pending = peer
        return true
    }

    /// MCSession の `.connecting` 通知。候補が未登録なら登録する(自分の招待経由でない接続への保険)。
    public mutating func markConnecting(_ peer: PeerID) {
        if canAccept { pending = peer }
    }

    /// MCSession の `.connected` 通知。
    public mutating func markConnected(_ peer: PeerID) -> ConnectResult {
        if connected == peer { return .duplicate }
        if pending == peer || canAccept {
            connected = peer
            pending = nil
            return .accepted
        }
        return .rejected
    }

    /// MCSession の `.notConnected` 通知(招待タイムアウト / 拒否 / 切断)。
    public mutating func markDisconnected(_ peer: PeerID) -> DisconnectResult {
        let wasConnected = connected == peer
        let wasPending = pending == peer
        if wasConnected { connected = nil }
        if wasPending { pending = nil }
        return DisconnectResult(
            wasConnected: wasConnected,
            wasPending: wasPending,
            isEmpty: pending == nil && connected == nil
        )
    }

    /// 探索中に候補ピアが見えなくなった(`lostPeer`)。候補だけを取り消す。
    public mutating func forgetPending(_ peer: PeerID) {
        if pending == peer { pending = nil }
    }

    public mutating func reset() {
        pending = nil
        connected = nil
    }
}
