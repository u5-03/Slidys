//
//  YugiohDuelDiskImmersiveView.swift
//  YugiohDuelDiskPackage
//
//  デュエルディスク体験の本体 ImmersiveView。Phase A3〜C を 1 View で組み立てる。
//
//  構成:
//   - 左手首 AnchorEntity に ディスクボード + デッキ + スロット5枚 を装着
//   - 左手の親指/人差し指 AnchorEntity を使ったピンチ判定で、左手の上に扇手札を表示
//   - 右手 thumbTip プローブ + デッキ の衝突 → 右ピンチ中ならドロー
//   - 右手 indexFingerTip プローブ + (扇カード / 配置済カード / ディスクスロット) の衝突
//     → 選択 / 配置 / コンテキストメニュー
//   - 右手カードと左手 palm の衝突 → 扇に取り込み
//   - 床平面 anchor で 5×2 召喚エリア + sugiy モンスター召喚
//

#if os(visionOS)
import ARKit
import HandGestureKit
import RealityKit
import SwiftUI
#if canImport(Sugiy)
import Sugiy
#endif
#if canImport(UIKit)
import UIKit
#endif

@MainActor
public struct YugiohDuelDiskImmersiveView: View {
    @Environment(\.duelAppModel) private var duelAppModel
    @Environment(\.duelSessionStore) private var sessionStore

    // ルート
    @State private var rootEntity = Entity()
    @State private var spatialTrackingSession = SpatialTrackingSession()

    // 左腕装着リグ
    @State private var leftWristAnchor: AnchorEntity?
    @State private var boardEntity: ModelEntity?
    @State private var deckEntity: ModelEntity?
    @State private var diskSlotEntities: [ModelEntity] = []
    @State private var placedDiskCardEntities: [UUID: ModelEntity] = [:]

    // 左手ピンチ判定用 (anchor は HandTrackingComponent.fingers に格納)
    @State private var leftThumbTipAnchor: AnchorEntity?
    @State private var leftIndexTipAnchor: AnchorEntity?
    @State private var leftPalmAnchor: AnchorEntity?
    @State private var leftHandComponent: HandTrackingComponent?

    // 右手ピンチ判定用
    @State private var rightThumbTipAnchor: AnchorEntity?
    @State private var rightIndexTipAnchor: AnchorEntity?
    @State private var rightThumbProbe: ModelEntity?
    @State private var rightIndexProbe: ModelEntity?
    @State private var rightHandComponent: HandTrackingComponent?

    // 扇手札 Entity (cardId -> ModelEntity)
    @State private var fanCardEntities: [UUID: ModelEntity] = [:]

    // 右手のドロー中カード
    @State private var rightHandCardEntity: ModelEntity?

    // 召喚エリア
    @State private var arenaRoot: AnchorEntity?
    @State private var arenaCardEntities: [Int: Entity] = [:]
    @State private var arenaMonsterEntities: [Int: Entity] = [:]
    /// col ごとの召喚 Task。新しい召喚要求が来たら旧 Task をキャンセルする。
    @State private var arenaSummonTasks: [Int: Task<Void, Never>] = [:]

    // 衝突購読 & polling
    @State private var collisionSubscriptions: [EventSubscription] = []
    @State private var pinchPollTask: Task<Void, Never>?

    // attachment の親付け済みフラグ(update 内での再 addChild 防止)
    @State private var attachmentInstalled: Bool = false

    public init() {}

