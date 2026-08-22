//
//  DuelSessionStore.swift
//  YugiohDuelDiskPackage
//
//  デュエルセッションの状態モデル(Single Source of Truth)。
//  ImmersiveSpace 入退室で `startNewDuel()` を呼んでリセットする。
//

import Foundation
import Observation

/// MainActor 上で利用される UI 状態モデル。
/// EnvironmentKey の `defaultValue` から呼び出せるよう `@MainActor` 隔離は付けず、
/// `@unchecked Sendable` で他アクターからの参照も許容する。
/// 書き込み箇所は基本的に MainActor 文脈(View / RealityKit System の MainActor)に閉じる前提。
@Observable
public final class DuelSessionStore: @unchecked Sendable {
    public enum Phase: Sendable {
        /// 何も持っていない通常状態
        case idle
        /// 右手にドロー中のカードを保持している(ピンチ解除しても保持)
        case drawing
        /// 手札のカードを選択中(=配置先スロット待ち)
        case selectingFromHand
    }

    // MARK: - 定数

    /// ImmersiveSpace 入室時に配るカード枚数
    public static let initialHandSize: Int = 5
    /// 手札上限(これ以上はドローしない)
    public static let handCapacity: Int = 7
    /// ディスク上の召喚スロット数 / 魔法・トラップ挿入口数
    public static let diskSlotCount: Int = 5

    // MARK: - 状態

    public var phase: Phase = .idle
    public var hand: [DuelCard] = []
    public var rightHandCard: DuelCard?
    public var selectedHandCardId: DuelCard.ID?
    /// ディスク上の召喚スロット(モンスター)。フィールド奥列と対。
    public var diskSlots: [DuelCard?] = Array(repeating: nil, count: diskSlotCount)
    /// ディスク上の魔法・トラップ挿入口。フィールド手前列と対。
    public var spellSlots: [DuelCard?] = Array(repeating: nil, count: diskSlotCount)
    /// フィールド奥列(モンスター)。ディスク召喚スロットと対。
    public var fieldBackRow: [DuelCard?] = Array(repeating: nil, count: diskSlotCount)
    /// フィールド手前列(魔法・トラップ)。ディスク魔法・トラップ挿入口と対。
    public var fieldFrontRow: [DuelCard?] = Array(repeating: nil, count: diskSlotCount)
    /// フィールド手前列のカードが表(オープン済み)かどうか。魔法・トラップは基本裏で置かれる。
    public var fieldFrontRevealed: [Bool] = Array(repeating: false, count: diskSlotCount)

    /// 配置済みカードをタップしたときに表示するメニューのコンテキスト
    public var tappedPlacedCardContext: PlacedCardContext?

    // MARK: - ハンドトラッキング状態(System から書き戻される)

    public var isLeftPinching: Bool = false
    public var isRightPinching: Bool = false

    public init() {}

    // MARK: - 派生状態

    /// 現在選択中の手札カード。
    public var selectedCard: DuelCard? {
        guard let id = selectedHandCardId else { return nil }
        return hand.first(where: { $0.id == id })
    }

    /// 現在選択中のカードの種類(未選択なら nil)。
    public var selectedCardKind: DuelCard.Kind? {
        selectedCard?.kind
    }

    // MARK: - ライフサイクル

    /// 新規デュエル開始: 初期手札を配る + 状態を全リセット。
    public func startNewDuel() {
        hand = (0..<Self.initialHandSize).map { _ in DuelCard.random() }
        rightHandCard = nil
        selectedHandCardId = nil
        diskSlots = Array(repeating: nil, count: Self.diskSlotCount)
        spellSlots = Array(repeating: nil, count: Self.diskSlotCount)
        fieldBackRow = Array(repeating: nil, count: Self.diskSlotCount)
        fieldFrontRow = Array(repeating: nil, count: Self.diskSlotCount)
        fieldFrontRevealed = Array(repeating: false, count: Self.diskSlotCount)
        tappedPlacedCardContext = nil
        phase = .idle
    }

    // MARK: - 操作

    /// ドロー判定: 右手がデッキに接触している間に呼ばれる。
    /// - 既に右手にカードがある場合は無視。
    /// - 手札上限に達している場合も無視。
    /// - 検証目的のためデッキ残り枚数の制限は設けない(無限ドロー可)。
    public func drawCard() {
        guard rightHandCard == nil else { return }
        guard hand.count < Self.handCapacity else { return }
        rightHandCard = DuelCard.random()
        phase = .drawing
    }

