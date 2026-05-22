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
        /// 手札のカードを選択中(=召喚スロット待ち)
        case selectingFromHand
    }

    // MARK: - 定数

    /// ImmersiveSpace 入室時に配るカード枚数
    public static let initialHandSize: Int = 5
    /// 手札上限(これ以上はドローしない)
    public static let handCapacity: Int = 7
    /// ディスク上の召喚スロット数
    public static let diskSlotCount: Int = 5

    // MARK: - 状態

    public var phase: Phase = .idle
    public var hand: [CardModel] = []
    public var rightHandCard: CardModel?
    public var selectedHandCardId: CardModel.ID?
    public var diskSlots: [CardModel?] = Array(repeating: nil, count: diskSlotCount)
    public var arenaSlotsBack: [CardModel?] = Array(repeating: nil, count: diskSlotCount)
    public var arenaSlotsFront: [CardModel?] = Array(repeating: nil, count: diskSlotCount)

    /// 配置済みカードをタップしたときに表示するメニューのコンテキスト
    public var tappedPlacedCardContext: PlacedCardContext?

    // MARK: - ハンドトラッキング状態(System から書き戻される)

    public var isLeftPinching: Bool = false
    public var isRightPinching: Bool = false

    public init() {}

    // MARK: - ライフサイクル

    /// 新規デュエル開始: 5枚配る + 状態を全リセット。
    public func startNewDuel() {
        hand = (0..<Self.initialHandSize).map { _ in CardModel() }
        rightHandCard = nil
        selectedHandCardId = nil
        diskSlots = Array(repeating: nil, count: Self.diskSlotCount)
        arenaSlotsBack = Array(repeating: nil, count: Self.diskSlotCount)
        arenaSlotsFront = Array(repeating: nil, count: Self.diskSlotCount)
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
        let newCard = CardModel()
        rightHandCard = newCard
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
    public func selectHandCard(id: CardModel.ID) {
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

    /// 選択中のカードをディスクの空きスロットに配置する。
    /// - 既にカードがあるスロットへの配置は拒否(B5確定)。
    /// - 配置と同時に、対応する召喚エリア奥列(`arenaSlotsBack[index]`) にも同じカードを反映する。
    ///   ディスクへの設置 → アリーナ召喚 という連携は仕様上「常に対」になるため、
    ///   View 層の `.onChange` で書き戻すと連鎖が分かりづらいので Store 層に集約している。
    public func placeSelectedCardToDiskSlot(index: Int) {
        guard (0..<Self.diskSlotCount).contains(index) else { return }
        guard let cardId = selectedHandCardId,
              let cardIndex = hand.firstIndex(where: { $0.id == cardId }) else { return }
        guard diskSlots[index] == nil else { return } // 上書き拒否

        let card = hand.remove(at: cardIndex)
        diskSlots[index] = card
        arenaSlotsBack[index] = card
        selectedHandCardId = nil
        phase = .idle
    }

    /// 配置済みカードを削除する。
    /// - `.diskSlot(i)` を消したら、対応する召喚エリア(`arenaSlotsBack[i]`)も連動して消す。
    public func removePlacedCard(at context: PlacedCardContext) {
        switch context {
        case .diskSlot(let i):
            guard (0..<Self.diskSlotCount).contains(i) else { return }
            diskSlots[i] = nil
            // 一貫性のため、召喚エリア奥列も同時に消す
            arenaSlotsBack[i] = nil
        case .arenaBack(let c):
            guard (0..<Self.diskSlotCount).contains(c) else { return }
            arenaSlotsBack[c] = nil
            // ディスク側にも残っていれば一緒に消すと一貫する
            diskSlots[c] = nil
        case .arenaFront(let c):
            guard (0..<Self.diskSlotCount).contains(c) else { return }
            arenaSlotsFront[c] = nil
        }
        tappedPlacedCardContext = nil
    }
}