    public var body: some View {
        RealityView { content, attachments in
            content.add(rootEntity)
            await requestHandTrackingAuthorization()
            await startSpatialTrackingSession()
            await setupAnchors()
            setupDiskRig()
            setupArena()
            installCollisionSubscriptions(content: content)
            installAttachmentIfNeeded(attachments)

            // anchor / Component が揃ってから polling を起動する。
            // `onAppear` で起動すると make の async 待ちを追い抜くため、ここで起動する。
            startPinchPolling()

            // 入室時に新規デュエル開始
            sessionStore.startNewDuel()
            duelAppModel.updateImmersiveSpaceState(.open)
        } update: { _, attachments in
            // 初回 make で attachments を取り損ねていた場合の保険 + 位置更新
            installAttachmentIfNeeded(attachments)
            updateAttachmentPlacement(attachments)
        } attachments: {
            Attachment(id: AttachmentID.placedCardMenu) {
                if let ctx = sessionStore.tappedPlacedCardContext {
                    CardActionMenuView(
                        context: ctx,
                        onDelete: {
                            // Entity の removeFromParent は `onChange(of: diskSlots / arenaSlotsBack)` 経由の
                            // `syncDiskSlotCardEntities` / `syncArenaBackEntities` が担当する。
                            // View 層は Store 状態を変更するだけに留め、削除責務を一本化する。
                            sessionStore.removePlacedCard(at: ctx)
                        },
                        onCancel: {
                            sessionStore.tappedPlacedCardContext = nil
                        }
                    )
                } else {
                    EmptyView()
                }
            }
        }
        .upperLimbVisibility(.hidden)
        .onDisappear {
            tearDown()
        }
        // 手札変化 → 扇 Entity を再構築
        .onChange(of: sessionStore.hand) { _, newValue in
            rebuildHandFan(cards: newValue)
        }
        // 選択 → ハイライト(浮かせる)
        .onChange(of: sessionStore.selectedHandCardId) { _, _ in
            applySelectedHighlight()
        }
        // 左手ピンチ状態 → 扇の表示/非表示
        .onChange(of: sessionStore.isLeftPinching) { _, isPinching in
            leftPalmAnchor?.isEnabled = isPinching
        }
        // 右手カード → Entity 同期
        .onChange(of: sessionStore.rightHandCard) { _, card in
            syncRightHandCardEntity(card: card)
        }
        // ディスクスロット → 配置カード Entity 同期(Store はここで arenaSlotsBack を同時更新済み)
        .onChange(of: sessionStore.diskSlots) { _, newSlots in
            syncDiskSlotCardEntities(newSlots: newSlots)
        }
        // 召喚エリア(奥) → カード + モンスター Entity 同期
        .onChange(of: sessionStore.arenaSlotsBack) { _, newSlots in
            syncArenaBackEntities(newSlots: newSlots)
        }
    }
}

// MARK: - 定数

private enum AttachmentID {
    static let placedCardMenu = "duelDiskPlacedCardMenu"
}

private enum DuelCollisionGroup {
    static let deck: CollisionGroup = .init(rawValue: 1 << 1)
    static let handCard: CollisionGroup = .init(rawValue: 1 << 2)
    static let rightHandCard: CollisionGroup = .init(rawValue: 1 << 3)
    static let leftPalm: CollisionGroup = .init(rawValue: 1 << 4)
    static let diskSlot: CollisionGroup = .init(rawValue: 1 << 5)
    static let placedCard: CollisionGroup = .init(rawValue: 1 << 6)
    /// 右親指 Tip プローブ(専用グループ — デッキ判定のみ)
    static let rightThumbProbe: CollisionGroup = .init(rawValue: 1 << 7)
    /// 右人差し指 Tip プローブ(専用グループ — タップ判定)
    static let rightIndexProbe: CollisionGroup = .init(rawValue: 1 << 8)
}

// MARK: - ログ

private enum DuelLog {
    static func log(_ message: @autoclosure () -> String) {
        print("[DuelDisk] \(message())")
    }
}

// MARK: - 初期化処理

private extension YugiohDuelDiskImmersiveView {
    func requestHandTrackingAuthorization() async {
        let session = ARKitSession()
        let result = await session.requestAuthorization(for: [.handTracking])
        if result[.handTracking] != .allowed {
            DuelLog.log("⚠️ Hand tracking authorization not allowed: \(String(describing: result[.handTracking]))")
        }
    }

    func startSpatialTrackingSession() async {
        let config = SpatialTrackingSession.Configuration(tracking: [.hand])
        let unavailable = await spatialTrackingSession.run(config)
        if let unavailable {
            DuelLog.log("⚠️ SpatialTrackingSession unavailable capabilities: \(unavailable)")
        }
    }

