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

struct DuelSessionStoreTests {
    // MARK: - 初期化 & startNewDuel

    @Test func initialStateIsEmpty() {
        let store = DuelSessionStore()
        #expect(store.hand.isEmpty)
        #expect(store.rightHandCard == nil)
        #expect(store.selectedHandCardId == nil)
        #expect(store.diskSlots.count == 5)
        #expect(store.diskSlots.allSatisfy { $0 == nil })
        #expect(store.arenaSlotsBack.count == 5)
        #expect(store.arenaSlotsFront.count == 5)
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
        store.rightHandCard = CardModel()
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
            store.hand.append(CardModel())
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
            store.hand.append(CardModel())
        }
        // 上限直前にドローしたい状態を強制的に再現
        store.rightHandCard = CardModel()
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

    // MARK: - placeSelectedCardToDiskSlot

    @Test func placeSelectedCardToEmptySlot() {
        let store = DuelSessionStore()
        store.startNewDuel()
        guard let target = store.hand.first else { return }
        store.selectHandCard(id: target.id)
        store.placeSelectedCardToDiskSlot(index: 0)
        #expect(store.diskSlots[0]?.id == target.id)
        #expect(store.hand.contains(where: { $0.id == target.id }) == false)
        #expect(store.selectedHandCardId == nil)
        #expect(store.phase == .idle)
    }

    @Test func placeSelectedCardIsRejectedOnOccupiedSlot() {
        let store = DuelSessionStore()
        store.startNewDuel()
        // 先に 0 番スロットを埋める
        guard store.hand.count >= 2 else { return }
        let occupant = store.hand[0]
        store.selectHandCard(id: occupant.id)
        store.placeSelectedCardToDiskSlot(index: 0)
        #expect(store.diskSlots[0]?.id == occupant.id)

        // 次のカードで上書きを試みる
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
        guard let target = store.hand.first else { return }
        store.selectHandCard(id: target.id)
        store.placeSelectedCardToDiskSlot(index: 99)
        #expect(store.diskSlots.allSatisfy { $0 == nil })
        #expect(store.selectedHandCardId == target.id) // 選択は残る
    }

    @Test func placeSelectedCardAlsoFillsArenaBack() {
        // disk への配置に伴い、対応する arenaBack も Store 層で自動的に埋まる
        let store = DuelSessionStore()
        store.startNewDuel()
        guard let target = store.hand.first else { return }
        store.selectHandCard(id: target.id)
        store.placeSelectedCardToDiskSlot(index: 2)
        #expect(store.diskSlots[2]?.id == target.id)
        #expect(store.arenaSlotsBack[2]?.id == target.id)
    }

    @Test func placeSelectedCardIgnoredWithoutPriorSelection() {
        // selectedHandCardId が nil のときは何もしない
        let store = DuelSessionStore()
        store.startNewDuel()
        let before = store.hand.count
        store.placeSelectedCardToDiskSlot(index: 1)
        #expect(store.hand.count == before)
        #expect(store.diskSlots[1] == nil)
        #expect(store.arenaSlotsBack[1] == nil)
    }

    // MARK: - removePlacedCard

    @Test func removePlacedDiskSlotAlsoClearsArenaBack() {
        let store = DuelSessionStore()
        store.startNewDuel()
        let card = CardModel()
        store.diskSlots[2] = card
        store.arenaSlotsBack[2] = card
        store.removePlacedCard(at: .diskSlot(2))
        #expect(store.diskSlots[2] == nil)
        #expect(store.arenaSlotsBack[2] == nil)
        #expect(store.tappedPlacedCardContext == nil)
    }

    @Test func removeArenaBackAlsoClearsDiskSlot() {
        let store = DuelSessionStore()
        store.startNewDuel()
        let card = CardModel()
        store.diskSlots[3] = card
        store.arenaSlotsBack[3] = card
        store.removePlacedCard(at: .arenaBack(3))
        #expect(store.arenaSlotsBack[3] == nil)
        #expect(store.diskSlots[3] == nil)
    }

    @Test func removePlacedCardArenaFrontOnlyClearsItself() {
        let store = DuelSessionStore()
        store.startNewDuel()
        let card = CardModel()
        store.arenaSlotsFront[1] = card
        store.removePlacedCard(at: .arenaFront(1))
        #expect(store.arenaSlotsFront[1] == nil)
    }

    @Test func removePlacedCardClearsTappedContext() {
        let store = DuelSessionStore()
        store.startNewDuel()
        let card = CardModel()
        store.diskSlots[0] = card
        store.tappedPlacedCardContext = .diskSlot(0)
        store.removePlacedCard(at: .diskSlot(0))
        #expect(store.tappedPlacedCardContext == nil)
    }

    @Test func removePlacedCardIgnoresOutOfRangeIndex() {
        let store = DuelSessionStore()
        store.startNewDuel()
        store.removePlacedCard(at: .diskSlot(99))
        store.removePlacedCard(at: .arenaBack(-1))
        store.removePlacedCard(at: .arenaFront(99))
        // クラッシュしないこと、状態が変わらないことを確認
        #expect(store.diskSlots.allSatisfy { $0 == nil })
    }

    // MARK: - drawCard 境界値

    @Test func drawCardAtExactlyHandCapacityIsRejected() {
        let store = DuelSessionStore()
        // 上限ぎりぎりに手札を作る
        while store.hand.count < DuelSessionStore.handCapacity {
            store.hand.append(CardModel())
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

    /// selectedHandCardId に「手札に居ないカード ID」がセットされた状態で配置すると、
    /// 第2 guard (`hand.firstIndex` 失敗) で no-op になる。
    @Test func placeSelectedCardWithStaleSelectionId() {
        let store = DuelSessionStore()
        store.startNewDuel()
        store.selectedHandCardId = UUID() // hand に存在しない ID を強引にセット
        store.placeSelectedCardToDiskSlot(index: 0)
        #expect(store.diskSlots[0] == nil)
        #expect(store.arenaSlotsBack[0] == nil)
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

    /// `placeSelectedCardToDiskSlot` には phase ガードが無いため、
    /// drawing 中でも配置は成功する(現状の意図された挙動)。
    @Test func placeSelectedCardWorksRegardlessOfDrawingPhase() {
        let store = DuelSessionStore()
        store.startNewDuel()
        store.drawCard() // phase=.drawing, rightHandCard 保持
        guard let target = store.hand.first else {
            Issue.record("hand should not be empty after startNewDuel")
            return
        }
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
        store.removePlacedCard(at: .arenaBack(0))
        store.removePlacedCard(at: .arenaFront(0))
        #expect(store.diskSlots.allSatisfy { $0 == nil })
        #expect(store.arenaSlotsBack.allSatisfy { $0 == nil })
        #expect(store.arenaSlotsFront.allSatisfy { $0 == nil })
        #expect(store.tappedPlacedCardContext == nil)
    }

    /// `placeSelectedCardToDiskSlot` は `arenaSlotsFront` を書き換えない(将来用)。
    @Test func placeSelectedCardDoesNotTouchArenaFront() {
        let store = DuelSessionStore()
        store.startNewDuel()
        guard let target = store.hand.first else {
            Issue.record("hand should not be empty after startNewDuel")
            return
        }
        store.selectHandCard(id: target.id)
        store.placeSelectedCardToDiskSlot(index: 3)
        #expect(store.diskSlots[3]?.id == target.id)
        #expect(store.arenaSlotsBack[3]?.id == target.id)
        #expect(store.arenaSlotsFront[3] == nil, "arenaFront は将来用なので書かれない")
    }
}