    /// 右手カードを左手の扇に取り込む。
    public func addRightHandCardToFan() {
        guard let card = rightHandCard else { return }
        guard hand.count < Self.handCapacity else {
            // 上限超過時は何もしない(扇に取り込めない)
            return
        }
        hand.append(card)
        rightHandCard = nil
        phase = .idle
    }

    /// 手札カードを選択(タップ)。同じカードを再タップすると選択解除。
    public func selectHandCard(id: DuelCard.ID) {
        guard hand.contains(where: { $0.id == id }) else { return }
        if selectedHandCardId == id {
            // 同じカードの再タップ → 選択解除
            selectedHandCardId = nil
            phase = .idle
        } else {
            selectedHandCardId = id
            phase = .selectingFromHand
        }
    }

    /// 選択中の *モンスター* カードをディスクの空き召喚スロットに配置する。
    /// - 選択カードがモンスターでない場合は拒否。
    /// - 既にカードがあるスロットへの配置は拒否。
    /// - 配置と同時に、対応するフィールド奥列(`fieldBackRow[index]`)にも反映する。
    public func placeSelectedCardToDiskSlot(index: Int) {
        guard (0..<Self.diskSlotCount).contains(index) else { return }
        guard let card = selectedCard, card.kind == .monster else { return }
        guard let cardIndex = hand.firstIndex(where: { $0.id == card.id }) else { return }
        guard diskSlots[index] == nil else { return } // 上書き拒否

        hand.remove(at: cardIndex)
        diskSlots[index] = card
        fieldBackRow[index] = card
        selectedHandCardId = nil
        phase = .idle
    }

    /// 選択中の *魔法・トラップ* カードをディスクの空き挿入口に配置する。
    /// - 選択カードが魔法・トラップでない場合は拒否。
    /// - 配置と同時に、対応するフィールド手前列(`fieldFrontRow[index]`)にも反映する。
    public func placeSelectedCardToSpellSlot(index: Int) {
        guard (0..<Self.diskSlotCount).contains(index) else { return }
        guard let card = selectedCard, card.isSpellOrTrap else { return }
        guard let cardIndex = hand.firstIndex(where: { $0.id == card.id }) else { return }
        guard spellSlots[index] == nil else { return } // 上書き拒否

        hand.remove(at: cardIndex)
        spellSlots[index] = card
        fieldFrontRow[index] = card
        fieldFrontRevealed[index] = false // 魔法・トラップは基本裏で置く
        selectedHandCardId = nil
        phase = .idle
    }

    /// 配置済みカードを表にする(オープン)。フィールド手前列(魔法・トラップ)が対象。
    public func openPlacedCard(at context: PlacedCardContext) {
        switch context {
        case .fieldFront(let c), .spellSlot(let c):
            guard (0..<Self.diskSlotCount).contains(c) else { return }
            fieldFrontRevealed[c] = true
        case .diskSlot, .fieldBack:
            break // モンスターは常に表なのでオープン不要
        }
        tappedPlacedCardContext = nil
    }

    /// 指定コンテキストのカードがオープン(表)可能か(=まだ裏の魔法・トラップか)。
    public func canOpenCard(at context: PlacedCardContext) -> Bool {
        switch context {
        case .fieldFront(let c), .spellSlot(let c):
            guard (0..<Self.diskSlotCount).contains(c) else { return false }
            return fieldFrontRow[c] != nil && fieldFrontRevealed[c] == false
        case .diskSlot, .fieldBack:
            return false
        }
    }

    /// 配置済みカードを削除する。ディスク側とフィールド側は対で消す。
    public func removePlacedCard(at context: PlacedCardContext) {
        switch context {
        case .diskSlot(let i), .fieldBack(let i):
            guard (0..<Self.diskSlotCount).contains(i) else { return }
            diskSlots[i] = nil
            fieldBackRow[i] = nil
        case .spellSlot(let i), .fieldFront(let i):
            guard (0..<Self.diskSlotCount).contains(i) else { return }
            spellSlots[i] = nil
            fieldFrontRow[i] = nil
            fieldFrontRevealed[i] = false
        }
        tappedPlacedCardContext = nil
    }
}