    func setupAnchors() async {
        // 左手首
        let wrist = AnchorEntity(
            .hand(.left, location: .joint(for: .wrist)),
            trackingMode: .predicted
        )
        wrist.name = "LeftWristAnchor"
        rootEntity.addChild(wrist)
        leftWristAnchor = wrist

        // 左手 thumbTip / indexFingerTip (ピンチ距離判定用)
        let lThumb = AnchorEntity(
            .hand(.left, location: .joint(for: .thumbTip)),
            trackingMode: .predicted
        )
        lThumb.name = "LeftThumbTipAnchor"
        rootEntity.addChild(lThumb)
        leftThumbTipAnchor = lThumb

        let lIndex = AnchorEntity(
            .hand(.left, location: .joint(for: .indexFingerTip)),
            trackingMode: .predicted
        )
        lIndex.name = "LeftIndexTipAnchor"
        rootEntity.addChild(lIndex)
        leftIndexTipAnchor = lIndex

        // 左 palm — 扇手札の親
        let palm = AnchorEntity(
            .hand(.left, location: .palm),
            trackingMode: .predicted
        )
        palm.name = "LeftPalmAnchor"
        palm.isEnabled = false // ピンチ中のみ enable
        // palm 周囲に「右手カードを吸い込む」用の大球コリジョン
        palm.components.set(CollisionComponent(
            shapes: [.generateSphere(radius: 0.07)],
            mode: .trigger,
            filter: CollisionFilter(
                group: DuelCollisionGroup.leftPalm,
                mask: DuelCollisionGroup.rightHandCard
            )
        ))
        rootEntity.addChild(palm)
        leftPalmAnchor = palm

        // 右手 thumbTip / indexFingerTip
        let rThumb = AnchorEntity(
            .hand(.right, location: .joint(for: .thumbTip)),
            trackingMode: .predicted
        )
        rThumb.name = "RightThumbTipAnchor"
        rootEntity.addChild(rThumb)
        rightThumbTipAnchor = rThumb

        let rIndex = AnchorEntity(
            .hand(.right, location: .joint(for: .indexFingerTip)),
            trackingMode: .predicted
        )
        rIndex.name = "RightIndexTipAnchor"
        rootEntity.addChild(rIndex)
        rightIndexTipAnchor = rIndex

        // 右親指プローブ — group は専用(rightThumbProbe)、mask は [deck] だけ
        let thumbProbe = ModelEntity()
        thumbProbe.name = "RightThumbProbe"
        thumbProbe.components.set(RightThumbProbeComponent())
        thumbProbe.components.set(CollisionComponent(
            shapes: [.generateSphere(radius: DuelDiskMetrics.handTipProbeRadius)],
            mode: .trigger,
            filter: CollisionFilter(
                group: DuelCollisionGroup.rightThumbProbe,
                mask: [DuelCollisionGroup.deck]
            )
        ))
        rThumb.addChild(thumbProbe)
        rightThumbProbe = thumbProbe

        // 右人差し指プローブ — group は専用(rightIndexProbe)、mask は タップ対象
        let indexProbe = ModelEntity()
        indexProbe.name = "RightIndexProbe"
        indexProbe.components.set(RightIndexProbeComponent())
        indexProbe.components.set(CollisionComponent(
            shapes: [.generateSphere(radius: DuelDiskMetrics.handTipProbeRadius)],
            mode: .trigger,
            filter: CollisionFilter(
                group: DuelCollisionGroup.rightIndexProbe,
                mask: [
                    DuelCollisionGroup.handCard,
                    DuelCollisionGroup.diskSlot,
                    DuelCollisionGroup.placedCard,
                ]
            )
        ))
        rIndex.addChild(indexProbe)
        rightIndexProbe = indexProbe

        // HandGestureKit のピンチ判定 API を使うために HandTrackingComponent を組み立てる。
        // 内部実装は fingers[.thumbTip] / fingers[.indexFingerTip] の position を見るだけなので、
        // この2関節分だけ詰めれば `areFingerTipsTouching` が動作する。
        var lhc = HandTrackingComponent(chirality: .left)
        lhc.fingers[.thumbTip] = lThumb
        lhc.fingers[.indexFingerTip] = lIndex
        leftHandComponent = lhc

        var rhc = HandTrackingComponent(chirality: .right)
        rhc.fingers[.thumbTip] = rThumb
        rhc.fingers[.indexFingerTip] = rIndex
        rightHandComponent = rhc
    }

