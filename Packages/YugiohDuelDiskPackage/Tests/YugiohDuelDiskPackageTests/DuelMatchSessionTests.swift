//
//  DuelMatchSessionTests.swift
//  YugiohDuelDiskPackageTests
//
//  DuelMatchSession を LoopbackDuelTransport と組み合わせて検証する。
//  イベント消費は MainActor 上の Task で非同期に行われるため、条件成立までポーリングして待つ。
//

import Foundation
import Testing
@testable import YugiohDuelDiskPackage

/// 条件が成立するまで(最大 timeout 秒)待つ。成立しなければ false。
@MainActor
private func waitUntil(timeout: TimeInterval = 2, _ condition: @MainActor () -> Bool) async -> Bool {
    let deadline = Date().addingTimeInterval(timeout)
    while Date() < deadline {
        if condition() { return true }
        try? await Task.sleep(for: .milliseconds(10))
    }
    return condition()
}

@MainActor
struct DuelMatchSessionTests {
    private func makeSession(script: [LoopbackDuelTransport.ScriptedStep] = [])
        -> (DuelSessionStore, LoopbackDuelTransport, DuelMatchSession)
    {
        let store = DuelSessionStore()
        store.startNewDuel()
        let transport = LoopbackDuelTransport(script: script)
        let info = DuelPeerInfo(displayName: "自分", deviceKind: "macOS")
        let session = DuelMatchSession(store: store, transport: transport, localInfo: info)
        return (store, transport, session)
    }

    @Test func startSendsHelloThenSnapshot() async {
        let (store, transport, session) = makeSession()
        session.start()
        #expect(store.isMultiplayerActive == true)
        #expect(store.eventSink != nil)
        let ok = await waitUntil { transport.sentEvents.count >= 2 }
        #expect(ok)
        let sent = transport.sentEvents
        #expect(sent.first == .hello(session.localInfo))
        #expect(sent.count >= 2)
        if sent.count >= 2 {
            #expect(sent[1] == .snapshot(store.fieldSnapshot()))
        }
        #expect(session.connectionState == .connected(peerName: "Loopback"))
        session.stop()
    }

    @Test func injectedSummonPopulatesOpponentBackRow() async {
        let (store, transport, session) = makeSession()
        session.start()
        let monster = DuelCard.monster(MonsterCard.hitenryu)
        transport.inject(.summonMonster(slot: 2, card: monster))
        let ok = await waitUntil { store.opponentFieldBackRow[2] != nil }
        #expect(ok)
        #expect(store.opponentFieldBackRow[2] == monster)
        #expect(store.fieldBackRow[2] == nil)
        session.stop()
    }

    @Test func injectedHelloSetsOpponentInfo() async {
        let (store, transport, session) = makeSession()
        session.start()
        let info = DuelPeerInfo(displayName: "相手", deviceKind: "iOS")
        transport.inject(.hello(info))
        let ok = await waitUntil { store.opponentInfo != nil }
        #expect(ok)
        #expect(store.opponentInfo == info)
        session.stop()
    }

    @Test func localPlacementIsSentAsSummon() async {
        let (store, transport, session) = makeSession()
        session.start()
        _ = await waitUntil { transport.sentEvents.count >= 2 }
        let hitenryu = store.hand[0]
        store.selectHandCard(id: hitenryu.id)
        store.placeSelectedCardToDiskSlot(index: 1)
        #expect(transport.sentEvents.contains(.summonMonster(slot: 1, card: hitenryu)))
        session.stop()
    }

    @Test func scriptedOpponentIsApplied() async {
        let script = [
            LoopbackDuelTransport.ScriptedStep(delay: 0, event: .summonMonster(slot: 0, card: .monster(MonsterCard.hitenryu))),
            LoopbackDuelTransport.ScriptedStep(delay: 0, event: .setSpellOrTrap(slot: 0, card: .spell(SpellCard.samples[0]))),
            LoopbackDuelTransport.ScriptedStep(delay: 0, event: .openCard(slot: 0)),
        ]
        let (store, _, session) = makeSession(script: script)
        session.start()
        let ok = await waitUntil { store.opponentFieldFrontRevealed[0] == true }
        #expect(ok)
        #expect(store.opponentFieldBackRow[0] != nil)
        #expect(store.opponentFieldFrontRow[0] != nil)
        session.stop()
    }

