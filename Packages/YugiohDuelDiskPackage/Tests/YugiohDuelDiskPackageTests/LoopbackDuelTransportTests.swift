//
//  LoopbackDuelTransportTests.swift
//  YugiohDuelDiskPackageTests
//
//  LoopbackDuelTransport(プロセス内トランスポート)の挙動を検証する。
//

import Foundation
import Testing
@testable import YugiohDuelDiskPackage

struct LoopbackDuelTransportTests {
    @Test func startEmitsConnected() async {
        let transport = LoopbackDuelTransport()
        transport.start()
        var iterator = transport.events.makeAsyncIterator()
        let first = await iterator.next()
        guard case .connected(let peerName) = first else {
            Issue.record("connected expected, got \(String(describing: first))")
            return
        }
        #expect(peerName == "Loopback")
    }

    @Test func injectDeliversReceived() async {
        let transport = LoopbackDuelTransport()
        transport.start()
        transport.inject(.openCard(slot: 1))
        var iterator = transport.events.makeAsyncIterator()
        _ = await iterator.next() // connected
        let second = await iterator.next()
        #expect({
            if case .received(.openCard(slot: 1)) = second { return true }
            return false
        }())
    }

    @Test func sendRecordsEvents() {
        let transport = LoopbackDuelTransport()
        #expect(transport.sentEvents.isEmpty)
        transport.send(.newDuel)
        transport.send(.openCard(slot: 3))
        #expect(transport.sentEvents == [.newDuel, .openCard(slot: 3)])
    }

    @Test func stopEmitsDisconnected() async {
        let transport = LoopbackDuelTransport()
        transport.start()
        transport.stop()
        var iterator = transport.events.makeAsyncIterator()
        _ = await iterator.next() // connected
        let second = await iterator.next()
        #expect({
            if case .disconnected = second { return true }
            return false
        }())
    }

    /// `.connected` を yield していなければ `stop()` は `.disconnected` を yield しない。
    @Test func stopWithoutStartDoesNotEmitDisconnected() async {
        let transport = LoopbackDuelTransport()
        transport.stop()
        transport.inject(.openCard(slot: 2))
        var iterator = transport.events.makeAsyncIterator()
        let first = await iterator.next()
        #expect({
            if case .received(.openCard(slot: 2)) = first { return true }
            return false
        }())
    }

    @Test func injectTransportEventDeliversAsIs() async {
        let transport = LoopbackDuelTransport()
        transport.injectTransportEvent(.protocolError("boom"))
        var iterator = transport.events.makeAsyncIterator()
        let first = await iterator.next()
        #expect({
            if case .protocolError("boom") = first { return true }
            return false
        }())
    }

    @Test func scriptIsReplayedAfterConnect() async {
        let script = [
            LoopbackDuelTransport.ScriptedStep(delay: 0, event: .openCard(slot: 0)),
            LoopbackDuelTransport.ScriptedStep(delay: 0.01, event: .newDuel),
        ]
        let transport = LoopbackDuelTransport(script: script)
        transport.start()
        var iterator = transport.events.makeAsyncIterator()
        _ = await iterator.next() // connected
        let a = await iterator.next()
        let b = await iterator.next()
        #expect({
            if case .received(.openCard(slot: 0)) = a { return true }
            return false
        }())
        #expect({
            if case .received(.newDuel) = b { return true }
            return false
        }())
    }

    @Test func demoScriptSummonsTwoMonstersAndOneSpellThenOpens() {
        let script = LoopbackDuelTransport.demoScript()
        let summons = script.filter { if case .summonMonster = $0.event { return true } else { return false } }
        let sets = script.filter { if case .setSpellOrTrap = $0.event { return true } else { return false } }
        let opens = script.filter { if case .openCard = $0.event { return true } else { return false } }
        #expect(summons.count == 2)
        #expect(sets.count == 1)
        #expect(opens.count == 1)
        #expect(script.allSatisfy { $0.delay > 0 })
    }
}