    func setupDiskRig() {
        guard let wrist = leftWristAnchor else { return }
        // Board
        let board = DuelDiskBoardFactory.makeBoard()
        wrist.addChild(board)
        boardEntity = board

        // Deck
        let deck = DeckEntityFactory.make()
        deck.position = SIMD3<Float>(
            0,
            DuelDiskMetrics.boardThickness / 2 + DuelDiskMetrics.deckHeight / 2,
            DuelDiskMetrics.boardDepth / 4
        )
        deck.components.set(CollisionComponent(
            shapes: [
                .generateBox(size: SIMD3<Float>(
                    DuelDiskMetrics.cardWidth,
                    DuelDiskMetrics.deckHeight,
                    DuelDiskMetrics.cardDepth
                ))
            ],
            mode: .trigger,
            filter: CollisionFilter(
                group: DuelCollisionGroup.deck,
                mask: DuelCollisionGroup.rightThumbProbe
            )
        ))
        board.addChild(deck)
        deckEntity = deck

        // ディスクスロット ×5
        let slots = DiskSlotFactory.makeSlots()
        for slot in slots {
            slot.components.set(CollisionComponent(
                shapes: [
                    .generateBox(size: SIMD3<Float>(
                        DuelDiskMetrics.diskSlotWidth,
                        0.005,
                        DuelDiskMetrics.diskSlotDepth
                    ))
                ],
                mode: .trigger,
                filter: CollisionFilter(
                    group: DuelCollisionGroup.diskSlot,
                    mask: DuelCollisionGroup.rightIndexProbe
                )
            ))
            board.addChild(slot)
        }
        diskSlotEntities = slots
    }

    func setupArena() {
        let arena = AnchorEntity(
            .plane(
                .horizontal,
                classification: .floor,
                minimumBounds: SIMD2<Float>(1.0, 1.0)
            )
        )
        arena.name = "ArenaRoot"
        rootEntity.addChild(arena)
        arenaRoot = arena

        let slots = ArenaSlotFactory.makeArena()
        arena.addChild(slots)
    }

    /// 衝突購読を **対象 entity を限定して** 仕掛ける。
    /// 旧実装の wildcard subscribe は別グループの誤通知を拾うリスクがあったため、
    /// プローブごとに明示的に entity を渡している。
    func installCollisionSubscriptions(content: RealityViewContent) {
        // 1) 右親指プローブ → デッキ衝突 → ドロー
        if let thumbProbe = rightThumbProbe {
            let sub = content.subscribe(to: CollisionEvents.Began.self, on: thumbProbe) { event in
                Task { @MainActor in
                    // 右手がピンチしているときのみドロー
                    guard sessionStore.isRightPinching else { return }
                    let other = otherEntity(event: event, against: thumbProbe)
                    // デッキ識別は DeckMarkerComponent で行う(name 文字列は使わない)
                    guard other.components[DeckMarkerComponent.self] != nil else { return }
                    sessionStore.drawCard()
                }
            }
            collisionSubscriptions.append(sub)
        }

        // 2) 右人差し指プローブ → 扇カード / ディスクスロット / 配置済カードのタップ
        if let indexProbe = rightIndexProbe {
            let sub = content.subscribe(to: CollisionEvents.Began.self, on: indexProbe) { event in
                Task { @MainActor in
                    let other = otherEntity(event: event, against: indexProbe)
                    handleIndexTap(on: other)
                }
            }
            collisionSubscriptions.append(sub)
        }

        // 3) 左 palm ↔ 右手カード → 扇に取り込み
        if let palm = leftPalmAnchor {
            let sub = content.subscribe(to: CollisionEvents.Began.self, on: palm) { _ in
                Task { @MainActor in
                    // 左がピンチ中(扇表示中)のみ取り込む
                    guard sessionStore.isLeftPinching else { return }
                    sessionStore.addRightHandCardToFan()
                }
            }
            collisionSubscriptions.append(sub)
        }
    }

    func installAttachmentIfNeeded(_ attachments: RealityViewAttachments) {
        // RealityView の attachments クロージャで生成された SwiftUI ビュー Entity を
        // シーングラフに組み込む。entity(for:) の返り値は identity が保たれる前提だが、
        // make の時点で取り損ねた場合や、State がリセットされた場合に備えて
        // update でも呼べる(`attachmentInstalled` で 1 回だけ親付けする)。
        guard !attachmentInstalled,
              let menu = attachments.entity(for: AttachmentID.placedCardMenu) else { return }
        rootEntity.addChild(menu)
        menu.isEnabled = false
        attachmentInstalled = true
    }
}

// MARK: - 衝突ハンドラ補助

private extension YugiohDuelDiskImmersiveView {
    /// 衝突イベントから「自分以外」のエンティティを取り出す。
    func otherEntity(event: CollisionEvents.Began, against me: Entity) -> Entity {
        event.entityA === me ? event.entityB : event.entityA
    }

