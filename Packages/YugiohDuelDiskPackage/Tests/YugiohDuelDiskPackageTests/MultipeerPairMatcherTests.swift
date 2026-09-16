//
//  MultipeerPairMatcherTests.swift
//  YugiohDuelDiskPackageTests
//
//  MultipeerDuelTransport の「ペア名」判定(MultipeerPairMatcher)を、実機なしで検証する。
//  discoveryInfo(host の広告)/ 招待 context(guest の招待)の両経路と、整形・一致判定を確認する。
//

import Foundation
import Testing
@testable import YugiohDuelDiskPackage

struct MultipeerPairMatcherTests {
    typealias Matcher = MultipeerPairMatcher

    // MARK: - sanitizedPairName

    @Test func sanitizeTrimsWhitespaceAndNewlines() {
        #expect(Matcher.sanitizedPairName("  team-a \n") == "team-a")
        #expect(Matcher.sanitizedPairName("") == "")
        #expect(Matcher.sanitizedPairName("  \n\t") == "")
    }

    @Test func sanitizeCapsAtTwentyCharacters() {
        let long = String(repeating: "a", count: 30)
        #expect(Matcher.sanitizedPairName(long).count == 20)
        // Character 単位で数える(日本語も 1 文字 = 1 Character)
        let japanese = String(repeating: "杉", count: 25)
        let capped = Matcher.sanitizedPairName(japanese)
        #expect(capped.count == 20)
        #expect(capped.allSatisfy { $0 == "杉" })
        // 20 文字ちょうどはそのまま
        let exact = String(repeating: "b", count: 20)
        #expect(Matcher.sanitizedPairName(exact) == exact)
    }

    @Test func sanitizeKeepsJapaneseAsIs() {
        #expect(Matcher.sanitizedPairName("赤チーム") == "赤チーム")
    }

    // MARK: - discoveryInfo (host の広告 → guest)

    @Test func pairNameFromDiscoveryInfoMissingIsEmpty() {
        #expect(Matcher.pairName(fromDiscoveryInfo: nil) == "")
        #expect(Matcher.pairName(fromDiscoveryInfo: [:]) == "")
        #expect(Matcher.pairName(fromDiscoveryInfo: ["name": "Host"]) == "")
    }

    @Test func pairNameFromDiscoveryInfoReadsPairKey() {
        #expect(Matcher.pairName(fromDiscoveryInfo: ["pair": "A", "name": "Host"]) == "A")
        #expect(Matcher.pairName(fromDiscoveryInfo: ["pair": " A "]) == "A")
    }

    @Test func discoveryInfoContainsSanitizedPairAndName() {
        let info = Matcher.discoveryInfo(pairName: " 赤チーム ", displayName: "Vision Pro")
        #expect(info["pair"] == "赤チーム")
        #expect(info["name"] == "Vision Pro")
        #expect(Matcher.pairName(fromDiscoveryInfo: info) == "赤チーム")
    }

    // MARK: - 招待 context (guest の招待 → host)

    @Test func invitationContextRoundTrip() {
        let context = Matcher.invitationContext(for: "team-a")
        #expect(Matcher.pairName(fromInvitationContext: context) == "team-a")
    }

    @Test func invitationContextRoundTripWithJapanese() {
        let context = Matcher.invitationContext(for: "赤チーム")
        #expect(context == Data("赤チーム".utf8))
        #expect(Matcher.pairName(fromInvitationContext: context) == "赤チーム")
    }

    @Test func invitationContextIsSanitized() {
        let context = Matcher.invitationContext(for: "  team-a\n")
        #expect(Matcher.pairName(fromInvitationContext: context) == "team-a")
    }

    @Test func pairNameFromInvitationContextMissingIsEmpty() {
        #expect(Matcher.pairName(fromInvitationContext: nil) == "")
        #expect(Matcher.pairName(fromInvitationContext: Data()) == "")
        // ペア名なしの guest からの context は空 Data
        #expect(Matcher.invitationContext(for: "") == Data())
    }

    @Test func pairNameFromInvalidUTF8ContextIsEmpty() {
        let invalid = Data([0xFF, 0xFE, 0xC0])
        #expect(Matcher.pairName(fromInvitationContext: invalid) == "")
    }

    // MARK: - matches

    @Test func matchesRequiresExactEquality() {
        #expect(Matcher.matches(local: "A", remote: "A") == true)
        #expect(Matcher.matches(local: "A", remote: "B") == false)
        #expect(Matcher.matches(local: "A", remote: "a") == false) // 大文字小文字も区別
        #expect(Matcher.matches(local: "赤チーム", remote: "赤チーム") == true)
    }

    @Test func emptyMatchesOnlyEmpty() {
        #expect(Matcher.matches(local: "", remote: "") == true)
        #expect(Matcher.matches(local: "", remote: "A") == false)
        #expect(Matcher.matches(local: "A", remote: "") == false)
    }

    @Test func matchesSanitizesBothSides() {
        #expect(Matcher.matches(local: " A ", remote: "A\n") == true)
        // 21 文字以上は 20 文字に丸めてから比較する
        let base = String(repeating: "x", count: 20)
        #expect(Matcher.matches(local: base + "1", remote: base + "2") == true)
    }

    // MARK: - 両経路の結合(host の広告 ↔ guest の招待)

    @Test func hostAndGuestWithSamePairNameMatchThroughBothChannels() {
        let hostInfo = Matcher.discoveryInfo(pairName: "team-a", displayName: "Host")
        let guestContext = Matcher.invitationContext(for: "team-a")
        // guest 側: 広告のペア名と自分のペア名を比較
        #expect(Matcher.matches(local: "team-a", remote: Matcher.pairName(fromDiscoveryInfo: hostInfo)))
        // host 側: 招待 context のペア名と自分のペア名を比較
        #expect(Matcher.matches(local: "team-a", remote: Matcher.pairName(fromInvitationContext: guestContext)))
    }

    @Test func hostAndGuestWithDifferentPairNamesDoNotMatch() {
        let hostInfo = Matcher.discoveryInfo(pairName: "team-a", displayName: "Host")
        let guestContext = Matcher.invitationContext(for: "team-b")
        #expect(Matcher.matches(local: "team-b", remote: Matcher.pairName(fromDiscoveryInfo: hostInfo)) == false)
        #expect(Matcher.matches(local: "team-a", remote: Matcher.pairName(fromInvitationContext: guestContext)) == false)
    }
}
