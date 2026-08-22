//
//  DuelSessionStoreTests.swift
//  YugiohDuelDiskPackageTests
//
//  DuelSessionStore のロジックを Swift Testing で検証する。
//  Entity / RealityKit 周りはここでは扱わない(View 層に閉じる)。
//

import Foundation
import Testing
@testable import YugiohDuelDiskPackage

/// テスト用のカード生成ヘルパー。
/// `startNewDuel()` はランダムに種類が混ざるため、配置系テストでは決定的な手札を作る。
private enum TestCards {
    static func monster(name: String = "テストモンスター") -> DuelCard {
        .monster(MonsterCard(
            name: name, attribute: "甘", level: 4, species: "甘党",
            text: "テスト", attack: 1000, defense: 800
        ))
    }

    static func spell(name: String = "テスト魔法") -> DuelCard {
        .spell(SpellCard(name: name, text: "テスト"))
    }

    static func trap(name: String = "テスト罠") -> DuelCard {
        .trap(TrapCard(name: name, text: "テスト"))
    }

    static func monsters(_ count: Int) -> [DuelCard] {
        (0..<count).map { monster(name: "モンスター\($0)") }
    }
}

struct DuelSessionStoreTests {
    // MARK: - 初期化 & startNewDuel

    @Test func initialStateIsEmpty() {
        let store = DuelSessionStore()
        #expect(store.hand.isEmpty)
        #expect(store.rightHandCard == nil)
        #expect(store.selectedHandCardId == nil)
        #expect(store.diskSlots.count == 5)
        #expect(store.diskSlots.allSatisfy { $0 == nil })
        #expect(store.spellSlots.count == 5)
        #expect(store.fieldBackRow.count == 5)
        #expect(store.fieldFrontRow.count == 5)
        #expect(store.phase == .idle)
    }

    @Test func startNewDuelDealsFiveCards() {
        let store = DuelSessionStore()
        store.startNewDuel()
        #expect(store.hand.count == 5)
        #expect(store.phase == .idle)
        #expect(store.rightHandCard == nil)
    }

    @Test func startNewDuelResetsExistingState() {
        let store = DuelSessionStore()
        store.startNewDuel()
        // セッション途中の状態を作る
        store.diskSlots[0] = store.hand.first
        store.rightHandCard = TestCards.monster()
        store.selectedHandCardId = store.hand.first?.id
        store.phase = .drawing
        // リセット
        store.startNewDuel()
        #expect(store.diskSlots.allSatisfy { $0 == nil })
        #expect(store.rightHandCard == nil)
        #expect(store.selectedHandCardId == nil)
        #expect(store.phase == .idle)
        #expect(store.hand.count == 5)
    }

    // MARK: - drawCard

    @Test func drawCardCreatesRightHandCard() {
        let store = DuelSessionStore()
        store.startNewDuel()
        store.drawCard()
        #expect(store.rightHandCard != nil)
        #expect(store.phase == .drawing)
    }

    @Test func drawCardIsIgnoredWhenRightHandAlreadyHasCard() {
        let store = DuelSessionStore()
        store.startNewDuel()
        store.drawCard()
        let firstId = store.rightHandCard?.id
        store.drawCard() // 連続ドロー → 無視されるはず
        #expect(store.rightHandCard?.id == firstId)
    }

    @Test func drawCardIsIgnoredAtHandCapacity() {
        let store = DuelSessionStore()
        store.startNewDuel()
        // 手札を上限まで埋める
        while store.hand.count < DuelSessionStore.handCapacity {
            store.hand.append(TestCards.monster())
        }
        store.drawCard()
        #expect(store.rightHandCard == nil)
    }

    // MARK: - addRightHandCardToFan

    @Test func addRightHandCardToFanIncreasesHand() {
        let store = DuelSessionStore()
        store.startNewDuel()
        store.drawCard()
        let drawnId = store.rightHandCard?.id
        store.addRightHandCardToFan()
        #expect(store.rightHandCard == nil)
        #expect(store.phase == .idle)
        #expect(store.hand.last?.id == drawnId)
        #expect(store.hand.count == DuelSessionStore.initialHandSize + 1)
    }