    /// 右人差し指プローブが何かに触れたとき: スロット → カード の順に Component で判定する。
    func handleIndexTap(on other: Entity) {
        // スロット
        if let slotIdx = other.components[DiskSlotIndexComponent.self]?.index {
            if sessionStore.phase == .selectingFromHand {
                sessionStore.placeSelectedCardToDiskSlot(index: slotIdx)
            }
            return
        }
        // 配置済みカード: タップされた Entity に直接コンテキストが乗っているので、
        // 探索順依存(同一 card.id がディスクとアリーナ両方に居る)による誤識別を防げる。
        if let locationComp = other.components[PlacedCardLocationComponent.self] {
            sessionStore.tappedPlacedCardContext = mapToContext(locationComp.location)
            return
        }
        // 扇の手札カード
        if let cardId = other.components[CardIdentityComponent.self]?.id,
           sessionStore.hand.contains(where: { $0.id == cardId }) {
            sessionStore.selectHandCard(id: cardId)
            return
        }
    }

    func mapToContext(_ location: PlacedCardLocationComponent.Location) -> PlacedCardContext {
        switch location {
        case .diskSlot(let i): return .diskSlot(i)
        case .arenaBack(let i): return .arenaBack(i)
        case .arenaFront(let i): return .arenaFront(i)
        }
    }
}

// MARK: - ピンチ判定 (Timer ベース)

private extension YugiohDuelDiskImmersiveView {
    func startPinchPolling() {
        pinchPollTask?.cancel()
        pinchPollTask = Task { @MainActor in
            while !Task.isCancelled {
                updatePinchState()
                try? await Task.sleep(nanoseconds: DuelDiskMetrics.pinchPollIntervalNanos)
            }
        }
    }

    func updatePinchState() {
        // 左手ピンチ判定
        if let lhc = leftHandComponent {
            sessionStore.isLeftPinching = computePinching(component: lhc)
        }
        // 右手ピンチ判定
        if let rhc = rightHandComponent {
            sessionStore.isRightPinching = computePinching(component: rhc)
        }
    }

    /// HandGestureKit の `areFingerTipsTouching` を用いてピンチ判定する。
    /// AnchorEntity が未トラッキング時には (0,0,0) を返す可能性があり、その状態では
    /// `areFingerTipsTouching` が「距離 0 < threshold」で誤判定するため、tracked チェックも併用する。
    func computePinching(component: HandTrackingComponent) -> Bool {
        guard let thumbTip = component.fingers[.thumbTip],
              let indexTip = component.fingers[.indexFingerTip] else { return false }
        let thumbPos = thumbTip.position(relativeTo: nil)
        let indexPos = indexTip.position(relativeTo: nil)
        let isTracked = thumbPos != .zero || indexPos != .zero
        guard isTracked else { return false }
        return component.areFingerTipsTouching(
            .thumb,
            .index,
            threshold: DuelDiskMetrics.pinchThreshold
        )
    }
}

// MARK: - 手札扇 Entity 同期

private extension YugiohDuelDiskImmersiveView {
    func rebuildHandFan(cards: [CardModel]) {
        guard let palm = leftPalmAnchor else { return }

        // 既存 Entity を全削除
        for (_, entity) in fanCardEntities {
            entity.removeFromParent()
        }
        fanCardEntities.removeAll()

        // 新規生成 + 扇レイアウト
        let total = cards.count
        let angleSpread: Float = Float(max(total - 1, 1)) * DuelDiskMetrics.fanDegreesPerCard * .pi / 180

        for (i, card) in cards.enumerated() {
            let entity = CardEntityFactory.make(model: card)
            entity.components.set(CollisionComponent(
                shapes: [
                    .generateBox(size: SIMD3<Float>(
                        DuelDiskMetrics.cardWidth,
                        DuelDiskMetrics.cardThickness * 5,
                        DuelDiskMetrics.cardDepth
                    ))
                ],
                mode: .trigger,
                filter: CollisionFilter(
                    group: DuelCollisionGroup.handCard,
                    mask: DuelCollisionGroup.rightIndexProbe
                )
            ))

            let t: Float = total <= 1
                ? 0
                : (Float(i) - Float(total - 1) / 2) / Float(total - 1)
            let angle = t * angleSpread
            entity.transform.rotation = simd_quatf(angle: angle, axis: SIMD3<Float>(0, 1, 0))
            entity.transform.translation = SIMD3<Float>(0, DuelDiskMetrics.fanBaseY, DuelDiskMetrics.fanOffsetZ)
            palm.addChild(entity)
            fanCardEntities[card.id] = entity
        }

        applySelectedHighlight()
    }

