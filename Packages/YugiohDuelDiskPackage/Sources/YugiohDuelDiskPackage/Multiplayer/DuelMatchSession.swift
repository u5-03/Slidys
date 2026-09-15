//
//  DuelMatchSession.swift
//  YugiohDuelDiskPackage
//
//  1 対戦分のセッション。
//  - ローカルの盤面変化(`DuelSessionStore.eventSink`)をトランスポート経由で相手へ送る。
//  - 相手から受信したイベントを `DuelSessionStore.applyOpponentEvent` で相手陣へ適用する。
//  Store への書き込みはすべて MainActor 上で行う。
//
//  セッションは使い切り: `start()` は 1 回だけ有効で、`stop()` 後の再 `start()` はサポートしない
//  (`DuelTransport.events` が単一消費者・使い切りのため)。再接続はセッションごと作り直す。
//

import Foundation
import Observation

@Observable
public final class DuelMatchSession: @unchecked Sendable {
    public enum ConnectionState: Sendable, Equatable {
        case idle
        case waiting
        case connected(peerName: String)
        case disconnected
    }

    public private(set) var connectionState: ConnectionState = .idle
    /// 直近のプロトコルエラー(デコード失敗 / 広告・探索の開始失敗など)。
    /// `.connected` を受けたとき、および `stop()` で nil に戻る。
    public private(set) var lastError: String?
    public let localInfo: DuelPeerInfo
    /// このセッションが使うトランスポート(テスト / デバッグ用に公開。差し替えは不可)。
    @ObservationIgnored public let transport: any DuelTransport

    @ObservationIgnored private let store: DuelSessionStore
    @ObservationIgnored private var consumeTask: Task<Void, Never>?
    @ObservationIgnored private var hasStarted = false

    public init(store: DuelSessionStore, transport: any DuelTransport, localInfo: DuelPeerInfo) {
        self.store = store
        self.transport = transport
        self.localInfo = localInfo
    }

    deinit {
        consumeTask?.cancel()
    }

    /// 対戦を開始する。Store を対戦モードに切り替え、トランスポートのイベント消費を始める。
    /// 冪等: 2 回目以降の呼び出し(`stop()` 後も含む)は無視する。
    public func start() {
        guard !hasStarted else { return }
        hasStarted = true
        lastError = nil
        connectionState = .waiting
        store.isMultiplayerActive = true
        store.eventSink = { [weak transport] event in
            transport?.send(event)
        }

        let transport = self.transport
        consumeTask = Task { @MainActor [weak self] in
            for await event in transport.events {
                guard let self, !Task.isCancelled else { return }
                self.handle(event)
            }
        }
        transport.start()
    }

    /// 対戦を終了する。Store を通常モードに戻し、相手陣を空にする。
    public func stop() {
        consumeTask?.cancel()
        consumeTask = nil
        transport.stop()
        store.eventSink = nil
        store.isMultiplayerActive = false
        store.resetOpponentField()
        store.opponentInfo = nil
        connectionState = .idle
        lastError = nil
    }

    @MainActor
    private func handle(_ event: DuelTransportEvent) {
        switch event {
        case .connected(let peerName):
            connectionState = .connected(peerName: peerName)
            lastError = nil
            // 接続直後(再接続時も同様): 自分の情報 → 現在の盤面を同期送信する。
            transport.send(.hello(localInfo))
            transport.send(.snapshot(store.fieldSnapshot()))
        case .received(let duelEvent):
            store.applyOpponentEvent(duelEvent)
        case .disconnected:
            // 相手陣(opponent*)は残す(再接続時に相手の snapshot で上書きされる)。
            connectionState = .disconnected
        case .protocolError(let message):
            lastError = message
        }
    }
}
