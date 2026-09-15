//
//  DuelTransport.swift
//  YugiohDuelDiskPackage
//
//  対戦モードの通信レイヤ抽象。
//  実装は Loopback(単体デモ / テスト)と MultipeerConnectivity(実機 2 台)の 2 種。
//

import Foundation

/// トランスポートから上位(DuelMatchSession)へ流れるイベント。
public enum DuelTransportEvent: Sendable {
    case connected(peerName: String)
    case disconnected
    case received(DuelEvent)
    /// 受信データのデコード失敗(バージョン不一致 / 不正 JSON / サイズ超過)や
    /// 広告・探索の開始失敗など、接続は残るが通信内容に問題があったことの通知。
    /// 引数は人間向けの説明文(UI 表示 / ログ用)。
    case protocolError(String)
}

/// MultipeerConnectivity 接続時の役割。
/// (`MultipeerDuelTransport.Role` は本 enum の typealias。`#if canImport` ガードの外でも参照できるようここに置く)
public enum DuelMultipeerRole: Sendable, Equatable {
    /// 広告側。最初の招待を自動受諾する。
    case host
    /// 探索側。最初に見つけたピアへ自動招待する。
    case guest
}

/// 対戦相手との送受信を担うトランスポート。
/// `events` はバックグラウンドから発火し得るため、消費側で MainActor へ載せ替えること。
/// `events` は単一消費者・使い切りの `AsyncStream`。消費側の Task をキャンセルするとストリームは終了し、
/// 以後の yield は捨てられる。再接続したい場合はトランスポートごと作り直すこと
/// (`DuelMultiplayerController.start(mode:displayName:)` はそのようにしている)。
public protocol DuelTransport: AnyObject, Sendable {
    var events: AsyncStream<DuelTransportEvent> { get }
    func start()
    func stop()
    func send(_ event: DuelEvent)
}