    @Test func stopClearsOpponentRowsAndFlag() async {
        let (store, transport, session) = makeSession()
        session.start()
        transport.inject(.hello(DuelPeerInfo(displayName: "相手", deviceKind: "iOS")))
        transport.inject(.summonMonster(slot: 0, card: .monster(MonsterCard.hitenryu)))
        transport.inject(.setSpellOrTrap(slot: 1, card: .trap(TrapCard.samples[0])))
        transport.inject(.openCard(slot: 1))
        let ok = await waitUntil { store.opponentFieldFrontRevealed[1] == true }
        #expect(ok)
        session.stop()
        #expect(store.isMultiplayerActive == false)
        #expect(store.eventSink == nil)
        #expect(store.opponentInfo == nil)
        #expect(store.opponentFieldBackRow.allSatisfy { $0 == nil })
        #expect(store.opponentFieldFrontRow.allSatisfy { $0 == nil })
        #expect(store.opponentFieldFrontRevealed.allSatisfy { $0 == false })
        #expect(session.connectionState == .idle)
        // 停止後のローカル操作は送信されない
        let before = transport.sentEvents.count
        let hitenryu = store.hand[0]
        store.selectHandCard(id: hitenryu.id)
        store.placeSelectedCardToDiskSlot(index: 0)
        #expect(transport.sentEvents.count == before)
    }

    @Test func controllerLoopbackDemoStartsAndStops() async {
        let store = DuelSessionStore()
        store.startNewDuel()
        let controller = DuelMultiplayerController(store: store)
        #expect(controller.mode == .off)
        #expect(controller.connectionState == .idle)
        controller.start(mode: .loopbackDemo, displayName: "自分")
        #expect(controller.mode == .loopbackDemo)
        #expect(controller.session != nil)
        #expect(store.isMultiplayerActive == true)
        let ok = await waitUntil { controller.connectionState == .connected(peerName: "Loopback") }
        #expect(ok)
        controller.stop()
        #expect(controller.mode == .off)
        #expect(controller.session == nil)
        #expect(controller.connectionState == .idle)
        #expect(store.isMultiplayerActive == false)
    }

    @Test func localDeviceKindIsKnownValue() {
        let kind = DuelMultiplayerController.localDeviceKind()
        #expect(["visionOS", "iOS", "macOS"].contains(kind))
    }

    // MARK: - ライフサイクルの堅牢性(N3 / N5 / N7 / N10)

    /// `start()` は冪等: 2 回呼んでもトランスポートは 1 回しか開始されず、hello + snapshot も 1 組だけ。
    @Test func startIsIdempotent() async {
        let (_, transport, session) = makeSession()
        session.start()
        session.start()
        _ = await waitUntil { transport.sentEvents.count >= 2 }
        try? await Task.sleep(for: .milliseconds(50))
        #expect(transport.sentEvents.count == 2)
        #expect(session.connectionState == .connected(peerName: "Loopback"))
        session.stop()
    }

    /// controller を 2 回 start したとき、1 つ目のトランスポートへの投入は Store に届かず、
    /// `eventSink` は 2 つ目のトランスポートへ配線されている。
    @Test func controllerRestartDetachesFirstTransport() async {
        let store = DuelSessionStore()
        store.startNewDuel()
        let controller = DuelMultiplayerController(store: store)
        controller.start(mode: .loopbackDemo, displayName: "自分")
        guard let first = controller.session?.transport as? LoopbackDuelTransport else {
            Issue.record("loopback transport expected")
            return
        }
        _ = await waitUntil { first.sentEvents.count >= 2 }

        controller.start(mode: .loopbackDemo, displayName: "自分")
        guard let second = controller.session?.transport as? LoopbackDuelTransport else {
            Issue.record("loopback transport expected")
            return
        }
        #expect(first !== second)
        _ = await waitUntil { second.sentEvents.count >= 2 }

        // 1 つ目へ投入しても相手陣は変わらない
        first.inject(.summonMonster(slot: 0, card: .monster(MonsterCard.hitenryu)))
        try? await Task.sleep(for: .milliseconds(100))
        #expect(store.opponentFieldBackRow.allSatisfy { $0 == nil })

        // ローカル操作は 2 つ目へだけ送られる
        let firstCountBefore = first.sentEvents.count
        let hitenryu = store.hand[0]
        store.selectHandCard(id: hitenryu.id)
        store.placeSelectedCardToDiskSlot(index: 1)
        #expect(second.sentEvents.contains(.summonMonster(slot: 1, card: hitenryu)))
        #expect(first.sentEvents.count == firstCountBefore)
        controller.stop()
    }

