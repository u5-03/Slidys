//
//  DuelSessionStoreDrawCooldownTests.swift
//  YugiohDuelDiskPackageTests
//
//  カードをセットした直後のドロー抑止(クールダウン)のテスト。
//  セットした右手がそのままデッキに触れて誤ってドローしてしまう挙動を防ぐ。
//

import Foundation
import Testing
@testable import YugiohDuelDiskPackage

@Suite("DuelSessionStore ドロークールダウン")
struct DuelSessionStoreDrawCooldownTests {
    /// 固定時刻を返す Store を作る(`now` を差し替えて時間を制御する)。
    private func makeStore(at time: Date) -> (DuelSessionStore, (Date) -> Void) {
        let store = DuelSessionStore()
        var current = time
        store.now = { current }
        store.startNewDuel()
        return (store, { current = $0 })
    }

    @Test("セット前はクールダウンなしでドローできる")
    func drawsWhenNothingWasPlaced() {
        let (store, _) = makeStore(at: Date(timeIntervalSince1970: 1_000))
        #expect(store.isDrawBlockedByPlacementCooldown == false)
        store.drawCard()
        #expect(store.rightHandCard != nil)
    }

    @Test("モンスターをセットした直後はドローが無視される")
    func blocksDrawRightAfterMonsterPlacement() {
        let base = Date(timeIntervalSince1970: 1_000)
        let (store, advance) = makeStore(at: base)
        let monster = store.hand[0] // 固定配布の 1 枚目は緋天竜(モンスター)
        store.selectHandCard(id: monster.id)
        store.placeSelectedCardToDiskSlot(index: 0)
        #expect(store.diskSlots[0] == monster)
        #expect(store.lastCardPlacedAt == base)

        advance(base.addingTimeInterval(0.5))
        #expect(store.isDrawBlockedByPlacementCooldown == true)
        store.drawCard()
        #expect(store.rightHandCard == nil, "セット直後(0.5s)のドローは無視される")
    }

    @Test("クールダウン経過後はドローできる")
    func allowsDrawAfterCooldown() {
        let base = Date(timeIntervalSince1970: 1_000)
        let (store, advance) = makeStore(at: base)
        let monster = store.hand[0]
        store.selectHandCard(id: monster.id)
        store.placeSelectedCardToDiskSlot(index: 0)

        advance(base.addingTimeInterval(DuelSessionStore.drawCooldownAfterPlacement + 0.05))
        #expect(store.isDrawBlockedByPlacementCooldown == false)
        store.drawCard()
        #expect(store.rightHandCard != nil, "1s 経過後はドローできる")
    }

    @Test("魔法・トラップの設置でもクールダウンが始まる")
    func blocksDrawRightAfterSpellPlacement() {
        let base = Date(timeIntervalSince1970: 1_000)
        let (store, advance) = makeStore(at: base)
        let spell = store.hand[4] // 固定配布の 5 枚目は魔法カード
        #expect(spell.isSpellOrTrap)
        store.selectHandCard(id: spell.id)
        store.placeSelectedCardToSpellSlot(index: 0)
        #expect(store.spellSlots[0] == spell)

        advance(base.addingTimeInterval(0.9))
        store.drawCard()
        #expect(store.rightHandCard == nil)
    }

    @Test("右手カードからの召喚/設置でもクールダウンが始まる")
    func blocksDrawAfterRightHandPlacement() {
        let base = Date(timeIntervalSince1970: 1_000)
        let (store, advance) = makeStore(at: base)
        let monster = store.hand[0]
        store.selectHandCard(id: monster.id)
        #expect(store.moveSelectedCardToRightHand())
        #expect(store.summonRightHandCardToDiskSlot(index: 1))

        advance(base.addingTimeInterval(0.2))
        store.drawCard()
        #expect(store.rightHandCard == nil)
    }
}
