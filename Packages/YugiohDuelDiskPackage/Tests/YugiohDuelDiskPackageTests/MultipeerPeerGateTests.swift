//
//  MultipeerPeerGateTests.swift
//  YugiohDuelDiskPackageTests
//
//  MultipeerDuelTransport の「最大 2 名」判定(MultipeerPeerGate)を、実機なしで検証する。
//  ピア ID は String で代用する。
//

import Foundation
import Testing
@testable import YugiohDuelDiskPackage

struct MultipeerPeerGateTests {
    typealias Gate = MultipeerPeerGate<String>

    // MARK: - canAccept(pending:connected:)

    @Test func canAcceptOnlyWhenFree() {
        #expect(Gate.canAccept(pending: nil, connected: nil) == true)
        #expect(Gate.canAccept(pending: "A", connected: nil) == false)      // 既に候補あり
        #expect(Gate.canAccept(pending: nil, connected: "A") == false)      // 既に接続済み
        #expect(Gate.canAccept(pending: "A", connected: "B") == false)
    }

    // MARK: - host: 招待受諾 / guest: 招待送信

    @Test func acceptRegistersPendingAndBlocksSecondPeer() {
        var gate = Gate()
        #expect(gate.canAccept)
        #expect(gate.accept("A") == true)
        #expect(gate.pending == "A")
        #expect(gate.connected == nil)
        // 候補がいる間は 2 人目を受け付けない(接続前の competing invite)
        #expect(gate.accept("B") == false)
        #expect(gate.pending == "A")
    }

    @Test func acceptIsBlockedWhileConnected() {
        var gate = Gate()
        gate.accept("A")
        #expect(gate.markConnected("A") == .accepted)
        #expect(gate.connected == "A")
        #expect(gate.pending == nil)
        #expect(gate.accept("B") == false)
    }

    // MARK: - MCSession 状態遷移

    @Test func connectedPendingPeerBecomesConnected() {
        var gate = Gate()
        gate.accept("A")
        gate.markConnecting("A")
        #expect(gate.markConnected("A") == .accepted)
        #expect(gate.connected == "A")
        // 同じピアの重複通知は無視
        #expect(gate.markConnected("A") == .duplicate)
    }

    @Test func connectedThirdPeerIsRejected() {
        var gate = Gate()
        gate.accept("A")
        #expect(gate.markConnected("A") == .accepted)
        #expect(gate.markConnected("B") == .rejected)
        #expect(gate.connected == "A")
    }

    @Test func connectedDifferentPeerWhilePendingIsRejected() {
        var gate = Gate()
        gate.accept("A")
        #expect(gate.markConnected("B") == .rejected)
        #expect(gate.pending == "A")
        #expect(gate.connected == nil)
    }

    @Test func connectingRegistersPendingOnlyWhenFree() {
        var gate = Gate()
        gate.markConnecting("A")
        #expect(gate.pending == "A")
        gate.markConnecting("B")
        #expect(gate.pending == "A")
    }

    @Test func disconnectOfConnectedPeerFreesGate() {
        var gate = Gate()
        gate.accept("A")
        _ = gate.markConnected("A")
        let result = gate.markDisconnected("A")
        #expect(result.wasConnected == true)
        #expect(result.wasPending == false)
        #expect(result.isEmpty == true)
        #expect(gate.canAccept)
        // 再接続(同じピアでも別ピアでも)を受け付ける
        #expect(gate.accept("B") == true)
    }

    @Test func failedInvitationClearsPendingWithoutDisconnect() {
        var gate = Gate()
        gate.accept("A")
        let result = gate.markDisconnected("A")
        #expect(result.wasConnected == false)
        #expect(result.wasPending == true)
        #expect(result.isEmpty == true)
        #expect(gate.canAccept)
    }

    @Test func disconnectOfUnknownPeerIsNoop() {
        var gate = Gate()
        gate.accept("A")
        _ = gate.markConnected("A")
        let result = gate.markDisconnected("Z")
        #expect(result.wasConnected == false)
        #expect(result.wasPending == false)
        #expect(result.isEmpty == false)
        #expect(gate.connected == "A")
    }

    @Test func forgetPendingOnlyClearsMatchingCandidate() {
        var gate = Gate()
        gate.accept("A")
        gate.forgetPending("B")
        #expect(gate.pending == "A")
        gate.forgetPending("A")
        #expect(gate.pending == nil)
        #expect(gate.canAccept)
    }

    @Test func resetClearsEverything() {
        var gate = Gate()
        gate.accept("A")
        _ = gate.markConnected("A")
        gate.reset()
        #expect(gate == Gate())
    }
}

#if canImport(MultipeerConnectivity)
/// MCPeerID の displayName 制約(空不可 / UTF-8 63 バイト以内)を多バイト文字でも守る。
struct MultipeerDisplayNameTests {
    @Test func multibyteNameIsTruncatedOnCharacterBoundary() {
        let name = String(repeating: "杉", count: 40) // 120 バイト
        let safe = MultipeerDuelTransport.sanitizedDisplayName(name)
        #expect(safe.utf8.count <= 63)
        #expect(safe.utf8.count == 63) // 21 文字 × 3 バイト
        #expect(safe.allSatisfy { $0 == "杉" })
    }

    @Test func fourByteScalarsDoNotOverflow() {
        let name = String(repeating: "😀", count: 20) // 80 バイト
        let safe = MultipeerDuelTransport.sanitizedDisplayName(name)
        #expect(safe.utf8.count <= 63)
        #expect(safe.utf8.count == 60)
    }

    @Test func emptyOrWhitespaceFallsBack() {
        #expect(MultipeerDuelTransport.sanitizedDisplayName("") == "Duelist")
        #expect(MultipeerDuelTransport.sanitizedDisplayName("  \n") == "Duelist")
        #expect(MultipeerDuelTransport.sanitizedDisplayName("  Yugo ") == "Yugo")
    }

    @Test func transportInitDoesNotCrashWithLongMultibyteName() {
        let transport = MultipeerDuelTransport(role: .host, displayName: String(repeating: "山", count: 100))
        #expect(transport.connectedPeerName == nil)
        #expect(transport.role == .host)
        #expect(transport.pairName == "")
    }

    @Test func transportSanitizesPairName() {
        #expect(MultipeerDuelTransport.sanitizedPairName("  team-a \n") == "team-a")
        #expect(MultipeerDuelTransport.sanitizedPairName(String(repeating: "杉", count: 30)).count == 20)
        #expect(MultipeerDuelTransport.sanitizedPairName("") == "")

        let transport = MultipeerDuelTransport(role: .guest, displayName: "Guest", pairName: " 赤チーム ")
        #expect(transport.pairName == "赤チーム")
    }
}
#endif