    func applySelectedHighlight() {
        for (id, entity) in fanCardEntities {
            let lift: Float = (id == sessionStore.selectedHandCardId)
                ? DuelDiskMetrics.selectedCardLift
                : 0
            entity.transform.translation.y = DuelDiskMetrics.fanBaseY + lift
        }
    }
}

// MARK: - 右手ドロー中カード Entity 同期

private extension YugiohDuelDiskImmersiveView {
    func syncRightHandCardEntity(card: CardModel?) {
        // 既存を一旦消す
        rightHandCardEntity?.removeFromParent()
        rightHandCardEntity = nil

        guard let card = card, let anchor = rightIndexTipAnchor else { return }
        let entity = CardEntityFactory.make(model: card)
        entity.components.set(CollisionComponent(
            shapes: [
                .generateBox(size: SIMD3<Float>(
                    DuelDiskMetrics.cardWidth,
                    DuelDiskMetrics.cardThickness * 5,
                    DuelDiskMetrics.cardDepth
                ))
            ],
            mode: .trigger,
            filter: CollisionFilter(
                group: DuelCollisionGroup.rightHandCard,
                mask: DuelCollisionGroup.leftPalm
            )
        ))
        // 要件: 「人差し指とカードが垂直」
        //   - rightIndexTipAnchor の +Y 軸が「指先方向(指の延長線)」を向く想定。
        //   - カード本体は `generateBox(width:height:depth:)` で X-Z 平面に薄板を作るので、
        //     カードの法線(=厚み方向)はデフォルトで anchor の +Y 軸方向 → これは「指の延長線」と平行。
        //   - 要件「カードと人差し指が垂直」は「カードの面と指の方向が垂直」と解釈し、
        //     法線=指方向 → カードの面と指方向は垂直、で要件を満たす。
        //   - 実機で軸方向が想定とズレた場合は、ここで `simd_quatf(angle:axis:)` を加える。
        entity.transform.rotation = simd_quatf(angle: 0, axis: SIMD3<Float>(1, 0, 0))
        entity.transform.translation = SIMD3<Float>(0, 0.02, 0)
        anchor.addChild(entity)
        rightHandCardEntity = entity
    }
}

// MARK: - ディスクスロット配置カード Entity 同期

private extension YugiohDuelDiskImmersiveView {
    func syncDiskSlotCardEntities(newSlots: [CardModel?]) {
        guard let board = boardEntity else { return }
        // 既存の中で「現在 newSlots に居ない」カードを削除
        let validIds = Set(newSlots.compactMap { $0?.id })
        for (id, entity) in placedDiskCardEntities where !validIds.contains(id) {
            entity.removeFromParent()
            placedDiskCardEntities.removeValue(forKey: id)
        }
        // 新規追加分の Entity を作る
        for (i, optCard) in newSlots.enumerated() {
            guard let card = optCard else { continue }
            if placedDiskCardEntities[card.id] != nil { continue }
            guard i < diskSlotEntities.count else { continue }
            let slot = diskSlotEntities[i]

            let entity = CardEntityFactory.make(model: card)
            entity.components.set(CollisionComponent(
                shapes: [
                    .generateBox(size: SIMD3<Float>(
                        DuelDiskMetrics.cardWidth,
                        DuelDiskMetrics.cardThickness * 5,
                        DuelDiskMetrics.cardDepth
                    ))
                ],
                mode: .trigger,
                filter: CollisionFilter(
                    group: DuelCollisionGroup.placedCard,
                    mask: DuelCollisionGroup.rightIndexProbe
                )
            ))
            entity.transform.translation = slot.position + SIMD3<Float>(0, 0.002, 0)
            // PlacedCardLocationComponent で「ディスクスロットの i 番目」と明示
            entity.components.set(PlacedCardLocationComponent(location: .diskSlot(i)))
            board.addChild(entity)
            placedDiskCardEntities[card.id] = entity
            // arenaSlotsBack への同期は Store 層 (`placeSelectedCardToDiskSlot`) で実施済み。
        }
    }
}

// MARK: - 召喚エリア(地面) Entity 同期 + sugiy 召喚

