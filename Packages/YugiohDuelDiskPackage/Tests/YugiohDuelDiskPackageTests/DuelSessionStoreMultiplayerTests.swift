//
//  DuelSessionStoreMultiplayerTests.swift
//  YugiohDuelDiskPackageTests
//
//  DuelSessionStore の対戦拡張(eventSink 発火 / applyOpponentEvent / fieldSnapshot)を検証する。
//  `startNewDuel()` の固定手札: [0] 緋天竜 / [1..3] たい焼き / [4] 魔法 / [5] トラップ。
//

import Foundation
import Testing
@testable import YugiohDuelDiskPackage

struct DuelSessionStoreMultiplayerTests {
    /// startNewDuel 済みで、eventSink の記録を始めた Store を返す(startNewDuel 自体の .newDuel は含まない)。
    private func makeRecordingStore() -> (DuelSessionStore, () -> [DuelEvent]) {
        let store = DuelSessionStore()
        store.startNewDuel()
        final class Box { var events: [DuelEvent] = [] }
        let box = Box()
        store.eventSink = { box.events.append($0) }
        return (store, { box.events })
    }

    // MARK: - eventSink

    @Test func initialOpponentStateIsEmpty() {
        let store = DuelSessionStore()
        #expect(store.opponentFieldBackRow.count == 5)
        #expect(store.opponentFieldBackRow.allSatisfy { $0 == nil })
        #expect(store.opponentFieldFrontRow.count == 5)
        #expect(store.opponentFieldFrontRevealed == [false, false, false, false, false])
        #expect(store.opponentInfo == nil)
        #expect(store.isMultiplayerActive == false)
        #expect(store.eventSink == nil)
    }

    @Test func startNewDuelEmitsNewDuel() {
        let store = DuelSessionStore()
        var received: [DuelEvent] = []
        store.eventSink = { received.append($0) }
        store.startNewDuel()
        #expect(received == [.newDuel])
    }

    @Test func placeSelectedMonsterEmitsSummon() {
        let (store, events) = makeRecordingStore()
        let hitenryu = store.hand[0]
        #expect(hitenryu.kind == .monster)
        store.selectHandCard(id: hitenryu.id)
        store.placeSelectedCardToDiskSlot(index: 2)
        #expect(events() == [.summonMonster(slot: 2, card: hitenryu)])
    }

    @Test func rejectedPlacementDoesNotEmit() {
        let (store, events) = makeRecordingStore()
        let spell = store.hand[4]
        store.selectHandCard(id: spell.id)
        store.placeSelectedCardToDiskSlot(index: 0) // 魔法は召喚スロット不可
        #expect(events().isEmpty)
        store.placeSelectedCardToSpellSlot(index: 99) // 範囲外
        #expect(events().isEmpty)
    }

    @Test func summonRightHandCardEmitsSummon() {
        let (store, events) = makeRecordingStore()
        let hitenryu = store.hand[0]
        store.selectHandCard(id: hitenryu.id)
        store.moveSelectedCardToRightHand()
        let ok = store.summonRightHandCardToDiskSlot(index: 4)
        #expect(ok)
        #expect(events() == [.summonMonster(slot: 4, card: hitenryu)])
    }

    @Test func placeSelectedSpellEmitsSet() {
        let (store, events) = makeRecordingStore()
        let spell = store.hand[4]
        #expect(spell.kind == .spell)
        store.selectHandCard(id: spell.id)
        store.placeSelectedCardToSpellSlot(index: 1)
        #expect(events() == [.setSpellOrTrap(slot: 1, card: spell)])
    }

    @Test func placeRightHandTrapEmitsSet() {
        let (store, events) = makeRecordingStore()
        let trap = store.hand[5]
        #expect(trap.kind == .trap)
        store.selectHandCard(id: trap.id)
        store.moveSelectedCardToRightHand()
        let ok = store.placeRightHandCardToSpellSlot(index: 3)
        #expect(ok)
        #expect(events() == [.setSpellOrTrap(slot: 3, card: trap)])
    }