    @Test func addRightHandCardToFanIsNoOpIfHandIsFull() {
        let store = DuelSessionStore()
        store.startNewDuel()
        // 上限ぎりぎりに整える
        while store.hand.count < DuelSessionStore.handCapacity {
            store.hand.append(TestCards.monster())
        }
        // 上限直前にドローしたい状態を強制的に再現
        store.rightHandCard = TestCards.monster()
        let beforeHand = store.hand.count
        store.addRightHandCardToFan()
        #expect(store.hand.count == beforeHand)
        #expect(store.rightHandCard != nil) // 取り込めなかったので残る
    }

    // MARK: - selectHandCard

    @Test func selectHandCardSetsSelectionAndPhase() {
        let store = DuelSessionStore()
        store.startNewDuel()
        guard let target = store.hand.first else {
            Issue.record("hand should not be empty after startNewDuel")
            return
        }
        store.selectHandCard(id: target.id)
        #expect(store.selectedHandCardId == target.id)
        #expect(store.phase == .selectingFromHand)
    }

    @Test func selectingSameCardClearsSelection() {
        let store = DuelSessionStore()
        store.startNewDuel()
        guard let target = store.hand.first else { return }
        store.selectHandCard(id: target.id)
        store.selectHandCard(id: target.id) // 同じカードを再タップ
        #expect(store.selectedHandCardId == nil)
        #expect(store.phase == .idle)
    }

    @Test func selectDifferentHandCardSwitchesSelection() {
        let store = DuelSessionStore()
        store.startNewDuel()
        guard store.hand.count >= 2 else { return }
        let first = store.hand[0]
        let second = store.hand[1]
        store.selectHandCard(id: first.id)
        store.selectHandCard(id: second.id)
        #expect(store.selectedHandCardId == second.id)
        #expect(store.phase == .selectingFromHand)
    }

    @Test func selectHandCardIgnoresUnknownId() {
        let store = DuelSessionStore()
        store.startNewDuel()
        store.selectHandCard(id: UUID()) // 存在しないID
        #expect(store.selectedHandCardId == nil)
        #expect(store.phase == .idle)
    }

    // MARK: - placeSelectedCardToDiskSlot (モンスター)

    @Test func placeSelectedMonsterToEmptySlot() {
        let store = DuelSessionStore()
        store.startNewDuel()
        store.hand = TestCards.monsters(5)
        let target = store.hand[0]
        store.selectHandCard(id: target.id)
        store.placeSelectedCardToDiskSlot(index: 0)
        #expect(store.diskSlots[0]?.id == target.id)
        #expect(store.hand.contains(where: { $0.id == target.id }) == false)
        #expect(store.selectedHandCardId == nil)
        #expect(store.phase == .idle)
    }

    @Test func placeSelectedMonsterIsRejectedOnOccupiedSlot() {
        let store = DuelSessionStore()
        store.startNewDuel()
        store.hand = TestCards.monsters(3)
        let occupant = store.hand[0]
        store.selectHandCard(id: occupant.id)
        store.placeSelectedCardToDiskSlot(index: 0)
        #expect(store.diskSlots[0]?.id == occupant.id)

        let challenger = store.hand[0] // 1枚減ったので 0 番目が以前の 1 番目
        store.selectHandCard(id: challenger.id)
        store.placeSelectedCardToDiskSlot(index: 0)
        #expect(store.diskSlots[0]?.id == occupant.id) // 拒否されている
        #expect(store.hand.contains(where: { $0.id == challenger.id })) // 手札にも残る
    }

    @Test func placeSelectedCardIgnoredWithoutSelection() {
        let store = DuelSessionStore()
        store.startNewDuel()
        store.placeSelectedCardToDiskSlot(index: 0)
        #expect(store.diskSlots[0] == nil)
    }

    @Test func placeSelectedCardIgnoresOutOfRangeIndex() {
        let store = DuelSessionStore()
        store.startNewDuel()
        store.hand = TestCards.monsters(5)
        let target = store.hand[0]
        store.selectHandCard(id: target.id)
        store.placeSelectedCardToDiskSlot(index: 99)
        #expect(store.diskSlots.allSatisfy { $0 == nil })
        #expect(store.selectedHandCardId == target.id) // 選択は残る
    }