private extension YugiohDuelDiskImmersiveView {
    func syncArenaBackEntities(newSlots: [CardModel?]) {
        guard let arena = arenaRoot else { return }

        // 削除分: col 単位で arena 子エンティティをクリーンアップ + Task をキャンセル
        for (col, entity) in arenaCardEntities {
            if newSlots.indices.contains(col) == false || newSlots[col] == nil {
                entity.removeFromParent()
                arenaCardEntities.removeValue(forKey: col)
                arenaMonsterEntities[col]?.removeFromParent()
                arenaMonsterEntities.removeValue(forKey: col)
                arenaSummonTasks[col]?.cancel()
                arenaSummonTasks.removeValue(forKey: col)
            }
        }

        // 追加分: 各 col で並列に Task 起動(直列 await による累積待ちを回避)
        for (col, optCard) in newSlots.enumerated() {
            guard let card = optCard else { continue }
            if arenaCardEntities[col] != nil { continue }
            // 旧 Task が残っていればキャンセル
            arenaSummonTasks[col]?.cancel()
            let task = Task { @MainActor in
                await summon(into: arena, at: col, card: card)
            }
            arenaSummonTasks[col] = task
        }
    }

    func summon(into arena: AnchorEntity, at col: Int, card: CardModel) async {
        let pitchX = DuelDiskMetrics.arenaSlotWidth + DuelDiskMetrics.arenaGapX
        let totalCols = DuelDiskMetrics.diskSlotCount
        let offsetX = (Float(col) - Float(totalCols - 1) / 2) * pitchX
        let basePosition = SIMD3<Float>(offsetX, 0.002, DuelDiskMetrics.arenaBackZ)

        // カード本体
        let cardEntity = CardEntityFactory.make(model: card)
        cardEntity.components.set(CollisionComponent(
            shapes: [
                .generateBox(size: SIMD3<Float>(
                    DuelDiskMetrics.cardWidth,
                    DuelDiskMetrics.cardThickness * 5,
                    DuelDiskMetrics.cardDepth
                ))
            ],
            mode: .trigger,
            filter: CollisionFilter(
                group: DuelCollisionGroup.placedCard,
                mask: DuelCollisionGroup.rightIndexProbe
            )
        ))
        cardEntity.transform.scale = SIMD3<Float>(
            repeating: DuelDiskMetrics.arenaCardScale
        )
        cardEntity.transform.translation = basePosition
        // タップ時に「アリーナ奥列 col 番目」と Component で確定識別できるようにする
        cardEntity.components.set(PlacedCardLocationComponent(location: .arenaBack(col)))
        arena.addChild(cardEntity)
        arenaCardEntities[col] = cardEntity

        // 上昇アニメ
        var goal = cardEntity.transform
        goal.translation.y = basePosition.y + DuelDiskMetrics.cardRiseHeight
        cardEntity.move(
            to: goal,
            relativeTo: cardEntity.parent,
            duration: DuelDiskMetrics.cardRiseDuration,
            timingFunction: .easeOut
        )

        // 1秒待ち(キャンセル耐性付き)
        do {
            try await Task.sleep(nanoseconds: UInt64(DuelDiskMetrics.monsterSpawnDelay * 1_000_000_000))
        } catch {
            return // キャンセルされた
        }

        // stale チェック: 待っている間に削除/再追加で col の Entity が変わっていたら中止
        guard arenaCardEntities[col] === cardEntity else { return }

        await spawnMonster(into: arena, at: col, above: cardEntity)
    }

    func spawnMonster(into arena: AnchorEntity, at col: Int, above cardEntity: Entity) async {
#if canImport(Sugiy)
        do {
            let monster = try await Entity(named: "sugiy", in: sugiyBundle)
            let bounds = monster.visualBounds(relativeTo: nil)
            let maxExtent = max(bounds.extents.x, max(bounds.extents.y, bounds.extents.z))
            let targetMax: Float = 0.4
            if maxExtent > 0 {
                monster.scale = SIMD3<Float>(repeating: targetMax / maxExtent)
            }
            monster.position = -bounds.center * monster.scale

            let container = Entity()
            container.name = "Monster_col\(col)"
            container.addChild(monster)
            container.transform.translation = cardEntity.transform.translation + SIMD3<Float>(0, 0.15, 0)
            container.transform.scale = .zero
            arena.addChild(container)
            arenaMonsterEntities[col] = container

            var goal = container.transform
            goal.scale = .one
            goal.translation.y += DuelDiskMetrics.cardRiseHeight
            container.move(
                to: goal,
                relativeTo: container.parent,
                duration: DuelDiskMetrics.cardRiseDuration,
                timingFunction: .easeOut
            )
        } catch {
            DuelLog.log("⚠️ Failed to load sugiy entity: \(error)")
            // フォールバック: 赤い球
            let fallback = ModelEntity(
                mesh: .generateSphere(radius: 0.08),
                materials: [SimpleMaterial(color: .red, isMetallic: false)]
            )
            fallback.position = cardEntity.transform.translation + SIMD3<Float>(0, 0.2, 0)
            arena.addChild(fallback)
            arenaMonsterEntities[col] = fallback
        }
#endif
    }

