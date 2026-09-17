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
    public static let initialHandSize: Int = 6
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

    // MARK: - ドローのクールダウン

    /// カードをセット(召喚/設置)した直後にドローを受け付けない時間。
    /// セットした右手がそのままデッキに触れて、意図せずカードを引いてしまう誤爆を防ぐ。
    public static let drawCooldownAfterPlacement: TimeInterval = 1.0
    /// 最後にカードをセットした時刻(未セットなら nil)。
    public var lastCardPlacedAt: Date?
    /// 現在時刻の供給元。テストで時間を進めるために差し替え可能。
    @ObservationIgnored public var now: () -> Date = Date.init
    /// セット直後のクールダウン中で、いまはドローを受け付けない状態か。
    public var isDrawBlockedByPlacementCooldown: Bool {
        guard let placedAt = lastCardPlacedAt else { return false }
        return now().timeIntervalSince(placedAt) < Self.drawCooldownAfterPlacement
    }

    // MARK: - 対戦(相手陣)

    /// 相手フィールド奥列(モンスター)。相手からの `DuelEvent` でのみ更新される。
    public var opponentFieldBackRow: [DuelCard?] = Array(repeating: nil, count: diskSlotCount)
    /// 相手フィールド手前列(魔法・トラップ)。
    public var opponentFieldFrontRow: [DuelCard?] = Array(repeating: nil, count: diskSlotCount)
    /// 相手フィールド手前列のカードが表(オープン済み)かどうか。
    public var opponentFieldFrontRevealed: [Bool] = Array(repeating: false, count: diskSlotCount)
    /// 相手のピア情報(`.hello` 受信で設定)。
    public var opponentInfo: DuelPeerInfo?
    /// true のとき View は相手陣を描画する。
    public var isMultiplayerActive: Bool = false
    /// ローカル操作で盤面が変わったときに呼ばれる(送信用)。nil なら何もしない。
    public var eventSink: ((DuelEvent) -> Void)?

    // MARK: - ハンドトラッキング状態(System から書き戻される)

    public var isLeftPinching: Bool = false
    public var isRightPinching: Bool = false

    public init() {}

    // MARK: - 派生状態

    /// 現在選択中のカード。
    /// 手札にある場合はそれを、選択したまま右手へ持ち替えた場合は右手のカードを返す。
    /// (「選択中のカードを右手に持っている」状態を選択として扱うことで、
    ///  選択なしで右手にカードがあるのはドロー時だけ、という不変条件を保つ)
    public var selectedCard: DuelCard? {
        guard let id = selectedHandCardId else { return nil }
        if let inHand = hand.first(where: { $0.id == id }) { return inHand }
        if let right = rightHandCard, right.id == id { return right }
        return nil
    }

    /// 現在選択中のカードの種類(未選択なら nil)。
    public var selectedCardKind: DuelCard.Kind? {
        selectedCard?.kind
    }

    // MARK: - ライフサイクル

    /// 新規デュエル開始: 初期手札を配る + 状態を全リセット。
    public func startNewDuel() {
        // デモ用に初期手札を固定構成にする(順番もこの通り):
        //  1. 龍のモンスター(緋天竜)
        //  2. あんこのたい焼き / 3. 抹茶 / 4. クリーム
        //  5. 魔法カード(黄金の命の水) / 6. トラップ(仕様変更)
        let taiyaki = MonsterCard.samples
        func taiyakiCard(_ flavor: TaiyakiFlavor) -> DuelCard {
            .monster(taiyaki.first { $0.flavor == flavor } ?? taiyaki[0])
        }
        var dealt: [DuelCard] = [
            .monster(MonsterCard.hitenryu),
            taiyakiCard(.redBean),
            taiyakiCard(.matcha),
            taiyakiCard(.cream),
        ]
        if let spell = SpellCard.samples.first { dealt.append(.spell(spell)) }        // 黄金の命の水
        if let trap = TrapCard.samples.first(where: { $0.name == "仕様変更" }) {
            dealt.append(.trap(trap))
        } else if let trap = TrapCard.samples.last {
            dealt.append(.trap(trap))
        }
        hand = dealt
        rightHandCard = nil
        selectedHandCardId = nil
        diskSlots = Array(repeating: nil, count: Self.diskSlotCount)
        spellSlots = Array(repeating: nil, count: Self.diskSlotCount)
        fieldBackRow = Array(repeating: nil, count: Self.diskSlotCount)
        fieldFrontRow = Array(repeating: nil, count: Self.diskSlotCount)
        fieldFrontRevealed = Array(repeating: false, count: Self.diskSlotCount)
        tappedPlacedCardContext = nil
        phase = .idle
        // 相手陣(opponent*)と isMultiplayerActive は相手側が所有する状態なのでここでは触らない。
        eventSink?(.newDuel)
    }

    // MARK: - 操作

    /// ドロー判定: 右手がデッキに接触している間に呼ばれる。
    /// - 既に右手にカードがある場合は無視。
    /// - 手札上限に達している場合も無視。
    /// - 検証目的のためデッキ残り枚数の制限は設けない(無限ドロー可)。
    /// - カードをセットした直後(`drawCooldownAfterPlacement` 以内)は無視。
    public func drawCard() {
        guard rightHandCard == nil else { return }
        guard hand.count < Self.handCapacity else { return }
        guard !isDrawBlockedByPlacementCooldown else { return }
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
        // 右手へ持ち替えていた選択カードを扇に戻したときは、選択も解除する
        // (戻したカードが選択されたまま残らないように)。
        if selectedHandCardId == card.id { selectedHandCardId = nil }
        phase = .idle
    }

    /// 選択中の手札カードを「右手に持ち替える」。
    /// デッキから引いたカードと同じ扱い(rightHandCard)にして、右手に追従表示する。
    /// - 既に右手にカードがある場合や、選択カードが無い場合は何もしない。
    @discardableResult
    public func moveSelectedCardToRightHand() -> Bool {
        guard rightHandCard == nil else { return false }
        guard let card = selectedCard else { return false }
        guard let cardIndex = hand.firstIndex(where: { $0.id == card.id }) else { return false }
        hand.remove(at: cardIndex)
        rightHandCard = card
        // 選択は保持する(=選択中のカードを右手に持っている状態)。
        // これで「選択なしで右手にカードがある」のはドロー時だけになる(ドローとは phase で区別)。
        selectedHandCardId = card.id
        phase = .selectingFromHand
        return true
    }

    /// 右手に持っているカードを、ディスクの空き召喚スロットに「召喚」する。
    /// (右手カードをカード置き場に重ねたときに呼ぶ)
    /// - 手札から選択して持ち替えたカード(選択中)だけが対象。ドロー直後の未選択カードは、
    ///   置き場にたまたま重なっても配置しない(まず扇に取り込み、選択してから置く)。
    /// - 右手カードがモンスターでない/スロットが埋まっている場合は拒否。
    /// - placeSelectedCardToDiskSlot と同様に fieldBackRow にも反映する。
    @discardableResult
    public func summonRightHandCardToDiskSlot(index: Int) -> Bool {
        guard (0..<Self.diskSlotCount).contains(index) else { return false }
        guard let card = rightHandCard, card.kind == .monster else { return false }
        guard selectedHandCardId == card.id else { return false } // ドロー直後(未選択)は配置不可
        guard diskSlots[index] == nil else { return false }
        diskSlots[index] = card
        fieldBackRow[index] = card
        rightHandCard = nil
        // 右手のカード=選択中のカードだった場合があるため選択も解除する。
        selectedHandCardId = nil
        phase = .idle
        lastCardPlacedAt = now()
        eventSink?(.summonMonster(slot: index, card: card))
        return true
    }

    /// 右手に持っている魔法・トラップカードを、ディスクの空き挿入口に設置する。
    /// (右手カードを挿入口の空間に重ねたときに呼ぶ)
    /// - 手札から選択して持ち替えたカード(選択中)だけが対象。ドロー直後の未選択カードが
    ///   挿入口に意図せず重なって設置される不具合を防ぐ。
    @discardableResult
    public func placeRightHandCardToSpellSlot(index: Int) -> Bool {
        guard (0..<Self.diskSlotCount).contains(index) else { return false }
        guard let card = rightHandCard, card.isSpellOrTrap else { return false }
        guard selectedHandCardId == card.id else { return false } // ドロー直後(未選択)は配置不可
        guard spellSlots[index] == nil else { return false }
        spellSlots[index] = card
        fieldFrontRow[index] = card
        fieldFrontRevealed[index] = false // 魔法・トラップは基本裏で置く
        rightHandCard = nil
        phase = .idle
        lastCardPlacedAt = now()
        eventSink?(.setSpellOrTrap(slot: index, card: card))
        return true
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
        lastCardPlacedAt = now()
        eventSink?(.summonMonster(slot: index, card: card))
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
        lastCardPlacedAt = now()
        eventSink?(.setSpellOrTrap(slot: index, card: card))
    }

    /// 配置済みカードを表にする(オープン)。フィールド手前列(魔法・トラップ)が対象。
    public func openPlacedCard(at context: PlacedCardContext) {
        switch context {
        case .fieldFront(let c), .spellSlot(let c):
            guard (0..<Self.diskSlotCount).contains(c) else { return }
            // 実際に裏→表へ変わったときだけ相手へ通知する。
            let didReveal = fieldFrontRow[c] != nil && fieldFrontRevealed[c] == false
            fieldFrontRevealed[c] = true
            if didReveal { eventSink?(.openCard(slot: c)) }
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
            eventSink?(.removeCard(row: .back, slot: i))
        case .spellSlot(let i), .fieldFront(let i):
            guard (0..<Self.diskSlotCount).contains(i) else { return }
            spellSlots[i] = nil
            fieldFrontRow[i] = nil
            fieldFrontRevealed[i] = false
            eventSink?(.removeCard(row: .front, slot: i))
        }
        tappedPlacedCardContext = nil
    }

    // MARK: - 対戦(相手陣)

    /// 自分のフィールド(奥列 / 手前列 / 表裏)のスナップショット。接続直後の同期送信に使う。
    public func fieldSnapshot() -> DuelFieldSnapshot {
        DuelFieldSnapshot(
            backRow: fieldBackRow,
            frontRow: fieldFrontRow,
            frontRevealed: fieldFrontRevealed
        )
    }

    /// 相手から受信したイベントを、自分の相手陣(opponent*)へ適用する。
    /// 相手が送ってきた値は信用しない:
    /// - 範囲外 slot のイベントは無視する。
    /// - カードは `sanitizedForWire()` で値域を丸めてから保存する(描画側のクラッシュ防止)。
    /// - `.summonMonster` はモンスター、`.setSpellOrTrap` は魔法・トラップ以外を無視する。
    /// - `.snapshot` は 3 配列すべてが `diskSlotCount` 長でなければイベントごと無視し、
    ///   列に合わない種類のカードは nil に置き換える。
    /// - `.hello` の文字列は 64 文字に切り詰める。
    public func applyOpponentEvent(_ event: DuelEvent) {
        let range = 0..<Self.diskSlotCount
        switch event {
        case .hello(let info):
            opponentInfo = info.sanitizedForWire()
        case .snapshot(let snapshot):
            guard snapshot.backRow.count == Self.diskSlotCount,
                  snapshot.frontRow.count == Self.diskSlotCount,
                  snapshot.frontRevealed.count == Self.diskSlotCount
            else { return }
            opponentFieldBackRow = snapshot.backRow.map { card in
                guard let card, card.kind == .monster else { return nil }
                return card.sanitizedForWire()
            }
            opponentFieldFrontRow = snapshot.frontRow.map { card in
                guard let card, card.isSpellOrTrap else { return nil }
                return card.sanitizedForWire()
            }
            opponentFieldFrontRevealed = snapshot.frontRevealed
        case .summonMonster(let slot, let card):
            guard range.contains(slot), card.kind == .monster else { return }
            opponentFieldBackRow[slot] = card.sanitizedForWire()
        case .setSpellOrTrap(let slot, let card):
            guard range.contains(slot), card.isSpellOrTrap else { return }
            opponentFieldFrontRow[slot] = card.sanitizedForWire()
            opponentFieldFrontRevealed[slot] = false
        case .openCard(let slot):
            guard range.contains(slot) else { return }
            opponentFieldFrontRevealed[slot] = true
        case .removeCard(let row, let slot):
            guard range.contains(slot) else { return }
            switch row {
            case .back:
                opponentFieldBackRow[slot] = nil
            case .front:
                opponentFieldFrontRow[slot] = nil
                opponentFieldFrontRevealed[slot] = false
            }
        case .newDuel:
            resetOpponentField()
        }
    }

    /// 相手陣の盤面(3配列)を空に戻す。`opponentInfo` は保持する。
    public func resetOpponentField() {
        opponentFieldBackRow = Array(repeating: nil, count: Self.diskSlotCount)
        opponentFieldFrontRow = Array(repeating: nil, count: Self.diskSlotCount)
        opponentFieldFrontRevealed = Array(repeating: false, count: Self.diskSlotCount)
    }
}