    @Test func placeSelectedMonsterAlsoFillsFieldBack() {
        // disk への配置に伴い、対応する fieldBackRow も Store 層で自動的に埋まる
        let store = DuelSessionStore()
        store.startNewDuel()
        store.hand = TestCards.monsters(5)
        let target = store.hand[0]
        store.selectHandCard(id: target.id)
        store.placeSelectedCardToDiskSlot(index: 2)
        #expect(store.diskSlots[2]?.id == target.id)
        #expect(store.fieldBackRow[2]?.id == target.id)
    }

    @Test func placeMonsterToDiskSlotDoesNotTouchFieldFront() {
        let store = DuelSessionStore()
        store.startNewDuel()
        store.hand = TestCards.monsters(5)
        let target = store.hand[3]
        store.selectHandCard(id: target.id)
        store.placeSelectedCardToDiskSlot(index: 3)
        #expect(store.diskSlots[3]?.id == target.id)
        #expect(store.fieldBackRow[3]?.id == target.id)
        #expect(store.fieldFrontRow[3] == nil, "モンスターは前列(魔法罠)を書かない")
    }

    @Test func placeSelectedCardIgnoredWithoutPriorSelection() {
        let store = DuelSessionStore()
        store.startNewDuel()
        let before = store.hand.count
        store.placeSelectedCardToDiskSlot(index: 1)
        #expect(store.hand.count == before)
        #expect(store.diskSlots[1] == nil)
        #expect(store.fieldBackRow[1] == nil)
    }

    // MARK: - 種類による配置制限

    @Test func spellCannotGoToDiskSummonSlot() {
        let store = DuelSessionStore()
        store.startNewDuel()
        store.hand = [TestCards.spell()]
        let spell = store.hand[0]
        store.selectHandCard(id: spell.id)
        store.placeSelectedCardToDiskSlot(index: 0) // 魔法は召喚スロット不可
        #expect(store.diskSlots[0] == nil)
        #expect(store.hand.contains(where: { $0.id == spell.id }))
    }

    @Test func monsterCannotGoToSpellSlot() {
        let store = DuelSessionStore()
        store.startNewDuel()
        store.hand = [TestCards.monster()]
        let monster = store.hand[0]
        store.selectHandCard(id: monster.id)
        store.placeSelectedCardToSpellSlot(index: 0) // モンスターは魔法罠挿入口不可
        #expect(store.spellSlots[0] == nil)
        #expect(store.hand.contains(where: { $0.id == monster.id }))
    }

    @Test func spellGoesToSpellSlotAndFieldFront() {
        let store = DuelSessionStore()
        store.startNewDuel()
        store.hand = [TestCards.spell(), TestCards.trap()]
        let spell = store.hand[0]
        store.selectHandCard(id: spell.id)
        store.placeSelectedCardToSpellSlot(index: 1)
        #expect(store.spellSlots[1]?.id == spell.id)
        #expect(store.fieldFrontRow[1]?.id == spell.id)
        #expect(store.fieldBackRow[1] == nil, "魔法罠は奥列(モンスター)を書かない")
        #expect(store.hand.contains(where: { $0.id == spell.id }) == false)
    }

    @Test func trapGoesToSpellSlot() {
        let store = DuelSessionStore()
        store.startNewDuel()
        store.hand = [TestCards.trap()]
        let trap = store.hand[0]
        store.selectHandCard(id: trap.id)
        store.placeSelectedCardToSpellSlot(index: 0)
        #expect(store.spellSlots[0]?.id == trap.id)
        #expect(store.fieldFrontRow[0]?.id == trap.id)
    }

    // MARK: - 裏向き / オープン

    @Test func spellIsPlacedFaceDownByDefault() {
        let store = DuelSessionStore()
        store.startNewDuel()
        store.hand = [TestCards.spell()]
        store.selectHandCard(id: store.hand[0].id)
        store.placeSelectedCardToSpellSlot(index: 2)
        #expect(store.fieldFrontRevealed[2] == false)
        #expect(store.canOpenCard(at: .fieldFront(2)) == true)
    }

    @Test func openPlacedCardRevealsIt() {
        let store = DuelSessionStore()
        store.startNewDuel()
        store.hand = [TestCards.trap()]
        store.selectHandCard(id: store.hand[0].id)
        store.placeSelectedCardToSpellSlot(index: 1)
        store.openPlacedCard(at: .fieldFront(1))
        #expect(store.fieldFrontRevealed[1] == true)
        #expect(store.canOpenCard(at: .fieldFront(1)) == false) // 既に表なので再オープン不可
    }