    /// スクリプト再生の途中で `stop()` したら、遅延後のステップは相手陣を変えない。
    @Test func stopMidScriptDoesNotMutateOpponentRows() async {
        let script = [
            LoopbackDuelTransport.ScriptedStep(delay: 0.05, event: .summonMonster(slot: 0, card: .monster(MonsterCard.hitenryu))),
        ]
        let (store, transport, session) = makeSession(script: script)
        session.start()
        _ = await waitUntil { transport.sentEvents.count >= 2 }
        session.stop()
        try? await Task.sleep(for: .milliseconds(150))
        #expect(store.opponentFieldBackRow.allSatisfy { $0 == nil })
        #expect(store.opponentFieldFrontRow.allSatisfy { $0 == nil })
        #expect(store.isMultiplayerActive == false)
    }

    /// 現行ポリシー: トランスポートの `.disconnected` は状態を `.disconnected` にするだけで、
    /// 相手陣(opponent*)は残す(再接続時に snapshot で上書きされる)。
    @Test func transportDisconnectSetsDisconnectedStateAndKeepsOpponentRows() async {
        let (store, transport, session) = makeSession()
        session.start()
        let monster = DuelCard.monster(MonsterCard.hitenryu)
        transport.inject(.hello(DuelPeerInfo(displayName: "相手", deviceKind: "iOS")))
        transport.inject(.summonMonster(slot: 2, card: monster))
        let applied = await waitUntil { store.opponentFieldBackRow[2] != nil }
        #expect(applied)
        transport.stop() // `.disconnected` を yield する
        let disconnected = await waitUntil { session.connectionState == .disconnected }
        #expect(disconnected)
        #expect(store.opponentFieldBackRow[2] == monster)
        #expect(store.opponentInfo != nil)
        #expect(store.isMultiplayerActive == true)
        session.stop()
    }

    @Test func startNewDuelThroughLiveSessionSendsNewDuel() async {
        let (store, transport, session) = makeSession()
        session.start()
        _ = await waitUntil { transport.sentEvents.count >= 2 }
        let before = transport.sentEvents.count
        store.startNewDuel()
        #expect(transport.sentEvents.count == before + 1)
        #expect(transport.sentEvents.last == .newDuel)
        session.stop()
    }

    @Test func protocolErrorSetsLastErrorAndReconnectClearsIt() async {
        let (_, transport, session) = makeSession()
        #expect(session.lastError == nil)
        session.start()
        _ = await waitUntil { session.connectionState == .connected(peerName: "Loopback") }
        transport.injectTransportEvent(.protocolError("decode failed: test"))
        let set = await waitUntil { session.lastError != nil }
        #expect(set)
        #expect(session.lastError == "decode failed: test")

        let controller = DuelMultiplayerController(store: DuelSessionStore())
        #expect(controller.lastError == nil)

        transport.injectTransportEvent(.connected(peerName: "Loopback"))
        let cleared = await waitUntil { session.lastError == nil }
        #expect(cleared)
        // 再接続時も hello + snapshot を送り直す
        let resent = await waitUntil { transport.sentEvents.count >= 4 }
        #expect(resent)
        session.stop()
        #expect(session.lastError == nil)
    }

    @Test func controllerExposesSessionLastError() async {
        let store = DuelSessionStore()
        let controller = DuelMultiplayerController(store: store)
        controller.start(mode: .loopbackDemo, displayName: "自分")
        guard let transport = controller.session?.transport as? LoopbackDuelTransport else {
            Issue.record("loopback transport expected")
            return
        }
        transport.injectTransportEvent(.protocolError("browsing failed: test"))
        let set = await waitUntil { controller.lastError != nil }
        #expect(set)
        #expect(controller.lastError == "browsing failed: test")
        controller.stop()
        #expect(controller.lastError == nil)
    }
}
