//
//  DuelEventCodableTests.swift
//  YugiohDuelDiskPackageTests
//
//  DuelEvent / DuelWireCodec の JSON 往復と、バージョン拒否を検証する。
//

import Foundation
import Testing
@testable import YugiohDuelDiskPackage

struct DuelEventCodableTests {
    private func roundTrip(_ event: DuelEvent) throws -> DuelEvent {
        let data = try DuelWireCodec.encode(event)
        return try DuelWireCodec.decode(data)
    }

    @Test func helloRoundTrip() throws {
        let event = DuelEvent.hello(DuelPeerInfo(displayName: "杉山", deviceKind: "visionOS"))
        #expect(try roundTrip(event) == event)
    }

    @Test func snapshotRoundTrip() throws {
        let hitenryu = DuelCard.monster(MonsterCard.hitenryu)
        let spell = DuelCard.spell(SpellCard.samples[0])
        let snapshot = DuelFieldSnapshot(
            backRow: [hitenryu, nil, nil, nil, nil],
            frontRow: [nil, spell, nil, nil, nil],
            frontRevealed: [false, true, false, false, false]
        )
        let decoded = try roundTrip(.snapshot(snapshot))
        #expect(decoded == .snapshot(snapshot))
        guard case .snapshot(let s) = decoded else {
            Issue.record("snapshot expected")
            return
        }
        #expect(s.backRow.count == 5)
        #expect(s.backRow[0]?.id == hitenryu.id)
        #expect(s.frontRow[1]?.id == spell.id)
        #expect(s.frontRevealed == [false, true, false, false, false])
    }

    @Test func summonHitenryuRoundTripPreservesFields() throws {
        let monster = MonsterCard.hitenryu
        let decoded = try roundTrip(.summonMonster(slot: 3, card: .monster(monster)))
        guard case .summonMonster(let slot, .monster(let card)) = decoded else {
            Issue.record("summonMonster expected")
            return
        }
        #expect(slot == 3)
        #expect(card.id == monster.id)
        #expect(card.name == monster.name)
        #expect(card.attack == monster.attack)
        #expect(card.defense == monster.defense)
        #expect(card.isRare == monster.isRare)
        #expect(card.summonModel == .hitenryu)
    }

    @Test func summonTaiyakiRoundTripPreservesFlavor() throws {
        for monster in MonsterCard.samples {
            let decoded = try roundTrip(.summonMonster(slot: 0, card: .monster(monster)))
            guard case .summonMonster(_, .monster(let card)) = decoded else {
                Issue.record("summonMonster expected")
                return
            }
            #expect(card.flavor == monster.flavor)
            #expect(card.summonModel == .taiyaki(monster.flavor))
            #expect(card.artVariant == monster.artVariant)
        }
    }

    @Test func setSpellRoundTrip() throws {
        let spell = SpellCard.samples[0]
        let decoded = try roundTrip(.setSpellOrTrap(slot: 1, card: .spell(spell)))
        guard case .setSpellOrTrap(let slot, .spell(let card)) = decoded else {
            Issue.record("setSpellOrTrap(spell) expected")
            return
        }
        #expect(slot == 1)
        #expect(card.id == spell.id)
        #expect(card.name == spell.name)
        #expect(card.symbolName == spell.symbolName)
    }

    @Test func setTrapRoundTrip() throws {
        let trap = TrapCard.samples[1]
        let decoded = try roundTrip(.setSpellOrTrap(slot: 4, card: .trap(trap)))
        guard case .setSpellOrTrap(let slot, .trap(let card)) = decoded else {
            Issue.record("setSpellOrTrap(trap) expected")
            return
        }
        #expect(slot == 4)
        #expect(card.id == trap.id)
        #expect(card.name == trap.name)
        #expect(card.text == trap.text)
    }

    @Test func openCardRoundTrip() throws {
        #expect(try roundTrip(.openCard(slot: 2)) == .openCard(slot: 2))
    }

    @Test func removeCardRoundTrip() throws {
        #expect(try roundTrip(.removeCard(row: .back, slot: 0)) == .removeCard(row: .back, slot: 0))
        #expect(try roundTrip(.removeCard(row: .front, slot: 4)) == .removeCard(row: .front, slot: 4))
    }

    @Test func newDuelRoundTrip() throws {
        #expect(try roundTrip(.newDuel) == .newDuel)
    }

    @Test func encodedMessageCarriesCurrentVersion() throws {
        let data = try DuelWireCodec.encode(.newDuel)
        let message = try JSONDecoder().decode(DuelWireMessage.self, from: data)
        #expect(message.version == DuelWireMessage.currentVersion)
    }

    @Test func unsupportedVersionIsRejected() throws {
        let message = DuelWireMessage(version: DuelWireMessage.currentVersion + 1, event: .newDuel)
        let data = try JSONEncoder().encode(message)
        #expect(throws: DuelWireCodec.CodecError.unsupportedVersion(DuelWireMessage.currentVersion + 1)) {
            try DuelWireCodec.decode(data)
        }
    }

    @Test func garbageDataIsRejected() {
        #expect(throws: (any Error).self) {
            try DuelWireCodec.decode(Data("not json".utf8))
        }
    }

    /// バージョンはペイロードより先に検証される: 未知の event を含んでいても `unsupportedVersion` になる。
    @Test func unsupportedVersionIsReportedBeforePayloadErrors() {
        let data = Data(#"{"version":99,"event":{"bogusCase":{}}}"#.utf8)
        #expect(throws: DuelWireCodec.CodecError.unsupportedVersion(99)) {
            try DuelWireCodec.decode(data)
        }
    }

    @Test func unknownEventCaseWithCurrentVersionThrowsDecodingError() {
        let data = Data(#"{"version":1,"event":{"bogusCase":{}}}"#.utf8)
        #expect(throws: DecodingError.self) {
            try DuelWireCodec.decode(data)
        }
    }

    @Test func missingVersionThrowsDecodingError() {
        let data = Data(#"{"event":{"newDuel":{}}}"#.utf8)
        #expect(throws: DecodingError.self) {
            try DuelWireCodec.decode(data)
        }
    }

    @Test func placedCardContextIsCodable() throws {
        let contexts: [PlacedCardContext] = [.diskSlot(0), .spellSlot(1), .fieldBack(2), .fieldFront(3)]
        let data = try JSONEncoder().encode(contexts)
        let decoded = try JSONDecoder().decode([PlacedCardContext].self, from: data)
        #expect(decoded == contexts)
    }
}