    // NOTE: 削除時の Entity removeFromParent は `syncDiskSlotCardEntities` / `syncArenaBackEntities`
    // の onChange 経由でのみ行う(`onDelete` → Store のみ更新 → onChange で View 同期)。
    // View 層から直接 Entity を消す経路は廃止した(2 重実行の責務分散を解消するため)。
}

// MARK: - Attachment 位置更新

private extension YugiohDuelDiskImmersiveView {
    func updateAttachmentPlacement(_ attachments: RealityViewAttachments) {
        guard let menu = attachments.entity(for: AttachmentID.placedCardMenu) else { return }
        guard let ctx = sessionStore.tappedPlacedCardContext else {
            menu.isEnabled = false
            return
        }
        menu.isEnabled = true
        if let pos = anchorPosition(for: ctx) {
            menu.setPosition(pos + SIMD3<Float>(0, 0.15, 0), relativeTo: nil)
        }
    }

    func anchorPosition(for ctx: PlacedCardContext) -> SIMD3<Float>? {
        switch ctx {
        case .diskSlot(let i):
            if let entity = sessionStore.diskSlots[safe: i].flatMap({ $0.flatMap { placedDiskCardEntities[$0.id] } }) {
                return entity.position(relativeTo: nil)
            }
        case .arenaBack(let c):
            if let entity = arenaCardEntities[c] {
                return entity.position(relativeTo: nil)
            }
        case .arenaFront(let c):
            if let entity = arenaCardEntities[c] {
                return entity.position(relativeTo: nil)
            }
        }
        return nil
    }
}

// MARK: - Cleanup

private extension YugiohDuelDiskImmersiveView {
    /// ImmersiveSpace を抜けたとき: subscription / Task / Entity dict を全部クリーンアップ。
    /// 残しておくと再入場時に dangling / 多重発火する。
    /// 特に `rootEntity` は `@State` で View identity と共に保持され続けるため、
    /// 子(anchor / board / deck / arenaRoot / attachment menu)を **手動で全部 removeFromParent**
    /// する必要がある。これを忘れると再入場時に二重生成する。
    func tearDown() {
        duelAppModel.updateImmersiveSpaceState(.closed)

        // Polling Task
        pinchPollTask?.cancel()
        pinchPollTask = nil

        // 衝突購読
        collisionSubscriptions.forEach { $0.cancel() }
        collisionSubscriptions.removeAll()

        // 召喚 Task
        arenaSummonTasks.values.forEach { $0.cancel() }
        arenaSummonTasks.removeAll()

        // rootEntity 配下のすべての子(anchor / board / deck / arenaRoot / attachment menu 等)を取り外す。
        // Array コピーを取ってから iterate(removeFromParent で children が変動するため)。
        Array(rootEntity.children).forEach { $0.removeFromParent() }

        // Entity 辞書クリア
        fanCardEntities.removeAll()
        placedDiskCardEntities.removeAll()
        arenaCardEntities.removeAll()
        arenaMonsterEntities.removeAll()
        rightHandCardEntity = nil

        // anchor / probe / arenaRoot の参照もクリア
        leftWristAnchor = nil
        boardEntity = nil
        deckEntity = nil
        diskSlotEntities.removeAll()
        leftThumbTipAnchor = nil
        leftIndexTipAnchor = nil
        leftPalmAnchor = nil
        rightThumbTipAnchor = nil
        rightIndexTipAnchor = nil
        rightThumbProbe = nil
        rightIndexProbe = nil
        arenaRoot = nil

        // HandTrackingComponent もクリア(Entity 参照を保持し続けないように)
        leftHandComponent = nil
        rightHandComponent = nil

        // attachment フラグもリセット
        attachmentInstalled = false

        // SpatialTrackingSession を停止
        Task { await spatialTrackingSession.stop() }
    }
}

// MARK: - 補助

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

#Preview(immersionStyle: .mixed) {
    YugiohDuelDiskImmersiveView()
}
#endif