    @Test func openPlacedCardEmitsOpenOnlyWhenRevealing() {
        let (store, events) = makeRecordingStore()
        let spell = store.hand[4]
        store.selectHandCard(id: spell.id)
        store.placeSelectedCardToSpellSlot(index: 1)
        store.openPlacedCard(at: .fieldFront(1))
        #expect(events() == [.setSpellOrTrap(slot: 1, card: spell), .openCard(slot: 1)])
        // 既に表 → 再オープンは発火しない
        store.openPlacedCard(at: .spellSlot(1))
        #expect(events().count == 2)
        // 空スロット → 発火しない
        store.openPlacedCard(at: .fieldFront(0))
        #expect(events().count == 2)
        // モンスターは発火しない
        store.openPlacedCard(at: .fieldBack(0))
        #expect(events().count == 2)
    }

    @Test func removePlacedCardEmitsRemoveWithRow() {
        let (store, events) = makeRecordingStore()
        store.removePlacedCard(at: .diskSlot(0))
        store.removePlacedCard(at: .fieldBack(1))
        store.removePlacedCard(at: .spellSlot(2))
        store.removePlacedCard(at: .fieldFront(3))
        #expect(events() == [
            .removeCard(row: .back, slot: 0),
            .removeCard(row: .back, slot: 1),
            .removeCard(row: .front, slot: 2),
            .removeCard(row: .front, slot: 3),
        ])
        store.removePlacedCard(at: .diskSlot(99)) // 範囲外は発火しない
        #expect(events().count == 4)
    }

    @Test func nilEventSinkIsSafe() {
        let store = DuelSessionStore()
        store.startNewDuel()
        store.eventSink = nil
        let hitenryu = store.hand[0]
        store.selectHandCard(id: hitenryu.id)
        store.placeSelectedCardToDiskSlot(index: 0)
        #expect(store.fieldBackRow[0]?.id == hitenryu.id)
    }

    // MARK: - applyOpponentEvent

    @Test func applyHelloSetsOpponentInfo() {
        let store = DuelSessionStore()
        let info = DuelPeerInfo(displayName: "相手", deviceKind: "iOS")
        store.applyOpponentEvent(.hello(info))
        #expect(store.opponentInfo == info)
    }

    @Test func applySnapshotReplacesRows() {
        let store = DuelSessionStore()
        let monster = DuelCard.monster(MonsterCard.hitenryu)
        let trap = DuelCard.trap(TrapCard.samples[0])
        let snapshot = DuelFieldSnapshot(
            backRow: [nil, monster, nil, nil, nil],
            frontRow: [nil, nil, nil, trap, nil],
            frontRevealed: [false, false, false, true, false]
        )
        store.applyOpponentEvent(.snapshot(snapshot))
        #expect(store.opponentFieldBackRow == snapshot.backRow)
        #expect(store.opponentFieldFrontRow == snapshot.frontRow)
        #expect(store.opponentFieldFrontRevealed == snapshot.frontRevealed)
    }

    /// 行数が `diskSlotCount` と一致しないスナップショットは(短くても長くても)イベントごと無視する。
    @Test func applySnapshotWithWrongRowCountsIsIgnored() {
        let store = DuelSessionStore()
        let monster = DuelCard.monster(MonsterCard.hitenryu)
        let existing = DuelCard.monster(MonsterCard.samples[0])
        store.applyOpponentEvent(.summonMonster(slot: 4, card: existing))

        let shorter = DuelFieldSnapshot(backRow: [monster], frontRow: [], frontRevealed: [true])
        store.applyOpponentEvent(.snapshot(shorter))
        #expect(store.opponentFieldBackRow == [nil, nil, nil, nil, existing])
        #expect(store.opponentFieldFrontRow.allSatisfy { $0 == nil })
        #expect(store.opponentFieldFrontRevealed.allSatisfy { $0 == false })

        let longer = DuelFieldSnapshot(
            backRow: [monster, nil, nil, nil, nil, nil],
            frontRow: [nil, nil, nil, nil, nil],
            frontRevealed: [false, false, false, false, false]
        )
        store.applyOpponentEvent(.snapshot(longer))
        #expect(store.opponentFieldBackRow == [nil, nil, nil, nil, existing])

        let revealedMismatch = DuelFieldSnapshot(
            backRow: [monster, nil, nil, nil, nil],
            frontRow: [nil, nil, nil, nil, nil],
            frontRevealed: [true]
        )
        store.applyOpponentEvent(.snapshot(revealedMismatch))
        #expect(store.opponentFieldBackRow == [nil, nil, nil, nil, existing])
        #expect(store.opponentFieldBackRow.count == 5)
        #expect(store.opponentFieldFrontRow.count == 5)
        #expect(store.opponentFieldFrontRevealed.count == 5)
    }

    // MARK: - applyOpponentEvent: 受信値の無害化(N1 / N6 / N8)

    @Test func applySummonClampsLevelAndStatsAndTruncatesStrings() {
        let store = DuelSessionStore()
        let longName = String(repeating: "あ", count: 1_000)
        let negative = MonsterCard(
            name: longName, attribute: "炎", level: -1, species: "竜", text: longName,
            attack: -5, defense: 1_000_000, artVariant: 7
        )
        store.applyOpponentEvent(.summonMonster(slot: 0, card: .monster(negative)))
        guard case .monster(let stored) = store.opponentFieldBackRow[0] else {
            Issue.record("monster expected")
            return
        }
        #expect(stored.id == negative.id)
        #expect(stored.level == 0)
        #expect(stored.attack == 0)
        #expect(stored.defense == 99_999)
        #expect(stored.artVariant == 1)
        #expect(stored.name.count == 200)
        #expect(stored.text.count == 200)

        let huge = MonsterCard(name: "x", attribute: "x", level: 99, species: "x", text: "x", attack: 1, defense: 1)
        store.applyOpponentEvent(.summonMonster(slot: 1, card: .monster(huge)))
        guard case .monster(let storedHuge) = store.opponentFieldBackRow[1] else {
            Issue.record("monster expected")
            return
        }
        #expect(storedHuge.level == 12)
        #expect(storedHuge.attack == 1)
    }

    @Test func applySnapshotSanitizesCards() {
        let store = DuelSessionStore()
        let monster = MonsterCard(name: "m", attribute: "a", level: 100_000_000, species: "s", text: "t", attack: 1, defense: 1)
        let spell = SpellCard(name: String(repeating: "s", count: 500), text: "t")
        let snapshot = DuelFieldSnapshot(
            backRow: [.monster(monster), nil, nil, nil, nil],
            frontRow: [nil, .spell(spell), nil, nil, nil],
            frontRevealed: [false, false, false, false, false]
        )
        store.applyOpponentEvent(.snapshot(snapshot))
        guard case .monster(let m) = store.opponentFieldBackRow[0], case .spell(let s) = store.opponentFieldFrontRow[1] else {
            Issue.record("sanitized cards expected")
            return
        }
        #expect(m.level == 12)
        #expect(s.name.count == 200)
    }

    @Test func sanitizedForWireKeepsIdentityAndModel() {
        let card = DuelCard.monster(MonsterCard.hitenryu)
        let sanitized = card.sanitizedForWire()
        #expect(sanitized == card)
        guard case .monster(let m) = sanitized else { return }
        #expect(m.summonModel == .hitenryu)
        #expect(m.isRare == true)
        #expect(m.level == 8)
    }

    @Test func applySummonMonsterIgnoresSpellOrTrap() {
        let store = DuelSessionStore()
        store.applyOpponentEvent(.summonMonster(slot: 0, card: .spell(SpellCard.samples[0])))
        store.applyOpponentEvent(.summonMonster(slot: 1, card: .trap(TrapCard.samples[0])))
        #expect(store.opponentFieldBackRow.allSatisfy { $0 == nil })
        #expect(store.opponentFieldFrontRow.allSatisfy { $0 == nil })
    }

    @Test func applySetSpellOrTrapIgnoresMonster() {
        let store = DuelSessionStore()
        store.opponentFieldFrontRevealed[2] = true
        store.applyOpponentEvent(.setSpellOrTrap(slot: 2, card: .monster(MonsterCard.hitenryu)))
        #expect(store.opponentFieldFrontRow.allSatisfy { $0 == nil })
        #expect(store.opponentFieldBackRow.allSatisfy { $0 == nil })
        // 無視されたので表裏状態も変わらない
        #expect(store.opponentFieldFrontRevealed[2] == true)
    }

    @Test func applySnapshotNilsWrongKindEntries() {
        let store = DuelSessionStore()
        let monster = DuelCard.monster(MonsterCard.hitenryu)
        let spell = DuelCard.spell(SpellCard.samples[0])
        let trap = DuelCard.trap(TrapCard.samples[0])
        let snapshot = DuelFieldSnapshot(
            backRow: [monster, spell, trap, nil, nil],
            frontRow: [monster, spell, trap, nil, nil],
            frontRevealed: [true, true, true, false, false]
        )
        store.applyOpponentEvent(.snapshot(snapshot))
        #expect(store.opponentFieldBackRow == [monster, nil, nil, nil, nil])
        #expect(store.opponentFieldFrontRow == [nil, spell, trap, nil, nil])
        #expect(store.opponentFieldFrontRevealed == [true, true, true, false, false])
    }

    @Test func applyHelloTruncatesLongStrings() {
        let store = DuelSessionStore()
        let info = DuelPeerInfo(
            displayName: String(repeating: "名", count: 300),
            deviceKind: String(repeating: "k", count: 300)
        )
        store.applyOpponentEvent(.hello(info))
        #expect(store.opponentInfo?.displayName.count == 64)
        #expect(store.opponentInfo?.deviceKind.count == 64)
        let short = DuelPeerInfo(displayName: "相手", deviceKind: "iOS")
        store.applyOpponentEvent(.hello(short))
        #expect(store.opponentInfo == short)
    }

    @Test func applySummonMonster() {
        let store = DuelSessionStore()
        let monster = DuelCard.monster(MonsterCard.samples[0])
        store.applyOpponentEvent(.summonMonster(slot: 3, card: monster))
        #expect(store.opponentFieldBackRow[3] == monster)
        #expect(store.opponentFieldFrontRow[3] == nil)
        // 自陣は変わらない
        #expect(store.fieldBackRow[3] == nil)
    }

    @Test func applySetSpellOrTrapIsFaceDown() {
        let store = DuelSessionStore()
        store.opponentFieldFrontRevealed[2] = true
        let spell = DuelCard.spell(SpellCard.samples[0])
        store.applyOpponentEvent(.setSpellOrTrap(slot: 2, card: spell))
        #expect(store.opponentFieldFrontRow[2] == spell)
        #expect(store.opponentFieldFrontRevealed[2] == false)
    }

    @Test func applyOpenCard() {
        let store = DuelSessionStore()
        store.applyOpponentEvent(.setSpellOrTrap(slot: 0, card: .trap(TrapCard.samples[0])))
        store.applyOpponentEvent(.openCard(slot: 0))
        #expect(store.opponentFieldFrontRevealed[0] == true)
    }

    @Test func applyRemoveCard() {
        let store = DuelSessionStore()
        store.applyOpponentEvent(.summonMonster(slot: 1, card: .monster(MonsterCard.hitenryu)))
        store.applyOpponentEvent(.setSpellOrTrap(slot: 1, card: .spell(SpellCard.samples[0])))
        store.applyOpponentEvent(.openCard(slot: 1))
        store.applyOpponentEvent(.removeCard(row: .back, slot: 1))
        #expect(store.opponentFieldBackRow[1] == nil)
        #expect(store.opponentFieldFrontRow[1] != nil)
        store.applyOpponentEvent(.removeCard(row: .front, slot: 1))
        #expect(store.opponentFieldFrontRow[1] == nil)
        #expect(store.opponentFieldFrontRevealed[1] == false)
    }

    @Test func applyNewDuelClearsOpponentFieldButKeepsInfo() {
        let store = DuelSessionStore()
        let info = DuelPeerInfo(displayName: "相手", deviceKind: "macOS")
        store.applyOpponentEvent(.hello(info))
        store.applyOpponentEvent(.summonMonster(slot: 0, card: .monster(MonsterCard.hitenryu)))
        store.applyOpponentEvent(.setSpellOrTrap(slot: 0, card: .spell(SpellCard.samples[0])))
        store.applyOpponentEvent(.openCard(slot: 0))
        store.applyOpponentEvent(.newDuel)
        #expect(store.opponentFieldBackRow.allSatisfy { $0 == nil })
        #expect(store.opponentFieldFrontRow.allSatisfy { $0 == nil })
        #expect(store.opponentFieldFrontRevealed.allSatisfy { $0 == false })
        #expect(store.opponentInfo == info)
    }

    @Test func applyIgnoresOutOfRangeSlots() {
        let store = DuelSessionStore()
        let monster = DuelCard.monster(MonsterCard.hitenryu)
        store.applyOpponentEvent(.summonMonster(slot: 5, card: monster))
        store.applyOpponentEvent(.summonMonster(slot: -1, card: monster))
        store.applyOpponentEvent(.setSpellOrTrap(slot: 99, card: .spell(SpellCard.samples[0])))
        store.applyOpponentEvent(.openCard(slot: 5))
        store.applyOpponentEvent(.removeCard(row: .back, slot: -1))
        store.applyOpponentEvent(.removeCard(row: .front, slot: 5))
        #expect(store.opponentFieldBackRow.allSatisfy { $0 == nil })
        #expect(store.opponentFieldFrontRow.allSatisfy { $0 == nil })
        #expect(store.opponentFieldFrontRevealed.allSatisfy { $0 == false })
    }

    @Test func applyOpponentEventDoesNotEmitToSink() {
        let store = DuelSessionStore()
        var received: [DuelEvent] = []
        store.eventSink = { received.append($0) }
        store.applyOpponentEvent(.summonMonster(slot: 0, card: .monster(MonsterCard.hitenryu)))
        store.applyOpponentEvent(.newDuel)
        #expect(received.isEmpty)
    }

    // MARK: - startNewDuel と相手陣

    @Test func startNewDuelLeavesOpponentStateIntact() {
        let store = DuelSessionStore()
        let monster = DuelCard.monster(MonsterCard.hitenryu)
        let info = DuelPeerInfo(displayName: "相手", deviceKind: "visionOS")
        store.isMultiplayerActive = true
        store.applyOpponentEvent(.hello(info))
        store.applyOpponentEvent(.summonMonster(slot: 2, card: monster))
        store.applyOpponentEvent(.setSpellOrTrap(slot: 2, card: .spell(SpellCard.samples[0])))
        store.applyOpponentEvent(.openCard(slot: 2))
        store.startNewDuel()
        #expect(store.opponentFieldBackRow[2] == monster)
        #expect(store.opponentFieldFrontRow[2] != nil)
        #expect(store.opponentFieldFrontRevealed[2] == true)
        #expect(store.opponentInfo == info)
        #expect(store.isMultiplayerActive == true)
    }

    // MARK: - fieldSnapshot / resetOpponentField

    @Test func fieldSnapshotReflectsLocalRows() {
        let (store, _) = makeRecordingStore()
        let hitenryu = store.hand[0]
        let spell = store.hand[4]
        store.selectHandCard(id: hitenryu.id)
        store.placeSelectedCardToDiskSlot(index: 0)
        store.selectHandCard(id: spell.id)
        store.placeSelectedCardToSpellSlot(index: 4)
        store.openPlacedCard(at: .fieldFront(4))
        let snapshot = store.fieldSnapshot()
        #expect(snapshot.backRow == store.fieldBackRow)
        #expect(snapshot.frontRow == store.fieldFrontRow)
        #expect(snapshot.frontRevealed == store.fieldFrontRevealed)
        #expect(snapshot.backRow[0] == hitenryu)
        #expect(snapshot.frontRow[4] == spell)
        #expect(snapshot.frontRevealed[4] == true)
    }

    @Test func resetOpponentFieldClearsRows() {
        let store = DuelSessionStore()
        store.applyOpponentEvent(.summonMonster(slot: 0, card: .monster(MonsterCard.hitenryu)))
        store.applyOpponentEvent(.setSpellOrTrap(slot: 1, card: .spell(SpellCard.samples[0])))
        store.applyOpponentEvent(.openCard(slot: 1))
        store.resetOpponentField()
        #expect(store.opponentFieldBackRow.allSatisfy { $0 == nil })
        #expect(store.opponentFieldFrontRow.allSatisfy { $0 == nil })
        #expect(store.opponentFieldFrontRevealed.allSatisfy { $0 == false })
    }
}