    @Test func monsterCardCannotBeOpened() {
        let store = DuelSessionStore()
        store.startNewDuel()
        store.hand = TestCards.monsters(1)
        store.selectHandCard(id: store.hand[0].id)
        store.placeSelectedCardToDiskSlot(index: 0)
        #expect(store.canOpenCard(at: .fieldBack(0)) == false)
    }

    @Test func removingFaceDownCardResetsRevealFlag() {
        let store = DuelSessionStore()
        store.startNewDuel()
        store.hand = [TestCards.spell()]
        store.selectHandCard(id: store.hand[0].id)
        store.placeSelectedCardToSpellSlot(index: 0)
        store.openPlacedCard(at: .fieldFront(0))
        store.removePlacedCard(at: .fieldFront(0))
        #expect(store.fieldFrontRow[0] == nil)
        #expect(store.fieldFrontRevealed[0] == false)
    }

    // MARK: - モンスターの具材バリエーション

    @Test func monsterSamplesCoverAllFourFlavors() {
        let flavors = Set(MonsterCard.samples.map { $0.flavor })
        #expect(flavors == Set(TaiyakiFlavor.allCases))
    }

    // MARK: - selectedCardKind

    @Test func selectedCardKindReflectsSelection() {
        let store = DuelSessionStore()
        store.startNewDuel()
        store.hand = [TestCards.monster(), TestCards.spell(), TestCards.trap()]
        store.selectHandCard(id: store.hand[0].id)
        #expect(store.selectedCardKind == .monster)
        store.selectHandCard(id: store.hand[1].id)
        #expect(store.selectedCardKind == .spell)
        store.selectHandCard(id: store.hand[2].id)
        #expect(store.selectedCardKind == .trap)
    }

    // MARK: - removePlacedCard

    @Test func removePlacedDiskSlotAlsoClearsFieldBack() {
        let store = DuelSessionStore()
        store.startNewDuel()
        let card = TestCards.monster()
        store.diskSlots[2] = card
        store.fieldBackRow[2] = card
        store.removePlacedCard(at: .diskSlot(2))
        #expect(store.diskSlots[2] == nil)
        #expect(store.fieldBackRow[2] == nil)
        #expect(store.tappedPlacedCardContext == nil)
    }

    @Test func removeFieldBackAlsoClearsDiskSlot() {
        let store = DuelSessionStore()
        store.startNewDuel()
        let card = TestCards.monster()
        store.diskSlots[3] = card
        store.fieldBackRow[3] = card
        store.removePlacedCard(at: .fieldBack(3))
        #expect(store.fieldBackRow[3] == nil)
        #expect(store.diskSlots[3] == nil)
    }

    @Test func removeSpellSlotAlsoClearsFieldFront() {
        let store = DuelSessionStore()
        store.startNewDuel()
        let card = TestCards.spell()
        store.spellSlots[1] = card
        store.fieldFrontRow[1] = card
        store.removePlacedCard(at: .spellSlot(1))
        #expect(store.spellSlots[1] == nil)
        #expect(store.fieldFrontRow[1] == nil)
    }

    @Test func removeFieldFrontAlsoClearsSpellSlot() {
        let store = DuelSessionStore()
        store.startNewDuel()
        let card = TestCards.trap()
        store.spellSlots[2] = card
        store.fieldFrontRow[2] = card
        store.removePlacedCard(at: .fieldFront(2))
        #expect(store.fieldFrontRow[2] == nil)
        #expect(store.spellSlots[2] == nil)
    }

    @Test func removePlacedCardClearsTappedContext() {
        let store = DuelSessionStore()
        store.startNewDuel()
        let card = TestCards.monster()
        store.diskSlots[0] = card
        store.tappedPlacedCardContext = .diskSlot(0)
        store.removePlacedCard(at: .diskSlot(0))
        #expect(store.tappedPlacedCardContext == nil)
    }

