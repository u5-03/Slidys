//
//  DuelMultiplayerController.swift
//  YugiohDuelDiskPackage
//
//  対戦モードの入口(ファサード)。visionOS の ImmersiveSpace と iPhone の 2D ボード UI が
//  共通で使う。モードに応じたトランスポートを組み立て、`DuelMatchSession` を管理する。
//

import Foundation
import Observation

@Observable
public final class DuelMultiplayerController: @unchecked Sendable {
    public enum Mode: Sendable, Equatable {
        /// 対戦オフ(通常の 1 人モード)
        case off
        /// 1 台デモ: Loopback + スクリプト再生の「影の対戦相手」
        case loopbackDemo
        /// 実機 2 台: MultipeerConnectivity
        case multipeer(DuelMultipeerRole)
    }

    public private(set) var mode: Mode = .off
    public private(set) var session: DuelMatchSession?
    /// 現在の対戦のペア名(整形済み)。Multipeer モード以外(off / 1 台デモ)では "" になる。
    public private(set) var pairName: String = ""

    @ObservationIgnored private let store: DuelSessionStore

    public var connectionState: DuelMatchSession.ConnectionState {
        session?.connectionState ?? .idle
    }

    /// 直近のプロトコルエラー(セッションがなければ nil)。UI での通知表示用。
    public var lastError: String? {
        session?.lastError
    }

    public init(store: DuelSessionStore) {
        self.store = store
    }

    /// 指定モードで対戦を開始する。既に開始済みのセッションがあれば先に停止する。
    /// `pairName` は Multipeer モードでのみ使い、同じペア名を入力した相手とだけ接続する("" = ペア名なし)。
    public func start(mode: Mode, displayName: String, pairName: String = "") {
        stop()
        guard mode != .off else { return }

        let transport: any DuelTransport
        var resolvedPairName = ""
        switch mode {
        case .off:
            return
        case .loopbackDemo:
            transport = LoopbackDuelTransport(script: LoopbackDuelTransport.demoScript())
        case .multipeer(let role):
            #if canImport(MultipeerConnectivity)
            let multipeer = MultipeerDuelTransport(role: role, displayName: displayName, pairName: pairName)
            resolvedPairName = multipeer.pairName
            transport = multipeer
            #else
            return
            #endif
        }

        let localInfo = DuelPeerInfo(displayName: displayName, deviceKind: Self.localDeviceKind())
        let session = DuelMatchSession(store: store, transport: transport, localInfo: localInfo)
        self.session = session
        self.mode = mode
        self.pairName = resolvedPairName
        session.start()
    }

    /// 対戦を停止し、通常モードへ戻す。
    public func stop() {
        session?.stop()
        session = nil
        mode = .off
        pairName = ""
    }

    /// 実行中デバイスの種別("visionOS" / "iOS" / "macOS")。
    public static func localDeviceKind() -> String {
        #if os(visionOS)
        return "visionOS"
        #elseif os(iOS)
        return "iOS"
        #elseif os(macOS)
        return "macOS"
        #else
        return "unknown"
        #endif
    }
}
