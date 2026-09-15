//
//  LoopbackDuelTransport.swift
//  YugiohDuelDiskPackage
//
//  プロセス内で完結するトランスポート。
//  - 1 台デモ用: `script` を遅延付きで再生し、「影の対戦相手」として振る舞う。
//  - テスト用: `inject` で受信イベントを手動投入し、`send` 内容は `sentEvents` に記録する。
//

import Foundation

public final class LoopbackDuelTransport: DuelTransport, @unchecked Sendable {
    /// 接続後に自動再生する「相手の操作」1 ステップ。
    public struct ScriptedStep: Sendable {
        /// 直前ステップからの待ち時間(秒)。
        public var delay: TimeInterval
        public var event: DuelEvent

        public init(delay: TimeInterval, event: DuelEvent) {
            self.delay = delay
            self.event = event
        }
    }

    public static let peerName = "Loopback"

    public let events: AsyncStream<DuelTransportEvent>
    private let continuation: AsyncStream<DuelTransportEvent>.Continuation

    /// `_sentEvents` / `scriptTask` / `_hasYieldedConnected` は `lock` 保護下でのみ触る。
    private let lock = NSLock()
    private var _sentEvents: [DuelEvent] = []
    private var scriptTask: Task<Void, Never>?
    /// `.connected` を一度でも yield したか。`stop()` はこれが true のときだけ `.disconnected` を yield する。
    private var _hasYieldedConnected = false
    private let script: [ScriptedStep]

    /// `send` で送られたイベントの記録(送信順)。
    public var sentEvents: [DuelEvent] {
        lock.lock(); defer { lock.unlock() }
        return _sentEvents
    }

    public init(script: [ScriptedStep] = []) {
        self.script = script
        let (stream, continuation) = AsyncStream<DuelTransportEvent>.makeStream()
        self.events = stream
        self.continuation = continuation
    }

    deinit {
        lock.lock()
        let task = scriptTask
        lock.unlock()
        task?.cancel()
        continuation.finish()
    }

    // MARK: - DuelTransport

    public func start() {
        lock.lock()
        _hasYieldedConnected = true
        lock.unlock()
        continuation.yield(.connected(peerName: Self.peerName))
        guard !script.isEmpty else { return }
        let steps = script
        let task = Task { [weak self] in
            for step in steps {
                if step.delay > 0 {
                    try? await Task.sleep(for: .seconds(step.delay))
                }
                guard !Task.isCancelled, let self else { return }
                self.continuation.yield(.received(step.event))
            }
        }
        lock.lock()
        let previous = scriptTask
        scriptTask = task
        lock.unlock()
        previous?.cancel()
    }

    public func stop() {
        lock.lock()
        let task = scriptTask
        scriptTask = nil
        let wasConnected = _hasYieldedConnected
        _hasYieldedConnected = false
        lock.unlock()
        task?.cancel()
        if wasConnected {
            continuation.yield(.disconnected)
        }
    }

    public func send(_ event: DuelEvent) {
        lock.lock()
        _sentEvents.append(event)
        lock.unlock()
    }

    // MARK: - テスト / デモ用

    /// 受信イベントを手動で投入する(相手からの受信をシミュレート)。
    public func inject(_ event: DuelEvent) {
        continuation.yield(.received(event))
    }

    /// トランスポートイベント(`.connected` / `.disconnected` / `.protocolError` など)を手動で投入する。
    /// 再接続やエラー通知をシミュレートするテスト用。
    public func injectTransportEvent(_ event: DuelTransportEvent) {
        if case .connected = event {
            lock.lock()
            _hasYieldedConnected = true
            lock.unlock()
        }
        continuation.yield(event)
    }

    /// 1 台デモ用スクリプト: モンスター 2 体を召喚 → 魔法 1 枚を裏で設置 → オープン。
    public static func demoScript() -> [ScriptedStep] {
        var steps: [ScriptedStep] = []
        if let taiyaki = MonsterCard.samples.first {
            steps.append(ScriptedStep(delay: 2, event: .summonMonster(slot: 2, card: .monster(taiyaki))))
        }
        steps.append(ScriptedStep(delay: 2, event: .summonMonster(slot: 1, card: .monster(MonsterCard.hitenryu))))
        if let spell = SpellCard.samples.first {
            steps.append(ScriptedStep(delay: 2, event: .setSpellOrTrap(slot: 2, card: .spell(spell))))
            steps.append(ScriptedStep(delay: 2, event: .openCard(slot: 2)))
        }
        return steps
    }
}