    @Test func removePlacedCardIgnoresOutOfRangeIndex() {
        let store = DuelSessionStore()
        store.startNewDuel()
        store.removePlacedCard(at: .diskSlot(99))
        store.removePlacedCard(at: .fieldBack(-1))
        store.removePlacedCard(at: .fieldFront(99))
        // クラッシュしないこと、状態が変わらないことを確認
        #expect(store.diskSlots.allSatisfy { $0 == nil })
    }

    // MARK: - drawCard 境界値

    @Test func drawCardAtExactlyHandCapacityIsRejected() {
        let store = DuelSessionStore()
        // 上限ぎりぎりに手札を作る
        while store.hand.count < DuelSessionStore.handCapacity {
            store.hand.append(TestCards.monster())
        }
        #expect(store.hand.count == DuelSessionStore.handCapacity)
        store.drawCard()
        #expect(store.rightHandCard == nil)
        #expect(store.phase == .idle)
    }

    @Test func drawCardWhenRightHandIsEmptyAndHandHasSpace() {
        let store = DuelSessionStore()
        store.startNewDuel() // 5枚
        store.drawCard()
        #expect(store.rightHandCard != nil)
        #expect(store.phase == .drawing)
    }

    // MARK: - addRightHandCardToFan 境界値

    @Test func addRightHandCardWithoutRightHandIsNoOp() {
        let store = DuelSessionStore()
        store.startNewDuel()
        let before = store.hand.count
        store.addRightHandCardToFan() // rightHandCard が nil
        #expect(store.hand.count == before)
    }

    // MARK: - 仕様化テスト (現状の意図された挙動を明示)

    /// selectedHandCardId に「手札に居ないカード ID」がセットされた状態で配置すると no-op。
    @Test func placeSelectedCardWithStaleSelectionId() {
        let store = DuelSessionStore()
        store.startNewDuel()
        store.selectedHandCardId = UUID() // hand に存在しない ID を強引にセット
        store.placeSelectedCardToDiskSlot(index: 0)
        #expect(store.diskSlots[0] == nil)
        #expect(store.fieldBackRow[0] == nil)
        #expect(store.hand.count == DuelSessionStore.initialHandSize)
    }

    /// 自然な状態機械フロー: hand=5 → draw → fan → hand=6 → draw → fan → hand=7 → draw 拒否
    @Test func drawAddLoopRespectsCapacityNaturally() {
        let store = DuelSessionStore()
        store.startNewDuel() // hand=5
        store.drawCard()
        store.addRightHandCardToFan() // hand=6
        #expect(store.hand.count == 6)
        store.drawCard() // 6 < 7 なので成功
        #expect(store.rightHandCard != nil)
        store.addRightHandCardToFan() // hand=7
        #expect(store.hand.count == DuelSessionStore.handCapacity)
        // 上限到達後の drawCard は拒否される
        store.drawCard()
        #expect(store.rightHandCard == nil)
        #expect(store.phase == .idle)
    }

    /// `placeSelectedCardToDiskSlot` には phase ガードが無いため、drawing 中でも配置は成功する。
    @Test func placeSelectedCardWorksRegardlessOfDrawingPhase() {
        let store = DuelSessionStore()
        store.startNewDuel()
        store.hand = TestCards.monsters(5)
        store.drawCard() // phase=.drawing, rightHandCard 保持
        let target = store.hand[0]
        store.selectHandCard(id: target.id) // phase が .selectingFromHand に上書きされる
        #expect(store.phase == .selectingFromHand)
        #expect(store.rightHandCard != nil, "右手カードは保持され続けるはず")
        store.placeSelectedCardToDiskSlot(index: 0)
        #expect(store.diskSlots[0]?.id == target.id)
        #expect(store.rightHandCard != nil, "配置後も右手カードは残る")
    }

    /// 空のスロットへの remove は安全 no-op
    @Test func removePlacedCardOnEmptySlotsIsNoOp() {
        let store = DuelSessionStore()
        store.startNewDuel()
        store.removePlacedCard(at: .diskSlot(0))
        store.removePlacedCard(at: .fieldBack(0))
        store.removePlacedCard(at: .fieldFront(0))
        #expect(store.diskSlots.allSatisfy { $0 == nil })
        #expect(store.fieldBackRow.allSatisfy { $0 == nil })
        #expect(store.fieldFrontRow.allSatisfy { $0 == nil })
        #expect(store.tappedPlacedCardContext == nil)
    }
}
