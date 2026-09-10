//
//  YugiohDuelDiskImmersiveView.swift
//  YugiohDuelDiskPackage
//
//  デュエルディスク体験の本体 ImmersiveView。Phase A3〜C を 1 View で組み立てる。
//
//  構成:
//   - 左手首 AnchorEntity に ディスクボード + デッキ + スロット5枚 を装着
//   - 左手の親指/人差し指 AnchorEntity を使ったピンチ判定で、左手の上に扇手札を表示
//     (扇の位置・姿勢は手のひらの基底に追従する)
//   - 右手の人差し指+中指をくっつけてデッキ空間に交差 → 離した時にドロー
//   - 右手 indexFingerTip プローブ + (扇カード / 配置済カード / ディスクスロット) の衝突
//     → 選択 / 配置 / コンテキストメニュー
//   - 右手カードと左手 palm の衝突 → 扇に取り込み
//   - 床平面 anchor で 5×2 召喚エリア + Taiyaki モンスター召喚
//

#if os(visionOS)
import ARKit
import HandGestureKit
import RealityKit
import SwiftUI
#if canImport(Sugiy)
import Sugiy
#endif
#if canImport(YugiohCardEffect)
import YugiohCardEffect
#endif
#if canImport(SummonEffectAssets)
import SummonEffectAssets
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
    /// 読み込んだ Blender ディスクモデル (Zone/SpellSlot ノードのハイライト切替に使う)
    @State private var diskModelEntity: Entity?
    /// 手首追従の初回適用が済んだか (未適用の間は board を非表示にする)
    @State private var diskPoseInitialized = false
    /// 手首推定が非現実的に飛んだ(=死角トラッキンググリッチ)ときに追従を保留したフレーム数。
    /// 一定フレーム継続したら「本当に動いた/再ローカライズした」とみなして追従を再開する。
    @State private var wristJumpHoldFrames = 0
    /// 実腕オクルージョンの動的切替 (手首を返した時だけ .automatic にして腕の奥に隠す)
    @State private var limbVisibility: Visibility = .hidden
    @State private var diskSlotEntities: [ModelEntity] = []
    /// 魔法・トラップ挿入口(SpellSlot)の視線ハイライト + タップ用オーバーレイ板
    @State private var spellSlotHighlightEntities: [ModelEntity] = []
    @State private var placedDiskCardEntities: [UUID: Entity] = [:]
    /// ディスクの魔法・トラップ挿入口に配置したカード Entity
    @State private var placedSpellCardEntities: [UUID: Entity] = [:]
    @State private var diskSummonEffectEntities: [UUID: Entity] = [:]

    // 左手ピンチ判定用 (anchor は HandTrackingComponent.fingers に格納)
    @State private var leftThumbTipAnchor: AnchorEntity?
    @State private var leftIndexTipAnchor: AnchorEntity?
    @State private var leftMiddleTipAnchor: AnchorEntity?
    // 手のひら基底の算出用。指先はピンチ中に1点へ集まって基底が縮退するため、
    // ピンチの影響を受けないナックル関節を使う。
    @State private var leftIndexKnuckleAnchor: AnchorEntity?
    @State private var leftLittleKnuckleAnchor: AnchorEntity?
    /// 扇カードを親指と並行に向けるための親指付け根
    @State private var leftThumbKnuckleAnchor: AnchorEntity?
    @State private var leftPalmAnchor: AnchorEntity?
    @State private var leftPinchFanRoot: Entity?
    @State private var leftHandComponent: HandTrackingComponent?

    // 右手ピンチ判定用
    @State private var rightThumbTipAnchor: AnchorEntity?
    @State private var rightIndexTipAnchor: AnchorEntity?
    @State private var rightMiddleTipAnchor: AnchorEntity?
    // 右手保持カードの向き算出用ナックル関節
    @State private var rightIndexKnuckleAnchor: AnchorEntity?
    @State private var rightLittleKnuckleAnchor: AnchorEntity?
    @State private var rightDrawProbe: ModelEntity?
    @State private var rightIndexProbe: ModelEntity?
    @State private var rightHandComponent: HandTrackingComponent?

    // 扇手札 Entity (cardId -> ModelEntity)
    @State private var fanCardEntities: [UUID: Entity] = [:]

    // 右手のドロー中カード
    @State private var rightHandCardEntity: Entity?

    // 召喚エリア
    @State private var fieldRoot: AnchorEntity?
    @State private var fieldInteractionRoot: Entity?
    /// 召喚エリア移動/回転用のハンドル(ハンドルエリア container の子)
    @State private var fieldMoveHandle: Entity?
    @State private var fieldRotateHandle: Entity?
    /// ハンドル3つのかたまり(=ハンドルエリア)の container。3つ目のハンドルで丸ごと移動できる。
    @State private var fieldHandleArea: Entity?
    /// ハンドルエリアごと移動する3つ目のハンドル。
    @State private var fieldAreaHandle: Entity?
    /// フィールドのサイズ(スケール)を調整するハンドル。
    @State private var fieldScaleHandle: Entity?
    /// 現在の視線正面へフィールドを再配置するボタン(タップ)。
    @State private var fieldRecenterHandle: Entity?
    /// エリア移動ドラッグ開始時の container ワールド位置。
    @State private var fieldHandleAreaDragStart: SIMD3<Float>?
    /// スケール調整ドラッグ開始時のフィールド一様スケール。
    @State private var fieldScaleDragStart: Float?
    @State private var fieldCardEntities: [Int: Entity] = [:]
    /// フィールド手前列(魔法・トラップ)に配置したカード Entity
    @State private var fieldFrontCardEntities: [Int: Entity] = [:]
    @State private var fieldMonsterEntities: [Int: Entity] = [:]
    /// col ごとの召喚 Task。新しい召喚要求が来たら旧 Task をキャンセルする。
    @State private var fieldSummonTasks: [Int: Task<Void, Never>] = [:]
    /// col ごとの召喚バースト(共通コントローラ SummonBurstController)。
    /// スロット削除/退室時に stop() で片付ける。
    @State private var fieldSummonEffects: [Int: SummonBurstController] = [:]
    /// 移動ハンドルのドラッグ開始時のフィールド位置(ワールド)
    @State private var fieldDragStartPosition: SIMD3<Float>?
    /// 回転ハンドルのドラッグ開始時の状態(フィールド中央を軸に回すために使う)
    @State private var fieldRotateStartAngle: Float?
    @State private var fieldRotateStartOrientation: simd_quatf?
    @State private var fieldRotateStartPosition: SIMD3<Float>?
    @State private var fieldRotateCenterWorld: SIMD3<Float>?
    @State private var fieldRotateHandleStartWorld: SIMD3<Float>?
    @State private var activeDiskSummonEffects: [UUID: DiskSummonEffectState] = [:]

    // 衝突購読 & polling
    @State private var collisionSubscriptions: [EventSubscription] = []
    @State private var pinchPollTask: Task<Void, Never>?
    /// デッキドロー: 右手の人差し指+中指がくっついた状態でデッキ空間へ入ると true。
    /// その後「指を離す」or「デッキ空間から出る」でドロー発火する。
    @State private var isDeckDrawArmed = false
    /// 左手が死角で一時ロストした時に手札を保持する残り猶予フレーム数。
    @State private var leftPinchGraceFrames = 0
    /// 右手の人差し指+中指が「くっついた」立ち上がり検知用(前フレームの接触状態)。
    @State private var wasRightFingersTouching = false
    @State private var isRightHandNearLeftFan = false
    @State private var lastBoardOrientationLogTime: TimeInterval = 0

    // attachment の親付け済みフラグ(update 内での再 addChild 防止)
    @State private var attachmentInstalled: Bool = false
    /// 配置カード操作メニューを視界正面に固定するための頭アンカー
    @State private var menuHeadAnchor: AnchorEntity?
    /// ライフ表示 attachment を LifeDisplay ノードへ設置済みか
    @State private var lifeDisplayInstalled: Bool = false

    public init() {}

    public var body: some View {
        RealityView { content, attachments in
            content.add(rootEntity)
            await requestHandTrackingAuthorization()
            await startSpatialTrackingSession()
            await setupAnchors()
            setupDiskRig()
            setupField()
            installCollisionSubscriptions(content: content)
            installAttachmentIfNeeded(attachments)

            // anchor / Component が揃ってから polling を起動する。
            // `onAppear` で起動すると make の async 待ちを追い抜くため、ここで起動する。
            startPinchPolling()

            // 入室時に新規デュエル開始
            sessionStore.startNewDuel()
            // `onChange(of: hand)` だけに依存せず、入室直後の手札 Entity も明示的に構築する。
            rebuildHandFan(cards: sessionStore.hand)
            DuelLog.event("ImmersiveViewReady", "initialHandCount=\(sessionStore.hand.count)")
            duelAppModel.updateImmersiveSpaceState(.open)
        } update: { _, attachments in
            // 初回 make で attachments を取り損ねていた場合の保険 + 位置更新
            installAttachmentIfNeeded(attachments)
            installLifeDisplayIfNeeded(attachments)
            syncCardAttachments(attachments)
            syncDiskSummonEffectAttachments(attachments)
            updateAttachmentPlacement(attachments)
        } attachments: {
            Attachment(id: AttachmentID.lifeDisplay) {
                LifeDisplayView(life: 8000)
            }
            Attachment(id: AttachmentID.placedCardMenu) {
                if let ctx = sessionStore.tappedPlacedCardContext {
                    CardActionMenuView(
                        context: ctx,
                        canOpen: sessionStore.canOpenCard(at: ctx),
                        onOpen: {
                            // 裏の魔法・トラップを表にする。Entity の向き更新は
                            // `onChange(of: fieldFrontRevealed)` 経由で反映する。
                            sessionStore.openPlacedCard(at: ctx)
                        },
                        onDelete: {
                            // Entity の removeFromParent は `onChange(of: diskSlots / fieldBackRow)` 経由の
                            // `syncDiskSlotCardEntities` / `syncFieldBackEntities` が担当する。
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
            ForEach(sessionStore.hand, id: \.id) { card in
                Attachment(id: AttachmentID.handCard(card.id)) {
#if canImport(YugiohCardEffect)
                    CardView(card: DuelCardVisualFactory.visualModel(for: card))
                        .frame(
                            width: CGFloat(DuelCardVisualFactory.designWidth),
                            height: CGFloat(DuelCardVisualFactory.designHeight)
                        )
#else
                    EmptyView()
#endif
                }
            }
            if let card = sessionStore.rightHandCard {
                Attachment(id: AttachmentID.rightHandCard(card.id)) {
#if canImport(YugiohCardEffect)
                    CardView(card: DuelCardVisualFactory.visualModel(for: card))
                        .frame(
                            width: CGFloat(DuelCardVisualFactory.designWidth),
                            height: CGFloat(DuelCardVisualFactory.designHeight)
                        )
#else
                    EmptyView()
#endif
                }
            }
            ForEach(Array(sessionStore.diskSlots.enumerated()), id: \.offset) { index, card in
                if let card {
                    Attachment(id: AttachmentID.diskCard(slotIndex: index, cardID: card.id)) {
#if canImport(YugiohCardEffect)
                        CardView(card: DuelCardVisualFactory.visualModel(for: card))
                            .frame(
                                width: CGFloat(DuelCardVisualFactory.designWidth),
                                height: CGFloat(DuelCardVisualFactory.designHeight)
                            )
#else
                        EmptyView()
#endif
                    }
                }
            }
            ForEach(Array(sessionStore.fieldBackRow.enumerated()), id: \.offset) { col, card in
                if let card {
                    Attachment(id: AttachmentID.fieldBackCard(column: col, cardID: card.id)) {
#if canImport(YugiohCardEffect)
                        CardView(card: DuelCardVisualFactory.visualModel(for: card))
                            .frame(
                                width: CGFloat(DuelCardVisualFactory.designWidth),
                                height: CGFloat(DuelCardVisualFactory.designHeight)
                            )
#else
                        EmptyView()
#endif
                    }
                }
            }
            ForEach(Array(sessionStore.fieldFrontRow.enumerated()), id: \.offset) { col, card in
                if let card {
                    Attachment(id: AttachmentID.fieldFrontCard(column: col, cardID: card.id)) {
#if canImport(YugiohCardEffect)
                        // 魔法・トラップは基本裏。オープン済みなら表(CardView)、未オープンなら裏(CardBackView)。
                        Group {
                            if sessionStore.fieldFrontRevealed[safe: col] == true {
                                CardView(card: DuelCardVisualFactory.visualModel(for: card))
                            } else {
                                CardBackView()
                            }
                        }
                        .frame(
                            width: CGFloat(DuelCardVisualFactory.designWidth),
                            height: CGFloat(DuelCardVisualFactory.designHeight)
                        )
#else
                        EmptyView()
#endif
                    }
                }
            }
            ForEach(Array(activeDiskSummonEffects.values), id: \.id) { effect in
                Attachment(id: AttachmentID.diskSummonEffect(effect.id)) {
#if canImport(YugiohCardEffect)
                    DiskSummonEffectView(
                        card: DuelCardVisualFactory.visualModel(for: effect.card),
                        animationID: effect.id
                    )
#else
                    EmptyView()
#endif
                }
            }
        }
        // 手首の向きで動的切替: 通常姿勢は .hidden (ディスクを常に完全表示)、
        // 手首を返した時だけ .automatic (腕の奥に隠れて見える)。
        // 既知の制約: 上肢オクルージョンは画面空間セグメンテーションのため、
        // 中間角度の連続的な遮蔽 (実物の腕時計のような見え方) は表現できない。
        .upperLimbVisibility(limbVisibility)
        // 召喚エリアの移動/回転は「右下の丸いハンドル」限定で行う。
        // 指ピンチ(手札表示など)での誤操作を無くすため、フィールド操作はハンドルにのみ紐付ける。
        // タップ(配置/選択)は最優先で拾う。ハンドルのドラッグは simultaneousGesture にして
        // タップを奪わないようにする(ピンチ=タップが召喚配置に確実に効くようにする)。
        .gesture(
            SpatialTapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    handleSpatialTap(on: value.entity)
                }
        )
        .simultaneousGesture(fieldHandleDragGesture)
        .onDisappear {
            tearDown()
        }
        // 手札変化 → 扇 Entity を再構築
        .onChange(of: sessionStore.hand) { _, newValue in
            rebuildHandFan(cards: newValue)
            DuelLog.state("HandUpdated", "count=\(newValue.count)")
        }
        // 選択 → ハイライト(浮かせる) + 配置先スロットのハイライト可否を切替
        .onChange(of: sessionStore.selectedHandCardId) { _, _ in
            applySelectedHighlight()
            updateSlotHighlightAvailability()
            DuelLog.state("HandSelection", "selected=\(sessionStore.selectedHandCardId?.uuidString ?? "nil")")
        }
        // 左手ピンチ状態 → 扇の表示/非表示
        .onChange(of: sessionStore.isLeftPinching) { _, isPinching in
            leftPalmAnchor?.isEnabled = isPinching
            leftPinchFanRoot?.isEnabled = isPinching
            // 手札表示中は指がカードを隠さないよう即座に実腕オクルージョンを切る。
            // (pose ループの updateLimbVisibility は早期 return で呼ばれないことがあるため、ここでも設定)
            if isPinching, limbVisibility != .hidden {
                limbVisibility = .hidden
                DuelLog.event("LimbVisibilityChanged", "visibility=hidden reason=leftFanShownOnChange")
            }
            DuelLog.state("LeftPinch", "isPinching=\(isPinching)")
        }
        .onChange(of: sessionStore.isRightPinching) { _, isPinching in
            DuelLog.state("RightPinch", "isPinching=\(isPinching)")
        }
        // 右手カード → Entity 同期
        .onChange(of: sessionStore.rightHandCard) { _, card in
            syncRightHandCardEntity(card: card)
            DuelLog.state("RightHandCard", "cardId=\(card?.id.uuidString ?? "nil")")
        }
        // ディスク召喚スロット → 配置カード Entity 同期(Store はここで fieldBackRow を同時更新済み)
        .onChange(of: sessionStore.diskSlots) { _, newSlots in
            syncDiskSlotCardEntities(newSlots: newSlots)
            DuelLog.state("DiskSlots", summarizeSlots(newSlots))
        }
        // ディスク魔法・トラップ挿入口 → 配置カード Entity 同期(Store は fieldFrontRow も更新済み)
        .onChange(of: sessionStore.spellSlots) { _, newSlots in
            syncSpellSlotCardEntities(newSlots: newSlots)
            DuelLog.state("SpellSlots", summarizeSlots(newSlots))
        }
        // フィールド奥列 → カード + モンスター Entity 同期
        .onChange(of: sessionStore.fieldBackRow) { _, newSlots in
            syncFieldBackEntities(newSlots: newSlots)
            DuelLog.state("FieldBackSlots", summarizeSlots(newSlots))
        }
        // フィールド手前列(魔法・トラップ) → カード Entity 同期
        .onChange(of: sessionStore.fieldFrontRow) { _, newSlots in
            syncFieldFrontEntities(newSlots: newSlots)
            DuelLog.state("FieldFrontSlots", summarizeSlots(newSlots))
        }
        .onChange(of: sessionStore.tappedPlacedCardContext) { _, ctx in
            DuelLog.state("PlacedCardMenu", "context=\(String(describing: ctx))")
        }
    }
}

// MARK: - 定数

private enum AttachmentID {
    static let placedCardMenu = "duelDiskPlacedCardMenu"
    static let lifeDisplay = "duelDiskLifeDisplay"
    static func handCard(_ id: UUID) -> String { "duelDiskHandCard-\(id.uuidString)" }
    static func rightHandCard(_ id: UUID) -> String { "duelDiskRightHandCard-\(id.uuidString)" }
    static func diskCard(slotIndex: Int, cardID: UUID) -> String {
        "duelDiskSlotCard-\(slotIndex)-\(cardID.uuidString)"
    }
    static func spellCard(slotIndex: Int, cardID: UUID) -> String {
        "duelDiskSpellCard-\(slotIndex)-\(cardID.uuidString)"
    }
    static func fieldBackCard(column: Int, cardID: UUID) -> String {
        "duelFieldBackCard-\(column)-\(cardID.uuidString)"
    }
    static func fieldFrontCard(column: Int, cardID: UUID) -> String {
        "duelFieldFrontCard-\(column)-\(cardID.uuidString)"
    }
    static func diskSummonEffect(_ id: UUID) -> String { "duelDiskSummonEffect-\(id.uuidString)" }
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

private let fieldInteractionWidth: Float =
    Float(DuelDiskMetrics.diskSlotCount) * DuelDiskMetrics.fieldSlotWidth
    + Float(DuelDiskMetrics.diskSlotCount - 1) * DuelDiskMetrics.fieldGapX
private let fieldInteractionDepth: Float =
    abs(DuelDiskMetrics.fieldFrontZ - DuelDiskMetrics.fieldBackZ) + DuelDiskMetrics.fieldSlotDepth
/// フィールド(3xスケール適用後)の奥行き半分。ワールド座標での実寸。
private let fieldHalfDepthWorld: Float = fieldInteractionDepth / 2 * DuelDiskMetrics.fieldScale
private let fieldHalfWidthWorld: Float = fieldInteractionWidth / 2 * DuelDiskMetrics.fieldScale
private let fieldLocalCenterOffsetZ = (DuelDiskMetrics.fieldBackZ + DuelDiskMetrics.fieldFrontZ) / 2
/// 「手前の召喚列(見えているスロットの手前列)」をプレイヤーの何m前方に置くか。
/// 見えないインタラクション板の端ではなく、実際に見える手前列を基準にする。
private let fieldFrontRowWorldZ: Float = -3.0
/// フィールド中心から手前列までのワールド距離(3xスケール適用後)。
/// (fieldFrontZ は中心オフセット基準なので、そこから中心オフセットを引いてスケール倍する)
private let fieldFrontRowLocalOffsetWorld: Float =
    (DuelDiskMetrics.fieldFrontZ - fieldLocalCenterOffsetZ) * DuelDiskMetrics.fieldScale
/// 手前列が fieldFrontRowWorldZ に来るよう、フィールド中心の Z を決める。
private let fieldWorldCenterPosition =
    SIMD3<Float>(0, -1.0, fieldFrontRowWorldZ - fieldFrontRowLocalOffsetWorld)

private func fieldInteractionMaterial() -> SimpleMaterial {
    var material = SimpleMaterial()
#if canImport(UIKit)
    material.color = .init(tint: UIColor.white.withAlphaComponent(0.06))
#endif
    material.metallic = 0
    material.roughness = 1
    return material
}

private struct DiskSummonEffectState: Identifiable {
    let id: UUID
    let slotIndex: Int
    let card: DuelCard
}

#if canImport(UIKit) && canImport(YugiohCardEffect)
/// カード裏面テクスチャの一度きり生成キャッシュ(全カード共通デザインのため使い回す)。
@MainActor
private enum CardBackTextureCache {
    static var didAttempt = false
    static var texture: TextureResource?
}

@MainActor
private enum HandleFaceTextureCache {
    static var textures: [FieldHandleComponent.Kind: TextureResource] = [:]
}
#endif

private enum CardAttachmentSurface {
    case fan
    case handheld
    case horizontal
}

// MARK: - ログ

private enum DuelLog {
    static let prefix = "[YugiohDuelDisk]"

    static func log(_ message: @autoclosure () -> String) {
        print("\(prefix) \(message())")
    }

    static func event(_ name: String, _ details: @autoclosure () -> String = "") {
        let suffix = details()
        log(suffix.isEmpty ? "EVENT \(name)" : "EVENT \(name) \(suffix)")
    }

    static func state(_ name: String, _ details: @autoclosure () -> String = "") {
        let suffix = details()
        log(suffix.isEmpty ? "STATE \(name)" : "STATE \(name) \(suffix)")
    }

    static func warning(_ message: @autoclosure () -> String) {
        log("WARN \(message())")
    }

    // MARK: - 召喚スロットのデバッグログ (issue 1 & 2)
    // 1(召喚線)と 2(空きスロットの視線ホバー→クリック配置)は「召喚スロットの一連の流れ」で
    // 共通するため、共通 prefix `SLOTFLOW` を付ける。さらに各issue固有の tag を足す:
    //   - 召喚線:   `SLOTFLOW/LINE`
    //   - 配置操作: `SLOTFLOW/PLACE`
    // grep 例: `SLOTFLOW`(1&2両方) / `SLOTFLOW/LINE`(線だけ) / `SLOTFLOW/PLACE`(配置だけ)。
    static let flowPrefix = "SLOTFLOW"

    /// 召喚線(issue 1)専用ログ。
    static func line(_ step: String, _ details: @autoclosure () -> String = "") {
        let suffix = details()
        log(suffix.isEmpty ? "\(flowPrefix)/LINE \(step)" : "\(flowPrefix)/LINE \(step) \(suffix)")
    }

    /// 空きスロットのホバー→クリック配置(issue 2)専用ログ。
    static func place(_ step: String, _ details: @autoclosure () -> String = "") {
        let suffix = details()
        log(suffix.isEmpty ? "\(flowPrefix)/PLACE \(step)" : "\(flowPrefix)/PLACE \(step) \(suffix)")
    }
}

// MARK: - 初期化処理

private extension YugiohDuelDiskImmersiveView {
    func requestHandTrackingAuthorization() async {
        let session = ARKitSession()
        let result = await session.requestAuthorization(for: [.handTracking])
        DuelLog.state("HandTrackingAuthorization", "result=\(String(describing: result[.handTracking]))")
        if result[.handTracking] != .allowed {
            DuelLog.warning("Hand tracking authorization not allowed: \(String(describing: result[.handTracking]))")
        }
    }

    func startSpatialTrackingSession() async {
        let config = SpatialTrackingSession.Configuration(tracking: [.hand, .world])
        let unavailable = await spatialTrackingSession.run(config)
        DuelLog.state(
            "SpatialTrackingSession",
            unavailable == nil ? "started tracking=[.hand,.world]" : "unavailable=\(unavailable!)"
        )
        if let unavailable {
            DuelLog.warning("SpatialTrackingSession unavailable capabilities: \(unavailable)")
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

        let lMiddle = AnchorEntity(
            .hand(.left, location: .joint(for: .middleFingerTip)),
            trackingMode: .predicted
        )
        lMiddle.name = "LeftMiddleTipAnchor"
        rootEntity.addChild(lMiddle)
        leftMiddleTipAnchor = lMiddle

        // 左手ナックル×2 — 手のひら基底(指方向 × 手のひら幅方向)の算出用。
        let lIndexKnuckle = AnchorEntity(
            .hand(.left, location: .joint(for: .indexFingerKnuckle)),
            trackingMode: .predicted
        )
        lIndexKnuckle.name = "LeftIndexKnuckleAnchor"
        rootEntity.addChild(lIndexKnuckle)
        leftIndexKnuckleAnchor = lIndexKnuckle

        let lLittleKnuckle = AnchorEntity(
            .hand(.left, location: .joint(for: .littleFingerKnuckle)),
            trackingMode: .predicted
        )
        lLittleKnuckle.name = "LeftLittleKnuckleAnchor"
        rootEntity.addChild(lLittleKnuckle)
        leftLittleKnuckleAnchor = lLittleKnuckle

        // 左親指付け根 — 扇カードを親指と並行に向けるための基準
        let lThumbKnuckle = AnchorEntity(
            .hand(.left, location: .joint(for: .thumbKnuckle)),
            trackingMode: .predicted
        )
        lThumbKnuckle.name = "LeftThumbKnuckleAnchor"
        rootEntity.addChild(lThumbKnuckle)
        leftThumbKnuckleAnchor = lThumbKnuckle

        // 左 palm — 互換用。実際の表示位置は pinch 中点 root で管理する。
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

        let leftFanRoot = Entity()
        leftFanRoot.name = "LeftPinchFanRoot"
        leftFanRoot.isEnabled = false
        rootEntity.addChild(leftFanRoot)
        leftPinchFanRoot = leftFanRoot

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

        let rMiddle = AnchorEntity(
            .hand(.right, location: .joint(for: .middleFingerTip)),
            trackingMode: .predicted
        )
        rMiddle.name = "RightMiddleTipAnchor"
        rootEntity.addChild(rMiddle)
        rightMiddleTipAnchor = rMiddle

        // 右手ナックル×2 — 保持カードを指の向き・指の腹側に合わせるための基底用
        let rIndexKnuckle = AnchorEntity(
            .hand(.right, location: .joint(for: .indexFingerKnuckle)),
            trackingMode: .predicted
        )
        rIndexKnuckle.name = "RightIndexKnuckleAnchor"
        rootEntity.addChild(rIndexKnuckle)
        rightIndexKnuckleAnchor = rIndexKnuckle

        let rLittleKnuckle = AnchorEntity(
            .hand(.right, location: .joint(for: .littleFingerKnuckle)),
            trackingMode: .predicted
        )
        rLittleKnuckle.name = "RightLittleKnuckleAnchor"
        rootEntity.addChild(rLittleKnuckle)
        rightLittleKnuckleAnchor = rLittleKnuckle
        DuelLog.event("AnchorsSetupCompleted", "left=[wrist,thumbTip,indexTip,middleTip,palm] right=[thumbTip,indexTip,middleTip]")

        // 右手ピンチ中点プローブ — deck draw 用。親指tip単体ではなくピンチ中点で判定する。
        let drawProbe = ModelEntity()
        drawProbe.name = "RightDrawProbe"
        drawProbe.components.set(RightThumbProbeComponent())
        drawProbe.components.set(CollisionComponent(
            shapes: [.generateSphere(radius: DuelDiskMetrics.drawProbeRadius)],
            mode: .trigger,
            filter: CollisionFilter(
                group: DuelCollisionGroup.rightThumbProbe,
                mask: [DuelCollisionGroup.deck]
            )
        ))
        rootEntity.addChild(drawProbe)
        rightDrawProbe = drawProbe

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
        lhc.fingers[.middleFingerTip] = lMiddle
        leftHandComponent = lhc

        var rhc = HandTrackingComponent(chirality: .right)
        rhc.fingers[.thumbTip] = rThumb
        rhc.fingers[.indexFingerTip] = rIndex
        rhc.fingers[.middleFingerTip] = rMiddle
        rightHandComponent = rhc

        // 配置カード操作メニュー用の頭アンカー(視界正面にメニューを固定表示する)
        let headAnchor = AnchorEntity(.head)
        headAnchor.name = "MenuHeadAnchor"
        headAnchor.anchoring.trackingMode = .continuous
        rootEntity.addChild(headAnchor)
        menuHeadAnchor = headAnchor
    }

    func setupDiskRig() {
        guard let wrist = leftWristAnchor else { return }
        // Board: Blender 製 USDZ を載せるコンテナ。
        // モデル原点 = WristAnchor ノード = 円盤裏面の中央 = 手首固定点。
        // AnchorEntity 直付けだと手首のトラッキングロスト時に姿勢が暴れるため、
        // root 配下に置き、ポーリングループで isAnchored のときだけスムーズに追従させる。
        let board = ModelEntity()
        board.name = "DuelDiskBoard"
        board.isEnabled = false // 初回の手首姿勢が取れるまで非表示
        rootEntity.addChild(board)
        boardEntity = board
        _ = wrist // 追従は updateDiskPoseFollowingWrist() が行う
        DuelLog.event("BoardAttached", "translation=\(board.transform.translation)")
        logBoardOrientation(force: true)

        // Deck
        let deck = DeckEntityFactory.make()
        deck.position = SIMD3<Float>(
            0,
            DuelDiskMetrics.boardThickness / 2 + DuelDiskMetrics.deckHeight / 2,
            DuelDiskMetrics.boardDepth / 4
        )
        deck.transform.rotation = simd_quatf(angle: .pi / 2, axis: SIMD3<Float>(0, 1, 0))
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
        installDeckBackFace(on: deck)
        DuelLog.event("DeckAttached", "position=\(deck.position)")

        // ディスクスロット ×5
        // 当たり判定は「1スロット分」に収める。スロットはヨー(±12°)が付くため、実寸のままだと
        // 回転で幅が広がり隣とピッチ(0.063m)を超えて重なる → 複数同時ホバー/誤タップになる。
        // 回転しても隣と重ならないよう、幅・奥行きを控えめ(diskSlotTapWidth/Depth)にする。
        let slots = DiskSlotFactory.makeSlots()
        for slot in slots {
            slot.components.set(CollisionComponent(
                shapes: [
                    .generateBox(size: SIMD3<Float>(
                        DuelDiskMetrics.diskSlotTapWidth,
                        DuelDiskMetrics.diskSlotTapHeight,
                        DuelDiskMetrics.diskSlotTapDepth
                    ))
                ],
                mode: .default,
                filter: .default
            ))
            board.addChild(slot)
            if let index = slot.components[DiskSlotIndexComponent.self]?.index {
                DuelLog.event("DiskSlotInteractiveReady", "slot=\(index) position=\(shortVector(slot.position))")
            }
        }
        diskSlotEntities = slots
        DuelLog.event("DiskSlotsAttached", "count=\(slots.count)")

        // Blender 製ディスクモデルを非同期で読み込み、装着 + ノード位置へ配置換え
        Task { @MainActor in
            do {
                let model = try await DuelDiskModelFactory.load()
                // 読み込み中に ImmersiveView が破棄/再入場された場合は何もしない
                // (再入場時は新しい board が boardEntity に入るため、同一性で比較する)
                guard boardEntity === board else { return }
                DuelDiskModelFactory.configureTapTargets(on: model)
                board.addChild(model)
                diskModelEntity = model
                repositionRigToModelNodes(model: model)
                installSpellSlotHighlightOverlays(model: model, board: board)
                verifyModelNodeContract(model: model)
                // 選択中カードの種類に応じたハイライト可否を初期反映する
                updateSlotHighlightAvailability()
                DuelLog.event("DuelDiskModelLoaded", "name=\(model.name)")
            } catch {
                DuelLog.event("DuelDiskModelLoadFailed", "error=\(error)")
            }
        }
    }

    /// 手首アンカーの姿勢へディスクをスムーズに追従させる (ポーリングループから毎tick呼ぶ)。
    /// トラッキングロスト中 (isAnchored=false / 原点近傍) は最後の姿勢を保持する。
    func updateDiskPoseFollowingWrist() {
        guard let board = boardEntity, let wrist = leftWristAnchor, wrist.isAnchored else { return }
        let wristTransform = Transform(matrix: wrist.transformMatrix(relativeTo: nil))
        // 未トラッキング時に原点 (単位行列) が返るケースを弾く
        guard simd_length(wristTransform.translation) > 0.05 else { return }

        // 右手をディスクへ伸ばしている間は追従を凍結する。
        // (このとき左手首が死角に入り姿勢推定が乱れ、ディスクが急に動く主因になるため)
        // 初回姿勢確定前は凍結しない(初期化を優先)。
        if diskPoseInitialized, isRightHandNearDisk(boardWorld: board.position(relativeTo: nil)) {
            return
        }
        let targetRotation = wristTransform.rotation * DuelDiskBoardLayout.rotation
        // 手首表面から surfaceLift だけディスク上方向 (board ローカル +Y) に浮かせる
        let targetPosition = wristTransform.translation
            + wristTransform.rotation.act(DuelDiskBoardLayout.translation)
            + targetRotation.act(SIMD3<Float>(0, DuelDiskBoardLayout.surfaceLift, 0))
        if !diskPoseInitialized {
            board.position = targetPosition
            board.orientation = targetRotation
            board.isEnabled = true
            diskPoseInitialized = true
            wristJumpHoldFrames = 0
            DuelLog.event("DiskPoseInitialized", "position=\(shortVector(targetPosition))")
            return
        }

        // --- 外れ値(死角トラッキンググリッチ)の棄却 ---
        // 右手をディスクへ伸ばすと左手首が死角に入り、手首推定が瞬間的に飛ぶことがある。
        // 1tickの移動/回転が非現実的に大きい場合は追従を保留し、最後の姿勢を維持する。
        // ただし、その大ジャンプが一定フレーム継続したら「本当に動いた/再ローカライズした」と判断して追従を再開する
        // (恒久的なズレを防ぐため)。
        let positionJump = simd_distance(board.position, targetPosition)
        // 2つの姿勢間の最短回転角 (rad)
        let relativeRotation = board.orientation.inverse * targetRotation
        let rawAngle = relativeRotation.angle
        let angleJump = rawAngle > .pi ? (2 * .pi - rawAngle) : rawAngle
        let isGlitchJump = positionJump > DuelDiskMetrics.wristFollowMaxJumpPerTick
            || angleJump > DuelDiskMetrics.wristFollowMaxAnglePerTick
        if isGlitchJump {
            wristJumpHoldFrames += 1
            if wristJumpHoldFrames < DuelDiskMetrics.wristFollowJumpConfirmFrames {
                // グリッチとみなして最後の姿勢を保持(=ディスクを動かさない)
                if wristJumpHoldFrames == 1 {
                    DuelLog.event(
                        "DiskPoseJumpRejected",
                        "posJump=\(String(format: "%.3f", positionJump)) angJump=\(String(format: "%.2f", angleJump))"
                    )
                }
                return
            }
            // 継続したので実際の移動と判断 → このフレームで追従を再開
            DuelLog.event("DiskPoseJumpAccepted", "posJump=\(String(format: "%.3f", positionJump))")
        }
        wristJumpHoldFrames = 0

        // ローパスで滑らかに追従 (60fps 想定で α=0.35)
        let alpha: Float = 0.35
        board.position = mix(board.position, targetPosition, t: alpha)
        board.orientation = simd_slerp(board.orientation, targetRotation, alpha)
        updateLimbVisibility(diskUp: targetRotation.act(SIMD3<Float>(0, 1, 0)))
    }

    /// 手首の向きに応じて実腕オクルージョンを切り替える。
    /// ディスク上面がワールド下向きになった (=手首を返した) ときだけ .automatic にする。
    /// ヒステリシス帯 (-0.2 ... 0.05) で境界のチラつきを抑える。
    func updateLimbVisibility(diskUp: SIMD3<Float>) {
        // 左手の手札(扇)を表示中は、指がカードを隠さないよう常に実腕オクルージョンを切る(.hidden)。
        // (手札を見るために手首を返すと disk が下向き=通常なら .automatic になり、指がカードを隠すため)
        if sessionStore.isLeftPinching {
            if limbVisibility != .hidden {
                limbVisibility = .hidden
                DuelLog.event("LimbVisibilityChanged", "visibility=hidden reason=leftFanShown")
            }
            return
        }
        let upDot = simd_dot(diskUp, SIMD3<Float>(0, 1, 0))
        let newValue: Visibility?
        if upDot < -0.2 {
            newValue = .automatic
        } else if upDot > 0.05 {
            newValue = .hidden
        } else {
            newValue = nil // ヒステリシス帯: 現状維持
        }
        if let newValue, newValue != limbVisibility {
            limbVisibility = newValue
            DuelLog.event(
                "LimbVisibilityChanged",
                "visibility=\(newValue == .automatic ? "automatic" : "hidden") upDot=\(String(format: "%.2f", upDot))"
            )
        }
    }

    /// Blender 側ノード契約の実行時検証。ノード有無・board座標・判定コンポーネントをログ出力する。
    func verifyModelNodeContract(model: Entity) {
        guard let board = boardEntity else { return }
        var names = ["WristAnchor", DuelDiskModelFactory.deckSlotName,
                     DuelDiskModelFactory.graveyardSlotName, DuelDiskModelFactory.lifeDisplayName]
        names += (1...5).map { "CardSlot_\($0)" }
        names += DuelDiskModelFactory.buttonNames
        names += DuelDiskModelFactory.spellSlotNames
        names += DuelDiskModelFactory.zoneFieldNames
        for name in names {
            guard let node = model.findEntity(named: name) else {
                DuelLog.warning("ModelNodeCheck MISSING name=\(name)")
                continue
            }
            let position = node.convert(position: .zero, to: board)
            let hasCollision = node.components[CollisionComponent.self] != nil
            let hasInput = node.components[InputTargetComponent.self] != nil
            DuelLog.event(
                "ModelNodeCheck",
                "name=\(name) boardPos=\(shortVector(position)) collision=\(hasCollision) input=\(hasInput)"
            )
        }
    }

    /// デッキとディスクスロットを USDZ 内のノード位置に合わせる。
    func repositionRigToModelNodes(model: Entity) {
        guard let board = boardEntity else { return }
        // デッキ: DeckSlot = 押さえホルダー底面の中央。デッキ上面をこの点に合わせる。
        if let deckNode = model.findEntity(named: DuelDiskModelFactory.deckSlotName),
           let deck = deckEntity {
            var position = deckNode.convert(position: .zero, to: board)
            position.y -= DuelDiskMetrics.deckHeight / 2
            deck.position = position
            DuelLog.event("DeckRepositioned", "position=\(shortVector(position))")
        }
        // 召喚スロット: CardSlot_1...5 (ブレード上のゾーン中心) に追従
        for slot in diskSlotEntities {
            guard let index = slot.components[DiskSlotIndexComponent.self]?.index,
                  let node = model.findEntity(named: "CardSlot_\(index + 1)") else { continue }
            // ゾーン面より確実に手前(上)に出して、視線ホバー/タップがスロット板に当たるようにする
            slot.position = node.convert(position: .zero, to: board) + SIMD3<Float>(0, 0.003, 0)
            // ノードの orientation には USDZ ルートの Z-up→Y-up 変換 (X軸 -90°) が乗っており、
            // そのまま使うとスロット面・配置カードが盤面に垂直に立ってしまう。
            // 翼の後退角 (±12°) はヨー成分として保存されるので、ヨーだけ取り出して適用する。
            slot.orientation = yawOnlyOrientation(of: node, relativeTo: board)
            DuelLog.event("DiskSlotRepositioned", "slot=\(index) position=\(shortVector(slot.position)) orientation=\(slot.orientation)")
        }
    }

    /// ノードの向きから、reference の +Y 軸まわりのヨー回転だけを取り出す。
    /// ノードのローカル +X 軸が reference の XZ 平面上でどちらを向いているかで算出する。
    func yawOnlyOrientation(of node: Entity, relativeTo reference: Entity) -> simd_quatf {
        let mappedX = node.convert(direction: SIMD3<Float>(1, 0, 0), to: reference)
        let projected = SIMD3<Float>(mappedX.x, 0, mappedX.z)
        guard simd_length(projected) > 0.0001 else { return simd_quatf(angle: 0, axis: SIMD3<Float>(0, 1, 0)) }
        let normalized = simd_normalize(projected)
        // R_y(θ) は (1,0,0) を (cosθ, 0, -sinθ) へ写すので θ = atan2(-z, x)
        let yaw = atan2(-normalized.z, normalized.x)
        return simd_quatf(angle: yaw, axis: SIMD3<Float>(0, 1, 0))
    }

    /// SpellSlot ノード位置に、タップ + カード接触判定用のオーバーレイ板を敷く。
    /// 実際のアニメには無い「赤い半透明ガイド」は出さない方針のため、板は透明にする
    /// (見た目は出さず、タップ/接触の判定だけを担う)。
    func installSpellSlotHighlightOverlays(model: Entity, board: Entity) {
        spellSlotHighlightEntities.forEach { $0.removeFromParent() }
        spellSlotHighlightEntities.removeAll()
        for i in 0..<DuelDiskMetrics.diskSlotCount {
            guard let node = model.findEntity(named: "SpellSlot_\(i + 1)") else { continue }
            let plane = ModelEntity(
                mesh: .generatePlane(width: DuelDiskMetrics.diskSlotWidth, depth: DuelDiskMetrics.diskSlotDepth),
                materials: [invisibleSlotMaterial()]
            )
            plane.name = "SpellSlotHighlight_\(i)"
            plane.transform.translation = node.convert(position: .zero, to: board) + SIMD3<Float>(0, 0.002, 0)
            plane.transform.rotation = yawOnlyOrientation(of: node, relativeTo: board)
            plane.components.set(SpellSlotIndexComponent(index: i))
            plane.components.set(InputTargetComponent())
            plane.components.set(CollisionComponent(
                shapes: [.generateBox(size: SIMD3<Float>(DuelDiskMetrics.diskSlotWidth, 0.005, DuelDiskMetrics.diskSlotDepth))],
                mode: .default,
                filter: .default
            ))
            board.addChild(plane)
            spellSlotHighlightEntities.append(plane)
        }
    }

    /// 選択中カードの種類に応じて、配置先スロットのハイライト可否を切り替える。
    /// - モンスター選択中: ディスク召喚スロット + 召喚ゾーン面のみハイライト。
    /// - 魔法/トラップ選択中: 魔法・トラップ挿入口のみハイライト。
    /// - 未選択: どちらもハイライトしない。
    /// ハイライト中はスロット板を発光色(Unlit)にして視線を向けなくても目立たせ、視線ホバーも強くする。
    func updateSlotHighlightAvailability() {
        let kind = sessionStore.selectedCardKind
        let monsterActive = (kind == .monster)
        let spellActive = (kind == .spell || kind == .trap)

        // ディスク召喚スロット plane (モンスター用)。
        // 視線ホバーは「常時ON」にする(空きスロットに目線を合わせたら必ず光る)。
        // モンスター選択中はさらに cyan を強めて「今ここに置ける」ことを強調する。配置可否は Store 側で判定。
        for slot in diskSlotEntities {
            slot.model?.materials = [slotHighlightMaterial(active: monsterActive, kind: .monster)]
            slot.components.set(DuelHoverStyle.summonSlot)
        }
        // 魔法・トラップ挿入口: 赤い半透明ガイドは出さない(実アニメに無いため)。
        // 板は常に透明のまま、タップ/カード接触の判定だけを担う。ホバーも付けない。
        _ = spellActive
        // 召喚ゾーン面 (Zone_i_Field) は「見えない板」なのでホバーを付けない。
        // (見えないノードにホバーが当たると、手前のスロット板ハイライトが視線に取られて見えなくなる)
        DuelLog.state(
            "SlotHighlightAvailability",
            "kind=\(kind.map { String(describing: $0) } ?? "nil") monster=\(monsterActive) spell=\(spellActive)"
        )
    }

    /// スロットのハイライト板マテリアル。
    /// active 時は Unlit の鮮やかな半透明色で「今ここに置ける」ことを強く示す。
    func slotHighlightMaterial(active: Bool, kind: DuelCard.Kind) -> RealityKit.Material {
#if canImport(UIKit)
        let base: UIColor = (kind == .monster) ? .cyan : .systemPink
        if active {
            var m = UnlitMaterial()
            m.color = .init(tint: base.withAlphaComponent(0.8))
            m.blending = .transparent(opacity: 0.8)
            return m
        } else {
            // 未選択でも「置き場」が分かり、視線ホバーが見えるよう、ある程度の可視度を残す。
            var m = UnlitMaterial()
            m.color = .init(tint: base.withAlphaComponent(0.35))
            m.blending = .transparent(opacity: 0.35)
            return m
        }
#else
        return SimpleMaterial()
#endif
    }

    /// 完全透明なマテリアル。見た目を出さずにタップ/接触判定だけを担う板に使う。
    func invisibleSlotMaterial() -> RealityKit.Material {
        var m = UnlitMaterial()
        m.blending = .transparent(opacity: 0.0)
#if canImport(UIKit)
        m.color = .init(tint: UIColor.white.withAlphaComponent(0.0))
#endif
        return m
    }

    /// ホバーハイライトの有効/無効を切り替える。無効時は HoverEffectComponent を外す。
    /// (InputTargetComponent は残すのでタップ自体は通り、種類不一致は Store 側で no-op になる)
    func setHoverEnabled(_ entity: Entity, enabled: Bool, style: @autoclosure () -> HoverEffectComponent) {
        if enabled {
            entity.components.set(style())
        } else {
            entity.components.remove(HoverEffectComponent.self)
        }
    }

    func setupField() {
        var fieldTransform = matrix_identity_float4x4
        // スロット群は root から平均 -1.4m 前方に配置されているため、
        // ワールドアンカーは +0.6m 手前に置いて、フィールド中心が -2.0m に来るようにする。
        fieldTransform.columns.3 = SIMD4<Float>(
            fieldWorldCenterPosition.x,
            fieldWorldCenterPosition.y,
            fieldWorldCenterPosition.z - fieldLocalCenterOffsetZ,
            1
        )
        let field = AnchorEntity(.world(transform: fieldTransform))
        field.name = "FieldRoot"
        rootEntity.addChild(field)
        fieldRoot = field

        let interactionRoot = Entity()
        interactionRoot.name = "FieldInteractionRoot"
        interactionRoot.position = SIMD3<Float>(0, 0, fieldLocalCenterOffsetZ)
        // フィールド全体(スロット/カード/モンスター)をまとめて拡大する。
        // フィールド中心 (world -2m) を基準に一様スケールするため、子の位置・大きさが揃って拡大される。
        interactionRoot.scale = SIMD3<Float>(repeating: DuelDiskMetrics.fieldScale)
        interactionRoot.components.set(FieldInteractionComponent())
        interactionRoot.components.set(InputTargetComponent())
        interactionRoot.components.set(HoverEffectComponent())
        interactionRoot.components.set(CollisionComponent(
            shapes: [.generateBox(size: SIMD3<Float>(
                fieldInteractionWidth,
                0.02,
                fieldInteractionDepth
            ))],
            mode: .default,
            filter: .default
        ))
        let interactionPlate = ModelEntity(
            mesh: .generatePlane(width: fieldInteractionWidth, depth: fieldInteractionDepth),
            materials: [fieldInteractionMaterial()]
        )
        interactionPlate.name = "FieldInteractionPlate"
        interactionPlate.position = SIMD3<Float>(0, DuelDiskMetrics.fieldSurfaceHeight - 0.003, 0)
        interactionPlate.components.set(InputTargetComponent())
        interactionPlate.components.set(HoverEffectComponent())
        interactionPlate.components.set(CollisionComponent(
            shapes: [.generateBox(size: SIMD3<Float>(
                fieldInteractionWidth,
                0.01,
                fieldInteractionDepth
            ))],
            mode: .default,
            filter: .default
        ))
        interactionRoot.addChild(interactionPlate)
        field.addChild(interactionRoot)
        fieldInteractionRoot = interactionRoot
        DuelLog.event(
            "FieldInteractionReady",
            "anchorWorld=\(shortVector(field.position(relativeTo: nil))) rootPosition=\(shortVector(interactionRoot.position)) platePosition=\(shortVector(interactionPlate.position)) size=\(shortVector(SIMD3<Float>(fieldInteractionWidth, 0.01, fieldInteractionDepth)))"
        )

        let slots = FieldSlotFactory.makeField()
        interactionRoot.addChild(slots)
        DuelLog.event("FieldSetupCompleted", "slotCount=10")

        // 召喚エリアの「移動」「回転」ハンドル(丸い球)を、フィールドの手前に設置する。
        // rootEntity 直下(回転しないワールド系)に置き、位置だけをフィールド中央に追従させる。
        // → 置き場と重ならない(手前)/ドラッグ計算が安定する/フィールド移動に追従する。
        setupFieldHandles()
    }

    /// 5種類のハンドル(移動/回転/サイズ/エリア移動/再配置)を生成し、手元に横1列で並べる。
    /// それぞれアイコン+ラベルを正面に貼って区別しやすくする。
    func setupFieldHandles() {
        let area = Entity()
        area.name = "FieldHandleArea"
        area.position = DuelDiskMetrics.fieldHandleAreaWorldPosition
        rootEntity.addChild(area)
        fieldHandleArea = area

        // 左端に「まとめて移動(=このハンドル群ごと動かす)」を独立配置し、区切り(セパレータ)を挟んで
        // その右にフィールド操作ハンドル群(移動/回転/サイズ/正面へ)を並べる。
        // 「まとめて」だけ操作対象が違う(ハンドル自身 vs フィールド)ので視覚的に分ける。
        let S = DuelDiskMetrics.fieldHandleSpacing
        let G = DuelDiskMetrics.fieldHandleSeparatorGap
        let group: [(kind: FieldHandleComponent.Kind, color: UIColor, name: String)] = [
            (.move, .systemCyan, "FieldMoveHandle"),
            (.rotate, .systemOrange, "FieldRotateHandle"),
            (.scale, .systemPurple, "FieldScaleHandle"),
            (.recenter, .systemYellow, "FieldRecenterHandle"),
        ]
        // X 座標(未センタリング): area=0、群は S+G から S 間隔。全体を中央寄せする。
        let areaX: Float = 0
        let groupStartX = S + G
        let lastX = groupStartX + S * Float(group.count - 1)
        let center = (areaX + lastX) / 2
        func x(_ raw: Float) -> Float { raw - center }

        // まとめて(左端・緑)
        let areaHandle = makeFieldHandle(kind: .area, color: .systemGreen, name: "FieldAreaHandle")
        areaHandle.position = SIMD3<Float>(x(areaX), 0, 0)
        area.addChild(areaHandle)
        fieldAreaHandle = areaHandle

        // 区切り(縦のセパレータ)= まとめて と 群 の中間。
        let separator = makeHandleSeparator()
        separator.position = SIMD3<Float>(x((areaX + groupStartX) / 2), 0, 0)
        area.addChild(separator)

        // フィールド操作ハンドル群
        for (i, spec) in group.enumerated() {
            let handle = makeFieldHandle(kind: spec.kind, color: spec.color, name: spec.name)
            handle.position = SIMD3<Float>(x(groupStartX + S * Float(i)), 0, 0)
            area.addChild(handle)
            switch spec.kind {
            case .move: fieldMoveHandle = handle
            case .rotate: fieldRotateHandle = handle
            case .scale: fieldScaleHandle = handle
            case .recenter: fieldRecenterHandle = handle
            case .area: break
            }
        }

        // 生成直後に一度、正面(ヘッド)を向かせる。以降は毎tickの billboard 更新で追従。
        updateFieldHandleBillboard()
        DuelLog.event("FieldHandlesReady", "count=\(group.count + 1) areaWorld=\(shortVector(area.position(relativeTo: nil)))")
    }

    /// 全ハンドルを常に Vision Pro(ヘッド)の方へヨーで向け、さらに面を上へ倒す。
    /// ハンドルは手元の低い位置に置くため、面が真横(こちら向き)だと見下ろして操作しづらい。
    /// ヘッド方向へのヨーに加えて `fieldHandleFacePitch` だけ面を上に傾け、上から操作しやすくする。
    /// 各ハンドルを個別に「自分の原点まわり」で回すので、ワールド位置は変わらない。
    func updateFieldHandleBillboard() {
        guard let head = menuHeadAnchor else { return }
        let headWorld = head.position(relativeTo: nil)
        guard simd_length(headWorld) > 0.05 else { return }
        // ローカル X 軸まわりに面を上へ倒す(-Pitch で +Z 面が上向きになる)。
        let pitch = simd_quatf(angle: -DuelDiskMetrics.fieldHandleFacePitch, axis: SIMD3<Float>(1, 0, 0))
        let handles = [fieldMoveHandle, fieldRotateHandle, fieldScaleHandle, fieldAreaHandle, fieldRecenterHandle]
        for handle in handles.compactMap({ $0 }) {
            let hp = handle.position(relativeTo: nil)
            let toHead = headWorld - hp
            let flat = SIMD3<Float>(toHead.x, 0, toHead.z)
            guard simd_length(flat) > 0.0001 else { continue }
            let yaw = atan2(flat.x, flat.z)  // まず +Z 面をヘッド方向へ向ける
            let yawQuat = simd_quatf(angle: yaw, axis: SIMD3<Float>(0, 1, 0))
            // ヨー(ワールド)→ ピッチ(ローカルX)の順に合成し、面を上へ倒す。
            handle.setOrientation(yawQuat * pitch, relativeTo: nil)
        }
    }

    /// ハンドル1個を生成する。角丸パネルの正面(+Z)に「SFシンボルのアイコン + 日本語ラベル」の
    /// テクスチャを貼り、色だけでなくアイコン/文字で一目で区別できるようにする。
    func makeFieldHandle(kind: FieldHandleComponent.Kind, color: UIColor, name: String) -> ModelEntity {
        let size = DuelDiskMetrics.fieldHandleSize
        // 台座(角丸パネル)。色付き・半透明で "ボタン" らしく。
        var base = PhysicallyBasedMaterial()
        base.baseColor = .init(tint: color.withAlphaComponent(0.9))
        base.emissiveColor = .init(color: color)
        base.emissiveIntensity = DuelDiskMetrics.fieldHandleEmissiveIntensity
        base.roughness = 0.4
        let panel = ModelEntity(
            mesh: .generateBox(size: size, cornerRadius: min(size.x, size.y) * 0.22),
            materials: [base]
        )
        panel.name = name
        panel.components.set(FieldHandleComponent(kind: kind))
        panel.components.set(InputTargetComponent())
        panel.components.set(HoverEffectComponent(.highlight(.init(color: .white, strength: 1.0))))
        panel.components.set(CollisionComponent(
            shapes: [.generateBox(size: SIMD3<Float>(size.x * 1.2, size.y * 1.2, size.z * 2.0))],
            mode: .default,
            filter: .default
        ))

        // 正面(+Z)にアイコン+ラベルのテクスチャ板を貼る(白のアイコン/文字が透過背景で乗る)。
        var faceMat = UnlitMaterial()
        faceMat.color = .init(tint: .white)
        if let tex = handleFaceTexture(for: kind) {
            faceMat.color = .init(tint: .white, texture: .init(tex))
        }
        faceMat.blending = .transparent(opacity: .init(floatLiteral: 1.0))
        let face = ModelEntity(
            mesh: .generatePlane(width: size.x * 0.92, height: size.y * 0.92),
            materials: [faceMat]
        )
        face.name = "\(name)_Face"
        face.position = SIMD3<Float>(0, 0, size.z / 2 + 0.001)  // 正面(+Z)手前
        panel.addChild(face)
        return panel
    }

    /// 「まとめて」と操作ハンドル群の間に置く縦の区切り(細い半透明の板)。
    func makeHandleSeparator() -> ModelEntity {
        let h = DuelDiskMetrics.fieldHandleSize.y * 1.05
        var mat = UnlitMaterial()
        mat.color = .init(tint: UIColor.white.withAlphaComponent(0.35))
        mat.blending = .transparent(opacity: .init(floatLiteral: 0.35))
        let bar = ModelEntity(
            mesh: .generateBox(size: SIMD3<Float>(0.006, h, 0.006), cornerRadius: 0.003),
            materials: [mat]
        )
        bar.name = "FieldHandleSeparator"
        return bar
    }

    /// ハンドル正面テクスチャ(SFシンボル + ラベル)を一度だけ生成してキャッシュする。
    func handleFaceTexture(for kind: FieldHandleComponent.Kind) -> TextureResource? {
#if canImport(UIKit)
        if let cached = HandleFaceTextureCache.textures[kind] { return cached }
        let (symbol, label): (String, String) = {
            switch kind {
            case .move: return ("arrow.up.and.down.and.arrow.left.and.right", "移動")
            case .rotate: return ("arrow.trianglehead.clockwise", "回転")
            case .scale: return ("arrow.up.left.and.arrow.down.right", "サイズ")
            case .area: return ("hand.point.up.left.fill", "まとめて")
            case .recenter: return ("scope", "正面へ")
            }
        }()
        let content = VStack(spacing: 10) {
            Image(systemName: symbol)
                .font(.system(size: 110, weight: .bold))
            Text(label)
                .font(.system(size: 52, weight: .heavy))
                .lineLimit(1)
                .minimumScaleFactor(0.4)
        }
        .foregroundStyle(.white)
        .shadow(color: .black.opacity(0.6), radius: 4)
        .frame(width: 256, height: 256)
        let renderer = ImageRenderer(content: content)
        renderer.scale = 3
        renderer.isOpaque = false
        guard let cg = renderer.cgImage else { return nil }
        let tex = try? TextureResource(image: cg, options: .init(semantic: .color))
        HandleFaceTextureCache.textures[kind] = tex
        return tex
#else
        return nil
#endif
    }

    /// 衝突購読を **対象 entity を限定して** 仕掛ける。
    /// 旧実装の wildcard subscribe は別グループの誤通知を拾うリスクがあったため、
    /// プローブごとに明示的に entity を渡している。
    func installCollisionSubscriptions(content: RealityViewContent) {
        // 1) 右手ドロープローブ → デッキ衝突 (デバッグログ用)。
        //    ドローの発火自体は polling の updateDeckDrawGesture が担う
        //    (「指がくっついた状態でデッキに交差 → 離した時にドロー」のため、Began 単発では判定できない)。
        if let drawProbe = rightDrawProbe {
            let sub = content.subscribe(to: CollisionEvents.Began.self, on: drawProbe) { event in
                Task { @MainActor in
                    let other = otherEntity(event: event, against: drawProbe)
                    // デッキ識別は DeckMarkerComponent で行う(name 文字列は使わない)
                    guard other.components[DeckMarkerComponent.self] != nil else { return }
                    DuelLog.event("DrawProbeEnteredDeck", "phase=\(String(describing: sessionStore.phase)) handCount=\(sessionStore.hand.count)")
                }
            }
            collisionSubscriptions.append(sub)
        }

        // 2) 左 palm ↔ 右手カード → 近接吸い込みの補助トリガ
        if let palm = leftPalmAnchor {
            let sub = content.subscribe(to: CollisionEvents.Began.self, on: palm) { _ in
                Task { @MainActor in
                    DuelLog.event("FanAbsorbCollision", "rightHandCard=\(sessionStore.rightHandCard?.id.uuidString ?? "nil")")
                    attemptAddRightHandCardToFan(trigger: "palmCollision")
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
        // 頭アンカーの子として視界正面(0.7m 前方・やや下)に固定する。
        // 遠くのモンスター位置に置くと小さく読めないため、常に目の前に出す。
        (menuHeadAnchor ?? rootEntity).addChild(menu)
        menu.position = SIMD3<Float>(0, -0.1, -0.7)
        menu.isEnabled = false
        attachmentInstalled = true
    }

    /// ライフ表示(8000)をディスクの LifeDisplay ノード上に一度だけ設置する。
    func installLifeDisplayIfNeeded(_ attachments: RealityViewAttachments) {
        guard !lifeDisplayInstalled,
              let board = boardEntity,
              let model = diskModelEntity,
              let node = model.findEntity(named: DuelDiskModelFactory.lifeDisplayName),
              let lifeEntity = attachments.entity(for: AttachmentID.lifeDisplay) else { return }

        // LCD 幅(約7cm)に合わせて attachment を縮小する
        let bounds = lifeEntity.visualBounds(relativeTo: lifeEntity)
        let targetWidth: Float = 0.07
        let scale = bounds.extents.x > 0.0001 ? targetWidth / bounds.extents.x : 1
        lifeEntity.transform.scale = SIMD3<Float>(repeating: scale)
        // LifeDisplay ノードの姿勢へ合わせ、面が上(+Y)を向くよう寝かせる。
        // ディスク面にぴったり乗るよう、Z-fight を避ける最小限だけ浮かせる。
        lifeEntity.transform.translation = node.convert(position: .zero, to: board) + SIMD3<Float>(0, 0.0005, 0)
        lifeEntity.transform.rotation = yawOnlyOrientation(of: node, relativeTo: board)
            * simd_quatf(angle: -.pi / 2, axis: SIMD3<Float>(1, 0, 0))
        board.addChild(lifeEntity)
        lifeDisplayInstalled = true
        DuelLog.event("LifeDisplayInstalled", "scale=\(scale)")
    }

    func syncCardAttachments(_ attachments: RealityViewAttachments) {
        for card in sessionStore.hand {
            if let entity = fanCardEntities[card.id] {
                attachCardViewIfNeeded(
                    to: entity,
                    attachmentID: AttachmentID.handCard(card.id),
                    attachments: attachments,
                    context: "HandFan",
                    surface: .fan
                )
            }
        }

        if let card = sessionStore.rightHandCard, let entity = rightHandCardEntity {
            attachCardViewIfNeeded(
                to: entity,
                attachmentID: AttachmentID.rightHandCard(card.id),
                attachments: attachments,
                context: "RightHand",
                surface: .handheld
            )
        }

        for (slotIndex, optCard) in sessionStore.diskSlots.enumerated() {
            guard let card = optCard, let entity = placedDiskCardEntities[card.id] else { continue }
            attachCardViewIfNeeded(
                to: entity,
                attachmentID: AttachmentID.diskCard(slotIndex: slotIndex, cardID: card.id),
                attachments: attachments,
                context: "DiskSlot",
                surface: .horizontal
            )
        }

        for (col, optCard) in sessionStore.fieldBackRow.enumerated() {
            guard let card = optCard, let entity = fieldCardEntities[col] else { continue }
            attachCardViewIfNeeded(
                to: entity,
                attachmentID: AttachmentID.fieldBackCard(column: col, cardID: card.id),
                attachments: attachments,
                context: "FieldBack",
                surface: .horizontal
            )
        }

        for (col, optCard) in sessionStore.fieldFrontRow.enumerated() {
            guard let card = optCard, let entity = fieldFrontCardEntities[col] else { continue }
            attachCardViewIfNeeded(
                to: entity,
                attachmentID: AttachmentID.fieldFrontCard(column: col, cardID: card.id),
                attachments: attachments,
                context: "FieldFront",
                surface: .horizontal
            )
        }
    }

    /// エフェクト holder の名前 prefix(シーングラフ上の走査に使う)。
    static let diskSummonEffectHolderPrefix = "DiskSummonEffect_"

    func syncDiskSummonEffectAttachments(_ attachments: RealityViewAttachments) {
        guard let board = boardEntity else { return }
        let validIds = Set(activeDiskSummonEffects.keys)
        // 期限切れ(activeでない)holder をシーングラフから除去する。
        // ※ @State(diskSummonEffectEntities)は RealityView の update closure 内での変更が
        //   確実に反映されず、同じ effectId の holder が何度も生成されて線が多重に重なる
        //   (=汚く見える)原因になっていた。判定はシーングラフ上の holder を直接見る方式にする。
        for child in board.children where child.name.hasPrefix(Self.diskSummonEffectHolderPrefix) {
            let idString = String(child.name.dropFirst(Self.diskSummonEffectHolderPrefix.count))
            if let id = UUID(uuidString: idString), validIds.contains(id) { continue }
            child.removeFromParent()
            if let id = UUID(uuidString: idString) { diskSummonEffectEntities.removeValue(forKey: id) }
        }

        for effect in activeDiskSummonEffects.values {
            guard effect.slotIndex < diskSlotEntities.count else {
                DuelLog.line("sync/skip", "slot=\(effect.slotIndex) reason=slotIndexOutOfRange slotCount=\(diskSlotEntities.count)")
                continue
            }
            let holderName = "\(Self.diskSummonEffectHolderPrefix)\(effect.id.uuidString)"
            // 既に holder がシーンにあるなら二重生成しない(@State に依存しない堅牢なガード)。
            guard board.findEntity(named: holderName) == nil else { continue }
            guard let attachment = attachments.entity(for: AttachmentID.diskSummonEffect(effect.id)) else {
                DuelLog.warning("Disk summon effect attachment missing slot=\(effect.slotIndex) effectId=\(effect.id.uuidString)")
                DuelLog.line("sync/skip", "slot=\(effect.slotIndex) reason=attachmentMissing effectId=\(effect.id.uuidString)")
                continue
            }
            let slot = diskSlotEntities[effect.slotIndex]
            let holder = Entity()
            holder.name = holderName
            attachment.name = "DiskSummonEffectAttachment"
            let bounds = attachment.visualBounds(relativeTo: attachment)
            let extents = bounds.extents
            // エフェクト平面は「置いたカードそのものの姿勢」に合わせる。
            // = スロット(=配置カード)の位置・向きをそのまま使う。カードは常にキャンバス中央にある。
            // 平面はカード周囲の局所エリアだけ(下記サイズ)を覆い、その矩形でクリップする。
            let areaW = DuelDiskMetrics.diskSummonEffectAreaWidth
            let areaD = DuelDiskMetrics.diskSummonEffectAreaDepth
            let shape = effectAttachmentShape(for: extents, targetWidth: areaW, targetDepth: areaD)
            // 位置・向き・高さは配置カードと同一(= co-planar)。エフェクトは1枚の平面で、
            // 中央のカード footprint 分が透明の「穴」になっており、その周囲から線が出る。
            // カードと同一平面なので穴とカードが一致し、視差でカードに被らない(プレビューと同じ)。
            holder.transform.translation = slot.position
                + SIMD3<Float>(0, DuelDiskMetrics.diskSummonEffectLift, 0)
            holder.transform.rotation = slot.orientation * faceUpCardRotation(topDirection: SIMD3<Float>(0, 0, -1))
            attachment.transform = Transform(
                scale: shape.scale,
                rotation: shape.rotation,
                translation: SIMD3<Float>(0, DuelDiskMetrics.cardThickness, 0)
            )
            board.addChild(holder)
            holder.addChild(attachment)
            diskSummonEffectEntities[effect.id] = holder
            // --- issue 1 診断: 1行に集約 -------------------------------------------
            // effectAboveCardMM: >0 なら視差でカードに被りやすい / stripSpillXZ: カード置き場エリア外への
            // はみ出し(本命指標, >0 で線がエリア外) / reachWxD: 線がカード周囲へ伸びる距離。
            let holderWorld = holder.position(relativeTo: nil)
            let cardTopWorld = boardEntity?.convert(
                position: slot.position + SIMD3<Float>(0, DuelDiskMetrics.diskPlacedCardLift, 0), to: nil
            ) ?? .zero
            let reachW = (areaW - DuelDiskMetrics.diskSlotWidth) / 2
            let reachD = (areaD - DuelDiskMetrics.diskSlotDepth) / 2
            let sx = slot.position.x, sz = slot.position.z
            let effMinX = sx - areaW / 2, effMaxX = sx + areaW / 2
            let effMinZ = sz - areaD / 2, effMaxZ = sz + areaD / 2
            let sxs = diskSlotEntities.map { $0.position.x }, szs = diskSlotEntities.map { $0.position.z }
            let stripMinX = (sxs.min() ?? sx) - DuelDiskMetrics.cardWidth / 2
            let stripMaxX = (sxs.max() ?? sx) + DuelDiskMetrics.cardWidth / 2
            let stripMinZ = (szs.min() ?? sz) - DuelDiskMetrics.cardDepth / 2
            let stripMaxZ = (szs.max() ?? sz) + DuelDiskMetrics.cardDepth / 2
            let stripSpillX = max(0, stripMinX - effMinX) + max(0, effMaxX - stripMaxX)
            let stripSpillZ = max(0, stripMinZ - effMinZ) + max(0, effMaxZ - stripMaxZ)
            DuelLog.line(
                "attached",
                "slot=\(effect.slotIndex)"
                + " effectAboveCardMM=\(String(format: "%.1f", (holderWorld.y - cardTopWorld.y) * 1000))"
                + " areaWxD=\(String(format: "%.3fx%.3f", areaW, areaD))"
                + " reachWxD=\(String(format: "%.3fx%.3f", reachW, reachD))"
                + " stripSpillXZ=\(String(format: "%.3fx%.3f", stripSpillX, stripSpillZ))"
            )
            // -----------------------------------------------------------------------
        }
    }

    func attachCardViewIfNeeded(
        to entity: Entity,
        attachmentID: String,
        attachments: RealityViewAttachments,
        context: String,
        surface: CardAttachmentSurface
    ) {
        if entity.findEntity(named: "CardAttachment") != nil { return }
        guard let attachment = attachments.entity(for: attachmentID) else {
            DuelLog.warning("Card attachment entity missing context=\(context) attachmentID=\(attachmentID)")
            return
        }
        attachment.name = "CardAttachment"
        let bounds = attachment.visualBounds(relativeTo: attachment)
        let extents = bounds.extents
        let shape = cardAttachmentShape(for: extents, surface: surface)
        attachment.transform = Transform(
            scale: shape.scale,
            rotation: shape.rotation,
            translation: SIMD3<Float>(0, DuelDiskMetrics.cardThickness / 2, 0)
        )
        installCardBackPlane(on: attachment, extents: extents)
        entity.addChild(attachment)
        DuelLog.event(
            "CardAttachmentBound",
            "context=\(context) attachmentID=\(attachmentID) extents=\(shortVector(extents)) scale=\(shortVector(shape.scale)) thicknessAxis=\(shape.thicknessAxis) faceAxes=\(shape.faceAxes)"
        )
    }

    /// SwiftUI attachment は背面から見ると内容が鏡写しに透けて見えるため、
    /// カード裏面デザイン (`CardBackView`) を焼き込んだ板を attachment の背後に貼る。
    /// attachment のローカル XY 面 (法線 +Z) と同サイズにし、スケールは親から継承させる。
    func installCardBackPlane(on attachment: Entity, extents: SIMD3<Float>) {
        guard attachment.findEntity(named: "CardBackPlane") == nil else { return }
        var material = UnlitMaterial()
#if canImport(UIKit)
        if let texture = cardBackTextureResource() {
            material.color = .init(tint: .white, texture: .init(texture))
        } else {
            material.color = .init(tint: .white)
        }
#endif
        let back = ModelEntity(
            mesh: .generatePlane(
                width: max(extents.x, 0.001),
                height: max(extents.y, 0.001)
            ),
            materials: [material]
        )
        back.name = "CardBackPlane"
        // 表面と Z-fighting しないよう僅かに背面へ置き、裏側 (-Z) から見えるよう反転する
        back.position = SIMD3<Float>(0, 0, -0.0005)
        back.orientation = simd_quatf(angle: .pi, axis: SIMD3<Float>(0, 1, 0))
        attachment.addChild(back)
    }

    /// デッキの一番上の面にカード裏面デザインを貼り、「カードの束」に見えるようにする。
    func installDeckBackFace(on deck: ModelEntity) {
        guard deck.findEntity(named: "DeckBackFace") == nil else { return }
        var material = UnlitMaterial()
#if canImport(UIKit)
        if let texture = cardBackTextureResource() {
            material.color = .init(tint: .white, texture: .init(texture))
        } else {
            material.color = .init(tint: UIColor(red: 0.72, green: 0.55, blue: 0.36, alpha: 1.0))
        }
#endif
        // deck ローカルの XZ 平面(法線 +Y)。デッキ天面のわずかに上に置く。
        let plane = ModelEntity(
            mesh: .generatePlane(width: DuelDiskMetrics.cardWidth, depth: DuelDiskMetrics.cardDepth),
            materials: [material]
        )
        plane.name = "DeckBackFace"
        plane.position = SIMD3<Float>(0, DuelDiskMetrics.deckHeight / 2 + 0.0006, 0)
        deck.addChild(plane)
    }

    /// カード裏面デザインを一度だけラスタライズして TextureResource 化しキャッシュする。
    func cardBackTextureResource() -> TextureResource? {
#if canImport(UIKit) && canImport(YugiohCardEffect)
        if CardBackTextureCache.didAttempt { return CardBackTextureCache.texture }
        CardBackTextureCache.didAttempt = true
        let renderer = ImageRenderer(content:
            CardBackView().frame(width: 236, height: 344)
        )
        renderer.scale = 3
        guard let cgImage = renderer.cgImage else { return nil }
        CardBackTextureCache.texture = try? TextureResource(
            image: cgImage,
            options: .init(semantic: .color)
        )
        return CardBackTextureCache.texture
#else
        return nil
#endif
    }

    func cardAttachmentShape(
        for extents: SIMD3<Float>,
        surface: CardAttachmentSurface
    ) -> (scale: SIMD3<Float>, rotation: simd_quatf, thicknessAxis: String, faceAxes: String) {
        let epsilon: Float = 0.0001
        let x = max(extents.x, epsilon)
        let y = max(extents.y, epsilon)
        let z = max(extents.z, epsilon)

        // SwiftUI attachment は薄い 2D 面になるため、最小軸は「厚み」ではなく「面の法線」。
        // その軸を cardThickness に無理に合わせると、0 に近い値の逆数でスケールが破綻する。
        // ここでは面の 2 軸だけをカードの幅・高さに合わせ、最小軸は 1 のままにする。
        if z <= x && z <= y {
            let rotation: simd_quatf = switch surface {
            case .horizontal:
                simd_quatf(angle: .pi, axis: SIMD3<Float>(0, 1, 0))
                * simd_quatf(angle: -.pi / 2, axis: SIMD3<Float>(1, 0, 0))
            case .fan, .handheld:
                simd_quatf(angle: .pi / 2, axis: SIMD3<Float>(1, 0, 0))
            }
            return (
                SIMD3<Float>(
                    DuelDiskMetrics.cardWidth / x,
                    DuelDiskMetrics.cardDepth / y,
                    1
                ),
                rotation,
                "z",
                "xy"
            )
        }

        if y <= x && y <= z {
            return (
                SIMD3<Float>(
                    DuelDiskMetrics.cardWidth / x,
                    1,
                    DuelDiskMetrics.cardDepth / z
                ),
                simd_quatf(),
                "y",
                "xz"
            )
        }

        return (
            SIMD3<Float>(
                1,
                DuelDiskMetrics.cardWidth / y,
                DuelDiskMetrics.cardDepth / z
            ),
            simd_quatf(angle: -.pi / 2, axis: SIMD3<Float>(0, 0, 1)),
            "x",
            "yz"
        )
    }

    /// 召喚エフェクト平面を、指定のワールド幅×奥行き (m) に一致させる scale/rotation を返す。
    /// SwiftUI attachment は「z が法線の薄い面(faceAxes=xy)」なので、
    /// 面の幅= X 軸, 面の奥行= **Y 軸**, 法線= Z 軸。
    /// base.scale は (cardWidth/x, cardDepth/y, 1)。奥行きは Y 軸に掛ける必要がある。
    /// 以前は奥行きを Z(法線)に掛けていたため、面の奥行きが cardDepth のまま(=areaD にならず)
    /// キャンバスが奥行方向に潰れ、線の発生源(カード領域)が実カードより小さくなって
    /// 「線がカードの内側から出る」不具合になっていた。
    func effectAttachmentShape(
        for extents: SIMD3<Float>,
        targetWidth: Float,
        targetDepth: Float
    ) -> (scale: SIMD3<Float>, rotation: simd_quatf) {
        let base = cardAttachmentShape(for: extents, surface: .horizontal)
        return (
            SIMD3<Float>(
                targetWidth / DuelDiskMetrics.cardWidth * base.scale.x,   // 面の幅 (X)
                targetDepth / DuelDiskMetrics.cardDepth * base.scale.y,   // 面の奥行 (Y) ← 修正
                base.scale.z                                              // 法線 (Z) はそのまま
            ),
            base.rotation
        )
    }

    func faceUpCardRotation(topDirection: SIMD3<Float>) -> simd_quatf {
        let normalized = simd_normalize(topDirection)
        let yaw = atan2(normalized.x, normalized.z)
        return simd_quatf(angle: yaw, axis: SIMD3<Float>(0, 1, 0))
    }
}

// MARK: - 衝突ハンドラ補助

private extension YugiohDuelDiskImmersiveView {
    /// 衝突イベントから「自分以外」のエンティティを取り出す。
    func otherEntity(event: CollisionEvents.Began, against me: Entity) -> Entity {
        event.entityA === me ? event.entityB : event.entityA
    }

    /// タップ/クリックされた Entity から意味のある祖先までの名前チェーンを作る(診断用)。
    func ancestorChainDescription(from entity: Entity, maxDepth: Int = 8) -> String {
        var names: [String] = []
        var cur: Entity? = entity
        var depth = 0
        while let e = cur, depth < maxDepth {
            let tags = [
                e.components[DiskSlotIndexComponent.self] != nil ? "slot#\(e.components[DiskSlotIndexComponent.self]!.index)" : nil,
                e.components[CardIdentityComponent.self] != nil ? "card" : nil,
                e.components[PlacedCardLocationComponent.self] != nil ? "placed" : nil,
                e.components[SpellSlotIndexComponent.self] != nil ? "spell" : nil,
                e.components[FieldHandleComponent.self] != nil ? "handle" : nil,
                e.components[FieldInteractionComponent.self] != nil ? "field" : nil,
                e.components[InputTargetComponent.self] != nil ? "input" : nil,
            ].compactMap { $0 }.joined(separator: ",")
            names.append(tags.isEmpty ? "'\(e.name)'" : "'\(e.name)'[\(tags)]")
            cur = e.parent
            depth += 1
        }
        return names.joined(separator: " < ")
    }

    /// 標準の visionOS targeted tap で拾った entity を、意味のある親まで遡って解決する。
    func handleSpatialTap(on tappedEntity: Entity) {
        // --- issue 2 共通の入口ログ: 視線クリックが発火し、どの entity に当たったか ---
        // (これが出ない = クリックジェスチャー自体が発火していない / InputTarget に当たっていない)
        DuelLog.place(
            "tap",
            "hit=\(ancestorChainDescription(from: tappedEntity))"
            + " selectedHand=\(sessionStore.selectedHandCardId?.uuidString ?? "nil")"
            + " selectedKind=\(sessionStore.selectedCardKind.map { String(describing: $0) } ?? "nil")"
            + " phase=\(String(describing: sessionStore.phase))"
        )

        // 再配置ハンドル(タップ): 現在の視線正面を基準にフィールドを置き直す。
        if fieldHandle(from: tappedEntity, kind: .recenter) {
            recenterFieldToView()
            return
        }

        // 魔法・トラップ挿入口オーバーレイ板のタップ → 選択中の魔法/トラップを配置
        if let spellIndex = resolveSpellSlotIndex(from: tappedEntity) {
            DuelLog.event(
                "SpellSlotOverlayTapped",
                "slot=\(spellIndex) selected=\(sessionStore.selectedCardKind.map { String(describing: $0) } ?? "nil")"
            )
            sessionStore.placeSelectedCardToSpellSlot(index: spellIndex)
            return
        }

        // ディスク部品 (ボタン / 魔法・トラップ挿入口 / 墓地) のタップを最優先で判定
        if let part = DuelDiskModelFactory.resolveTapPartName(from: tappedEntity) {
            if part.hasPrefix("Button_") {
                // 手前の5つのボタン → 対応する列の「裏でセットした魔法・トラップ」をオープンする。
                if let index = spellSlotIndex(from: part) {
                    let context = PlacedCardContext.fieldFront(index)
                    if sessionStore.canOpenCard(at: context) {
                        DuelLog.event("DiskButtonOpenSetCard", "button=\(part) col=\(index)")
                        sessionStore.openPlacedCard(at: context)
                    } else {
                        DuelLog.event("DiskButtonTapped", "button=\(part) col=\(index) openable=false")
                    }
                }
            } else if part.hasPrefix("SpellSlot_") {
                // 魔法・トラップ挿入口 → 選択中の魔法/トラップを配置
                if let index = spellSlotIndex(from: part) {
                    DuelLog.event(
                        "SpellTrapSlotTapped",
                        "slot=\(index) selected=\(sessionStore.selectedCardKind.map(String.init(describing:)) ?? "nil")"
                    )
                    sessionStore.placeSelectedCardToSpellSlot(index: index)
                }
            } else {
                DuelLog.event("GraveyardTapped", "part=\(part)")
            }
            return
        }

        // 召喚ゾーン面 (Zone_i_Field) のタップ → スロット配置 (DiskSlot plane と同じ挙動)
        if let zoneIndex = DuelDiskModelFactory.resolveZoneFieldIndex(from: tappedEntity) {
            DuelLog.event(
                "ZoneFieldTapped",
                "slot=\(zoneIndex) selected=\(sessionStore.selectedHandCardId?.uuidString ?? "nil")"
            )
            placeToDiskSlotLogged(index: zoneIndex, source: "Zone_i_Field")
            return
        }

        let target = resolveInteractiveEntity(startingFrom: tappedEntity)

        if let slotIdx = target?.components[DiskSlotIndexComponent.self]?.index {
            let isSelectable = sessionStore.selectedHandCardId != nil
            DuelLog.event(
                "DiskSlotTapped",
                "slot=\(slotIdx) selected=\(sessionStore.selectedHandCardId?.uuidString ?? "nil") phase=\(String(describing: sessionStore.phase)) selectable=\(isSelectable)"
            )
            placeToDiskSlotLogged(index: slotIdx, source: "DiskSlotPlane")
            return
        }

        if let locationComp = target?.components[PlacedCardLocationComponent.self] {
            // 召喚エフェクト再生中の誤爆ガード:
            // モンスター召喚直後、演出中に同じスロットのカードをタップ扱いしてしまうと、
            // 「このカードを消しますか?」のアラートが意図せず出てしまう。
            // 該当スロットの召喚エフェクトが終わるまでは、配置カードのタップを無視する。
            if case .diskSlot(let i) = locationComp.location,
               isDiskSummonEffectActive(forSlot: i) {
                DuelLog.place("placedTapBlocked", "slot=\(i) reason=summonEffectPlaying")
                return
            }
            DuelLog.event("PlacedCardTapped", "location=\(locationComp.location)")
            sessionStore.tappedPlacedCardContext = mapToContext(locationComp.location)
            return
        }

        if let cardId = target?.components[CardIdentityComponent.self]?.id,
           sessionStore.hand.contains(where: { $0.id == cardId }) {
            // 右手の人差し指+中指がくっついている間(=カードを持ち替え/デッキ操作中)は、
            // 手札カードに指が触れても選択しない。右手カードを扇に戻して手を戻すときに、
            // 意図せず別のカードが選択される誤爆を防ぐ。
            if rightIndexMiddleTouching() {
                DuelLog.place("selectBlocked", "cardId=\(cardId.uuidString) reason=rightIndexMiddleTouching")
                return
            }
            DuelLog.event("HandCardTapped", "cardId=\(cardId.uuidString)")
            sessionStore.selectHandCard(id: cardId)
            return
        }

        DuelLog.state(
            "SpatialTapIgnored",
            "entity=\(tappedEntity.name) parent=\(tappedEntity.parent?.name ?? "nil") hasCard=\(tappedEntity.components[CardIdentityComponent.self] != nil) hasSlot=\(tappedEntity.components[DiskSlotIndexComponent.self] != nil) hasPlaced=\(tappedEntity.components[PlacedCardLocationComponent.self] != nil) hasFieldInteraction=\(resolveFieldInteractionEntity(startingFrom: tappedEntity) != nil)"
        )
    }

    /// ディスク召喚スロットへの配置を、成否と原因つきでログして実行する(issue 2)。
    /// 召喚できるのは「選択中のカード」だけ。選択カードは 2 箇所に居うる:
    ///   1. 手札にある選択カード        → placeSelectedCardToDiskSlot
    ///   2. 選択したまま右手に持ち替えたカード → summonRightHandCardToDiskSlot
    /// (未選択でも右手にカードがある状態=「ドローしたカード」は召喚対象にしない。
    ///  それは手札に加えるためのカードで、スロットに置くものではないため。)
    func placeToDiskSlotLogged(index: Int, source: String) {
        func nameOf(_ c: DuelCard?) -> String {
            switch c {
            case .monster(let m): return m.name
            case .spell(let s): return s.name
            case .trap(let t): return t.name
            case nil: return "nil"
            }
        }
        let selected = sessionStore.selectedCard   // 手札 or 右手(選択中)
        let inHand = selected != nil && sessionStore.hand.contains { $0.id == selected?.id }
        let carriedInRightHand = selected != nil && sessionStore.rightHandCard?.id == selected?.id
        let occupiedBefore = sessionStore.diskSlots[safe: index].flatMap { $0 } != nil

        let reason: String
        if !(0..<DuelSessionStore.diskSlotCount).contains(index) {
            reason = "indexOutOfRange"
        } else if selected == nil {
            reason = "noCardSelected"  // 未選択(ドローの右手カードは召喚対象外)
        } else if selected?.kind != .monster {
            reason = "selectedNotMonster(kind=\(selected.map { String(describing: $0.kind) } ?? "nil"))"
        } else if occupiedBefore {
            reason = "slotOccupied"
        } else {
            reason = "shouldSucceed"
        }
        DuelLog.place(
            "place/try",
            "slot=\(index) source=\(source) where=\(inHand ? "hand" : carriedInRightHand ? "rightHandCarry" : "none") card=\(nameOf(selected)) kind=\(selected.map { String(describing: $0.kind) } ?? "nil") occupiedBefore=\(occupiedBefore) predicted=\(reason)"
        )

        if inHand {
            sessionStore.placeSelectedCardToDiskSlot(index: index)
        } else if carriedInRightHand {
            _ = sessionStore.summonRightHandCardToDiskSlot(index: index)
        }

        let occupiedAfter = sessionStore.diskSlots[safe: index].flatMap { $0 } != nil
        let placed = occupiedAfter && !occupiedBefore
        DuelLog.place(
            "place/result",
            "slot=\(index) placed=\(placed) occupiedAfter=\(occupiedAfter) handCount=\(sessionStore.hand.count) rightHandAfter=\(sessionStore.rightHandCard == nil ? "nil" : "held") selectedAfter=\(sessionStore.selectedHandCardId?.uuidString ?? "nil")"
        )
    }

    func resolveInteractiveEntity(startingFrom entity: Entity) -> Entity? {
        var current: Entity? = entity
        while let candidate = current {
            if candidate.components[DiskSlotIndexComponent.self] != nil
                || candidate.components[PlacedCardLocationComponent.self] != nil
                || candidate.components[CardIdentityComponent.self] != nil {
                return candidate
            }
            current = candidate.parent
        }
        return nil
    }

    func resolveFieldInteractionEntity(startingFrom entity: Entity) -> Entity? {
        var current: Entity? = entity
        while let candidate = current {
            // フィールド上のカード/モンスターを掴んだ時はフィールド全体を動かさない。
            // (配置カードはタップでメニューを開く。誤ってフィールドが D&D されるのを防ぐ)
            if candidate.components[CardIdentityComponent.self] != nil
                || candidate.components[PlacedCardLocationComponent.self] != nil {
                return nil
            }
            if candidate.components[FieldInteractionComponent.self] != nil {
                return candidate
            }
            current = candidate.parent
        }
        return nil
    }

    /// "SpellSlot_3" → 2 (0-based)。
    func spellSlotIndex(from part: String) -> Int? {
        let parts = part.split(separator: "_")
        guard parts.count >= 2, let number = Int(parts[1]), (1...5).contains(number) else { return nil }
        return number - 1
    }

    /// タップされた Entity(またはその祖先)から魔法・トラップ挿入口オーバーレイの index を解決する。
    func resolveSpellSlotIndex(from entity: Entity) -> Int? {
        var current: Entity? = entity
        while let candidate = current {
            if let index = candidate.components[SpellSlotIndexComponent.self]?.index {
                return index
            }
            current = candidate.parent
        }
        return nil
    }

    func mapToContext(_ location: PlacedCardLocationComponent.Location) -> PlacedCardContext {
        switch location {
        case .diskSlot(let i): return .diskSlot(i)
        case .spellSlot(let i): return .spellSlot(i)
        case .fieldBack(let i): return .fieldBack(i)
        case .fieldFront(let i): return .fieldFront(i)
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
        let left = pinchSignals(component: leftHandComponent)
        let right = pinchSignals(component: rightHandComponent)
        // 手札表示は「3本指(親指+人差し指+中指)」のときだけ。2本指では出さない。
        // ただし、右手でタップする際に左手がカメラの死角に入ると一時的に未トラッキングになり、
        // 手札が消えてしまう。左手が「未トラッキング」の間は少しの猶予(grace)を与えて手札を保持する。
        // (実際に手を開いた=トラッキング済みで3本指でない、ときは即座に隠す)
        if left.threeFinger {
            sessionStore.isLeftPinching = true
            leftPinchGraceFrames = DuelDiskMetrics.leftPinchGraceFrames
        } else {
            let leftTracked = trackedPosition(leftThumbTipAnchor) != nil
                || trackedPosition(leftIndexTipAnchor) != nil
                || trackedPosition(leftMiddleTipAnchor) != nil
            if !leftTracked, leftPinchGraceFrames > 0, sessionStore.isLeftPinching {
                // 死角による一時ロスト → 猶予中は手札を保持する
                leftPinchGraceFrames -= 1
            } else {
                sessionStore.isLeftPinching = false
                leftPinchGraceFrames = 0
            }
        }
        sessionStore.isRightPinching = right.threeFinger
        // 召喚エリアの移動・回転はどちらも「専用ハンドル」限定にする。
        // 指ピンチ(手札表示や右手カード保持)には一切紐付けないため、誤作動しない。
        _ = (left.twoFinger, right.twoFinger)
        updateDiskPoseFollowingWrist()
        updateDynamicRigTransforms()
    }

    /// 右手の人差し指と中指がくっついているか(=カード持ち替え/デッキドロー操作中の指の形)。
    /// 手札カードの選択を、この状態のときは無効化するために使う。
    func rightIndexMiddleTouching() -> Bool {
        guard let component = rightHandComponent,
              let index = component.fingers[.indexFingerTip],
              let middle = component.fingers[.middleFingerTip] else { return false }
        let ip = index.position(relativeTo: nil)
        let mp = middle.position(relativeTo: nil)
        guard ip != .zero || mp != .zero else { return false }  // 未トラッキング時は判定しない
        return simd_distance(ip, mp) < DuelDiskMetrics.drawFingerTouchThreshold
    }

    /// -π..π に収めた角度差。
    func shortestAngleDelta(from a: Float, to b: Float) -> Float {
        var d = b - a
        while d > .pi { d -= 2 * .pi }
        while d < -.pi { d += 2 * .pi }
        return d
    }

    /// 各手のピンチ状態を返す。
    /// - twoFinger: 親指+人差し指がくっついている(中指はくっついていない)= フィールド操作用
    /// - threeFinger: 親指+人差し指+中指がすべてくっついている = 手札表示用
    /// 未トラッキング時は (0,0,0) が返るため tracked チェックを併用する。
    func pinchSignals(component: HandTrackingComponent?) -> (twoFinger: Bool, threeFinger: Bool) {
        guard let component,
              let thumbTip = component.fingers[.thumbTip],
              let indexTip = component.fingers[.indexFingerTip],
              let middleTip = component.fingers[.middleFingerTip] else { return (false, false) }
        let thumbPos = thumbTip.position(relativeTo: nil)
        let indexPos = indexTip.position(relativeTo: nil)
        let middlePos = middleTip.position(relativeTo: nil)
        guard thumbPos != .zero || indexPos != .zero || middlePos != .zero else { return (false, false) }
        let thumbIndex = distance(thumbPos, indexPos) < DuelDiskMetrics.pinchThreshold
        // 中指は厳しめの閾値で「確実にくっついている」ときだけ 3本指とみなす
        let thumbMiddle = distance(thumbPos, middlePos) < DuelDiskMetrics.threeFingerThreshold
        let indexMiddle = distance(indexPos, middlePos) < DuelDiskMetrics.threeFingerThreshold
        let threeFinger = thumbIndex && thumbMiddle && indexMiddle
        // 2本指 = 親指+人差し指がくっつき、かつ3本指ではない
        let twoFinger = thumbIndex && !threeFinger
        return (twoFinger, threeFinger)
    }

    /// 3つのハンドルのドラッグで召喚エリア/ハンドルエリアを操作する(指ピンチには一切紐付けない)。
    /// - 移動(シアン): ドラッグ量ぶんフィールドを平行移動。
    /// - 回転(オレンジ): フィールド中央を軸に、ハンドルを動かした方向へ回転。
    /// - エリア(緑): ハンドル3つのかたまり(container)自体を、ドラッグ量ぶん動かす
    ///   → ハンドルを手元の好きな位置へ持ってこられる。フィールドには触れない。
    var fieldHandleDragGesture: some Gesture {
        DragGesture()
            .targetedToAnyEntity()
            .onChanged { value in
                let worldDelta = value.convert(value.translation3D, from: .local, to: .scene)

                // (1) エリア移動ハンドル: ハンドルのかたまり container ごと動かす(フィールドは不動)。
                if fieldHandle(from: value.entity, kind: .area), let area = fieldHandleArea {
                    let start: SIMD3<Float>
                    if let s = fieldHandleAreaDragStart {
                        start = s
                    } else {
                        start = area.position(relativeTo: nil)
                        fieldHandleAreaDragStart = start
                    }
                    area.setPosition(start + worldDelta, relativeTo: nil)
                    return
                }

                // (2)(3) フィールド操作。動かすのは plain Entity の fieldInteractionRoot。
                // AnchorEntity(fieldRoot)を直接動かすと anchor 変換と二重適用されて "ワープ" するため。
                // その原点はフィールド中央なので、回転はその場回転で中央軸回転になる。
                guard let field = fieldInteractionRoot else { return }

                if fieldHandle(from: value.entity, kind: .move) {
                    let start: SIMD3<Float>
                    if let s = fieldDragStartPosition {
                        start = s
                    } else {
                        start = field.position(relativeTo: nil)
                        fieldDragStartPosition = start
                    }
                    // 前後左右+上下(3軸)すべて移動できるようにする。ハンドルは動かさない。
                    field.setPosition(start + worldDelta, relativeTo: nil)
                } else if fieldHandle(from: value.entity, kind: .rotate) {
                    // 初回に中央・ハンドル位置・開始姿勢を記録する。
                    if fieldRotateStartAngle == nil {
                        let center = field.position(relativeTo: nil)   // = フィールド中央
                        let handleStart = value.entity.position(relativeTo: nil)
                        fieldRotateCenterWorld = center
                        fieldRotateHandleStartWorld = handleStart
                        fieldRotateStartOrientation = field.orientation(relativeTo: nil)
                        fieldRotateStartAngle = atan2(handleStart.x - center.x, handleStart.z - center.z)
                    }
                    guard let center = fieldRotateCenterWorld,
                          let handleStart = fieldRotateHandleStartWorld,
                          let startAngle = fieldRotateStartAngle,
                          let startOrientation = fieldRotateStartOrientation else { return }
                    // ハンドルをドラッグした仮想位置の、中央まわりの角度差ぶん回す。
                    let dragged = handleStart + worldDelta
                    let curAngle = atan2(dragged.x - center.x, dragged.z - center.z)
                    let dAngle = shortestAngleDelta(from: startAngle, to: curAngle)
                    let rot = simd_quatf(angle: dAngle, axis: SIMD3<Float>(0, 1, 0))
                    // fieldInteractionRoot の原点=中央なので、その場回転がそのまま中央軸回転になる。
                    field.setOrientation(rot * startOrientation, relativeTo: nil)
                } else if fieldHandle(from: value.entity, kind: .scale) {
                    // サイズ調整: ドラッグ縦移動(上=拡大 / 下=縮小)でフィールドの一様スケールを変える。
                    let start: Float
                    if let s = fieldScaleDragStart {
                        start = s
                    } else {
                        start = field.scale(relativeTo: nil).x
                        fieldScaleDragStart = start
                    }
                    let factor = 1 + worldDelta.y * DuelDiskMetrics.fieldScaleDragSensitivity
                    let newScale = min(
                        DuelDiskMetrics.fieldScaleMax,
                        max(DuelDiskMetrics.fieldScaleMin, start * factor)
                    )
                    field.setScale(SIMD3<Float>(repeating: newScale), relativeTo: nil)
                }
            }
            .onEnded { _ in
                fieldDragStartPosition = nil
                fieldRotateStartAngle = nil
                fieldRotateStartOrientation = nil
                fieldRotateStartPosition = nil
                fieldRotateCenterWorld = nil
                fieldRotateHandleStartWorld = nil
                fieldHandleAreaDragStart = nil
                fieldScaleDragStart = nil
            }
    }

    /// 現在の視線(ヘッド)正面を基準に、召喚エリアを置き直す。
    /// アプリ起動時の空間の向きとデモ時の向きが違っても、ワンタップで正面に持ってこられる。
    func recenterFieldToView() {
        guard let field = fieldInteractionRoot, let head = menuHeadAnchor else { return }
        let headPos = head.position(relativeTo: nil)
        guard simd_length(headPos) > 0.05 else { return }  // ヘッド未トラッキング時は何もしない
        // ヘッドの前方(水平成分)。カメラは -Z を向く。
        let forward = head.orientation(relativeTo: nil).act(SIMD3<Float>(0, 0, -1))
        var forwardH = SIMD3<Float>(forward.x, 0, forward.z)
        guard simd_length(forwardH) > 0.0001 else { return }
        forwardH = simd_normalize(forwardH)
        // フィールド中心 = 視線正面の少し前。高さは今のフィールドの高さを維持(急な上下移動を避ける)。
        let currentY = field.position(relativeTo: nil).y
        let target = SIMD3<Float>(
            headPos.x + forwardH.x * DuelDiskMetrics.fieldRecenterDistance,
            currentY,
            headPos.z + forwardH.z * DuelDiskMetrics.fieldRecenterDistance
        )
        // フィールドの正面(+Z=プレイヤー側)がヘッドを向くヨー。
        let toHead = SIMD3<Float>(headPos.x - target.x, 0, headPos.z - target.z)
        let yaw = atan2(toHead.x, toHead.z)
        field.setPosition(target, relativeTo: nil)
        field.setOrientation(simd_quatf(angle: yaw, axis: SIMD3<Float>(0, 1, 0)), relativeTo: nil)
        DuelLog.event("FieldRecentered", "target=\(shortVector(target)) yawDeg=\(String(format: "%.0f", yaw * 180 / .pi))")
    }

    /// 指定 entity(またはその親)が指定種別のフィールド操作ハンドルかを判定する。
    func fieldHandle(from entity: Entity, kind: FieldHandleComponent.Kind) -> Bool {
        var node: Entity? = entity
        while let cur = node {
            if let handle = cur.components[FieldHandleComponent.self], handle.kind == kind {
                return true
            }
            node = cur.parent
        }
        return false
    }

    func updateDynamicRigTransforms() {
        logBoardOrientationIfNeeded()

        updateLeftFanPose()
        updateRightHandRig()
        // ハンドルは「エリア移動ハンドル」で好きな位置へ動かす方式(フィールドには自動追従しない=奥へ飛ばない)。
        // 位置は動かさず、向きだけ常にヘッド(Vision Pro)へ向けて文字/面が読めるようにする。
        updateFieldHandleBillboard()
    }

    /// 左手の扇手札の位置と姿勢を、ピンチ中点 + 手のひらの基底に追従させる。
    /// 実際に手札を持っている見え方になるよう、
    ///  - 扇ローカル +Y (カード上端方向) = 親指の向き (カードは親指と並行)
    ///  - 扇ローカル +Z (カード表面の法線) = 手のひらの向いている側 (親指側から面が見える)
    /// に合わせる。
    func updateLeftFanPose() {
        guard let fanRoot = leftPinchFanRoot,
              let midpoint = centroidOfTips(leftThumbTipAnchor, leftIndexTipAnchor, leftMiddleTipAnchor) else { return }

        let targetOrientation = leftFanBasisOrientation() ?? fanRoot.orientation(relativeTo: nil)
        // ハンドトラッキングのジッタを抑える: deadband(微小変化を無視)+ 強めのローパス。
        let smoothed = jitterSmoothedOrientation(
            current: fanRoot.orientation(relativeTo: nil),
            target: targetOrientation
        )
        // 扇ルート原点を指先(ピンチ中点)に置く。カード自体は fanTransform で +Y に
        // カード高さ半分ぶん持ち上がるので、カード下端がちょうど指先に来る。
        // 指にめり込まないよう手のひら法線側(+Z)へ少しだけ浮かせる。
        let localOffset = SIMD3<Float>(0, 0, DuelDiskMetrics.fanVerticalOffset)
        let targetPosition = midpoint + smoothed.act(localOffset)

        fanRoot.setOrientation(smoothed, relativeTo: nil)
        fanRoot.setPosition(
            jitterSmoothedPosition(current: fanRoot.position(relativeTo: nil), target: targetPosition),
            relativeTo: nil
        )
        updateRightHandToLeftFanProximityLog(leftFanPosition: targetPosition)
    }

    /// 左手の親指 + ナックル関節から扇の基底を作る。
    /// (指先はピンチ中に1点へ集まって基底が縮退するため、付け根関節を使う)
    /// - Returns: +Y=親指の向き (付け根→先端) / +Z=手のひらの向いている側 (親指軸と直交化) の回転。
    ///            未トラッキング時は nil。
    func leftFanBasisOrientation() -> simd_quatf? {
        guard let wristPos = trackedPosition(leftWristAnchor),
              let thumbKnucklePos = trackedPosition(leftThumbKnuckleAnchor),
              let thumbTipPos = trackedPosition(leftThumbTipAnchor),
              let indexKnucklePos = trackedPosition(leftIndexKnuckleAnchor),
              let littleKnucklePos = trackedPosition(leftLittleKnuckleAnchor) else { return nil }

        let thumbDir = thumbTipPos - thumbKnucklePos
        let fingersDir = (indexKnucklePos + littleKnucklePos) / 2 - wristPos
        let across = littleKnucklePos - indexKnucklePos
        guard simd_length(thumbDir) > 0.01,
              simd_length(fingersDir) > 0.01,
              simd_length(across) > 0.01 else { return nil }

        // 左手: (人差し指→小指) × (指方向) が手のひらの向いている側 (=親指の腹側) を向く。
        // 右手とは chirality により外積の順序が逆になる点に注意。
        let palmNormal = simd_cross(simd_normalize(across), simd_normalize(fingersDir))
        var yAxis = simd_normalize(thumbDir)
        // 親指軸と直交化した手のひら法線をカード面の法線にする
        let zRaw = palmNormal - simd_dot(palmNormal, yAxis) * yAxis
        guard simd_length(zRaw) > 0.001 else { return nil }
        let zAxis = simd_normalize(zRaw)
        let xAxis = simd_normalize(simd_cross(yAxis, zAxis))
        yAxis = simd_cross(zAxis, xAxis)
        return simd_quatf(simd_float3x3(columns: (xAxis, yAxis, zAxis)))
    }

    /// 右手リグの更新: ドロープローブ/保持カードを人差し指+中指に追従させ、
    /// デッキドロージェスチャーを判定する。
    func updateRightHandRig() {
        guard let indexPos = trackedPosition(rightIndexTipAnchor),
              let middlePos = trackedPosition(rightMiddleTipAnchor) else {
            isDeckDrawArmed = false
            rightHandCardEntity?.isEnabled = false
            return
        }
        let midpoint = (indexPos + middlePos) / 2
        rightDrawProbe?.setPosition(midpoint, relativeTo: nil)
        // 右手カードは「人差し指と中指がくっついている(=カードをつまんでいる)」ときだけ表示する。
        // 指が離れているのに表示され続けるのを防ぐため、判定を厳格化する。
        let fingersHolding = simd_distance(indexPos, middlePos) < DuelDiskMetrics.rightHandCardHoldThreshold
        rightHandCardEntity?.isEnabled = fingersHolding
        if let cardEntity = rightHandCardEntity, fingersHolding {
            // 向き: 指の腹側にカード面 / 指先方向にカード上端。
            // Entity ローカルでは attachment が X軸 +90° で差し込まれるため、その分を打ち消しておく。
            let targetOrientation: simd_quatf
            if let basis = rightFingersBasisOrientation() {
                targetOrientation = basis * simd_quatf(angle: -.pi / 2, axis: SIMD3<Float>(1, 0, 0))
            } else {
                targetOrientation = cardEntity.orientation(relativeTo: nil)
            }
            // deadband + 強めのローパスで手ブレを吸収する。
            let smoothed = jitterSmoothedOrientation(
                current: cardEntity.orientation(relativeTo: nil),
                target: targetOrientation
            )
            cardEntity.setOrientation(smoothed, relativeTo: nil)
            // 位置: 指先がカードの「下から1/3」の高さに来るよう、中心を上端方向へずらす
            let topDirection = smoothed.act(SIMD3<Float>(0, 0, 1))
            let targetPos = midpoint + topDirection * DuelDiskMetrics.rightHandCardCenterOffset
            cardEntity.setPosition(
                jitterSmoothedPosition(current: cardEntity.position(relativeTo: nil), target: targetPos),
                relativeTo: nil
            )
        }
        updateDeckDrawGesture(indexPos: indexPos, middlePos: middlePos, midpoint: midpoint)
        // カードをつまんでいる(表示中)ときだけ、置き場への重ね召喚を判定する。
        if fingersHolding {
            updateRightHandCardSummonOverlap()
        }
    }

    /// 右手に持っているカードがディスクの置き場/挿入口に重なったら設置(召喚)する。
    /// - モンスター: カード置き場(diskSlot)に重ねると召喚。
    /// - 魔法・トラップ: 挿入口(spellSlot)の空間に重ねると設置。
    /// 対象は「手札から選択して右手に持ち替えたカード」だけ。ドロー直後の未選択カードは、
    /// 置き場に意図せず重なっても配置しない(まず扇に取り込んで選択するのが正規フロー)。
    func updateRightHandCardSummonOverlap() {
        guard let card = sessionStore.rightHandCard,
              let cardEntity = rightHandCardEntity else { return }
        guard sessionStore.selectedHandCardId == card.id else { return }
        let cardPos = cardEntity.position(relativeTo: nil)

        if card.kind == .monster {
            for slot in diskSlotEntities {
                guard let index = slot.components[DiskSlotIndexComponent.self]?.index else { continue }
                if simd_distance(cardPos, slot.position(relativeTo: nil)) < DuelDiskMetrics.rightHandCardSummonRadius {
                    if sessionStore.summonRightHandCardToDiskSlot(index: index) {
                        DuelLog.event("RightHandCardSummoned", "slot=\(index)")
                    }
                    return
                }
            }
        } else if card.isSpellOrTrap {
            for plane in spellSlotHighlightEntities {
                guard let index = plane.components[SpellSlotIndexComponent.self]?.index else { continue }
                if simd_distance(cardPos, plane.position(relativeTo: nil)) < DuelDiskMetrics.rightHandCardSummonRadius {
                    if sessionStore.placeRightHandCardToSpellSlot(index: index) {
                        DuelLog.event("RightHandCardPlacedToSpellSlot", "slot=\(index)")
                    }
                    return
                }
            }
        }
    }

    /// 右手の指の基底から保持カードの目標姿勢を作る。
    /// - Returns: +Y=指先方向 (人差し指+中指) / +Z=指の腹側 (面が見える側) の回転。未トラッキング時は nil。
    func rightFingersBasisOrientation() -> simd_quatf? {
        guard let indexTipPos = trackedPosition(rightIndexTipAnchor),
              let middleTipPos = trackedPosition(rightMiddleTipAnchor),
              let indexKnucklePos = trackedPosition(rightIndexKnuckleAnchor),
              let littleKnucklePos = trackedPosition(rightLittleKnuckleAnchor) else { return nil }

        let tipsMid = (indexTipPos + middleTipPos) / 2
        let knucklesMid = (indexKnucklePos + littleKnucklePos) / 2
        let fingersDir = tipsMid - knucklesMid
        let across = littleKnucklePos - indexKnucklePos
        guard simd_length(fingersDir) > 0.01, simd_length(across) > 0.01 else { return nil }

        // 右手: (指方向) × (人差し指→小指) が指の腹の向いている側を向く。
        // 左手とは chirality により外積の順序が逆になる点に注意。
        let padNormal = simd_cross(simd_normalize(fingersDir), simd_normalize(across))
        var yAxis = simd_normalize(fingersDir)
        let zRaw = padNormal - simd_dot(padNormal, yAxis) * yAxis
        guard simd_length(zRaw) > 0.001 else { return nil }
        let zAxis = simd_normalize(zRaw)
        let xAxis = simd_normalize(simd_cross(yAxis, zAxis))
        yAxis = simd_cross(zAxis, xAxis)
        return simd_quatf(simd_float3x3(columns: (xAxis, yAxis, zAxis)))
    }

    /// 右手の指先(親指/人差し指/中指のいずれか)がディスクの「上」に伸びているか。
    /// タップ・配置のために右手をディスク上へ伸ばしている状況に限定して検知する
    /// (近くを通るだけでは凍結させない = 左手移動への追従を妨げない)。
    func isRightHandNearDisk(boardWorld: SIMD3<Float>) -> Bool {
        let tips = [rightIndexTipAnchor, rightMiddleTipAnchor, rightThumbTipAnchor]
        for tip in tips {
            guard let pos = trackedPosition(tip) else { continue }
            // ディスク面上方向(ローカル+Y)から見て、水平方向に近く、かつ面より上にあるか
            let dist = simd_distance(pos, boardWorld)
            let above = pos.y > boardWorld.y - 0.02
            if dist < DuelDiskMetrics.diskFollowFreezeRadius, above {
                return true
            }
        }
        return false
    }

    /// デッキドロー判定:
    ///  1. 右手の人差し指+中指がくっついた状態で、その中点がデッキの空間に交差 → armed
    ///  2. armed のまま「指が離れる」or「デッキ空間から出る」→ ドロー発火
    func updateDeckDrawGesture(indexPos: SIMD3<Float>, middlePos: SIMD3<Float>, midpoint: SIMD3<Float>) {
        let fingersTouching = simd_distance(indexPos, middlePos) < DuelDiskMetrics.drawFingerTouchThreshold
        let insideDeck = isPointInsideDeckVolume(midpoint)

        // 選択中カードの「右手への持ち替え」:
        // 手札カードを選択した状態で右手の人差し指+中指をくっつけた瞬間(立ち上がり)に、
        // デッキから引いたカードと同じように選択カードを右手に持たせる。
        // (デッキドローより優先。持ち替え後は右手カード追従 → カード置き場に重ねて召喚する)
        if !wasRightFingersTouching, fingersTouching,
           sessionStore.rightHandCard == nil,
           sessionStore.selectedHandCardId != nil {
            if sessionStore.moveSelectedCardToRightHand() {
                DuelLog.event("SelectedCardMovedToRightHand", "")
                wasRightFingersTouching = fingersTouching
                return
            }
        }
        wasRightFingersTouching = fingersTouching

        if isDeckDrawArmed {
            if !fingersTouching || !insideDeck {
                isDeckDrawArmed = false
                let trigger = fingersTouching ? "leftDeckVolume" : "fingersReleased"
                DuelLog.event("DeckDrawReleased", "trigger=\(trigger)")
                performDeckDraw(trigger: trigger)
            }
        } else if fingersTouching && insideDeck {
            guard sessionStore.rightHandCard == nil else { return }
            guard sessionStore.hand.count < DuelSessionStore.handCapacity else { return }
            isDeckDrawArmed = true
            DuelLog.event("DeckDrawArmed", "midpoint=\(shortVector(midpoint))")
        }
    }

    /// ワールド座標の点がデッキの直方体 (+プローブ半径のマージン) の内側にあるか。
    func isPointInsideDeckVolume(_ worldPoint: SIMD3<Float>) -> Bool {
        guard let deckEntity else { return false }
        let local = deckEntity.convert(position: worldPoint, from: nil)
        let margin = DuelDiskMetrics.drawProbeRadius
        return abs(local.x) <= DuelDiskMetrics.cardWidth / 2 + margin
            && abs(local.y) <= DuelDiskMetrics.deckHeight / 2 + margin
            && abs(local.z) <= DuelDiskMetrics.cardDepth / 2 + margin
    }

    /// 手ブレ抑制付きの位置追従。deadband 未満の微小変化は無視し、それ以上はローパスで滑らかに寄せる。
    func jitterSmoothedPosition(current: SIMD3<Float>, target: SIMD3<Float>) -> SIMD3<Float> {
        if simd_distance(current, target) < DuelDiskMetrics.handFollowPositionDeadband {
            return current
        }
        return mix(current, target, t: DuelDiskMetrics.handFollowPositionAlpha)
    }

    /// 手ブレ抑制付きの姿勢追従。deadband 未満の微小回転は無視する。
    func jitterSmoothedOrientation(current: simd_quatf, target: simd_quatf) -> simd_quatf {
        let rel = current.inverse * target
        let raw = rel.angle
        let ang = raw > .pi ? (2 * .pi - raw) : raw
        if ang < DuelDiskMetrics.handFollowRotationDeadband {
            return current
        }
        return simd_slerp(current, target, DuelDiskMetrics.handFollowRotationAlpha)
    }

    /// AnchorEntity のワールド位置を返す。未トラッキング (原点) のときは nil。
    func trackedPosition(_ anchor: AnchorEntity?) -> SIMD3<Float>? {
        guard let anchor else { return nil }
        let position = anchor.position(relativeTo: nil)
        guard position != .zero else { return nil }
        return position
    }

    /// 指定スロットで召喚エフェクトが再生中かどうか。
    /// 再生中は配置カードのタップ(=削除アラート)を抑止して、召喚直後の誤爆を防ぐ。
    func isDiskSummonEffectActive(forSlot slotIndex: Int) -> Bool {
        activeDiskSummonEffects.values.contains { $0.slotIndex == slotIndex }
    }

    func triggerDiskSummonEffect(slotIndex: Int, card: DuelCard) {
        let effect = DiskSummonEffectState(id: UUID(), slotIndex: slotIndex, card: card)
        activeDiskSummonEffects[effect.id] = effect
        DuelLog.event("DiskSummonEffectTriggered", "slot=\(slotIndex) effectId=\(effect.id.uuidString) cardId=\(card.id.uuidString)")
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: UInt64(DuelDiskMetrics.diskSummonEffectDuration * 1_000_000_000))
            activeDiskSummonEffects.removeValue(forKey: effect.id)
            DuelLog.event("DiskSummonEffectEnded", "slot=\(slotIndex) effectId=\(effect.id.uuidString)")
        }
    }


    func centroidOfTips(_ a: AnchorEntity?, _ b: AnchorEntity?, _ c: AnchorEntity?) -> SIMD3<Float>? {
        guard let a, let b, let c else { return nil }
        let pa = a.position(relativeTo: nil)
        let pb = b.position(relativeTo: nil)
        let pc = c.position(relativeTo: nil)
        let isTracked = pa != .zero || pb != .zero || pc != .zero
        guard isTracked else { return nil }
        return (pa + pb + pc) / 3
    }

    func performDeckDraw(trigger: String) {
        guard sessionStore.rightHandCard == nil else {
            DuelLog.state("DrawAttemptSkipped", "trigger=\(trigger) reason=alreadyHoldingCard")
            return
        }
        guard sessionStore.hand.count < DuelSessionStore.handCapacity else {
            DuelLog.state("DrawAttemptSkipped", "trigger=\(trigger) reason=handFull")
            return
        }

        DuelLog.event("DrawTriggered", "trigger=\(trigger) phase=\(String(describing: sessionStore.phase)) handCount=\(sessionStore.hand.count)")
        sessionStore.drawCard()
    }

    func updateRightHandToLeftFanProximityLog(leftFanPosition: SIMD3<Float>) {
        guard let rightHandCardEntity else {
            isRightHandNearLeftFan = false
            return
        }
        let rightHandPosition = rightHandCardEntity.position(relativeTo: nil)
        let distance = simd_distance(rightHandPosition, leftFanPosition)
        let isNear = distance < DuelDiskMetrics.handoffDistanceThreshold
        if isNear != isRightHandNearLeftFan {
            isRightHandNearLeftFan = isNear
            DuelLog.state("RightHandNearLeftFan", "isNear=\(isNear) distance=\(distance)")
            if isNear {
                attemptAddRightHandCardToFan(trigger: "leftFanProximity")
            }
        }
    }

    func attemptAddRightHandCardToFan(trigger: String) {
        guard sessionStore.isLeftPinching else {
            DuelLog.state("FanAbsorbSkipped", "trigger=\(trigger) reason=leftNotPinching")
            return
        }
        guard sessionStore.rightHandCard != nil else {
            DuelLog.state("FanAbsorbSkipped", "trigger=\(trigger) reason=noRightHandCard")
            return
        }
        guard isRightHandNearLeftFan || trigger == "palmCollision" else {
            DuelLog.state("FanAbsorbSkipped", "trigger=\(trigger) reason=notNearLeftFan")
            return
        }
        guard sessionStore.hand.count < DuelSessionStore.handCapacity else {
            DuelLog.state("FanAbsorbSkipped", "trigger=\(trigger) reason=handFull")
            return
        }

        if let fanRoot = leftPinchFanRoot {
            rightHandCardEntity?.setPosition(fanRoot.position(relativeTo: nil), relativeTo: nil)
        }
        DuelLog.event("FanAbsorbTriggered", "trigger=\(trigger) handCount=\(sessionStore.hand.count)")
        sessionStore.addRightHandCardToFan()
    }

    func logBoardOrientationIfNeeded() {
        let now = Date().timeIntervalSinceReferenceDate
        guard now - lastBoardOrientationLogTime >= 1.0 else { return }
        lastBoardOrientationLogTime = now
        logBoardOrientation(force: false)
    }

    func logBoardOrientation(force: Bool) {
        guard let boardEntity, let leftWristAnchor else { return }
        let boardMatrix = boardEntity.transformMatrix(relativeTo: nil)
        let wristMatrix = leftWristAnchor.transformMatrix(relativeTo: nil)
        let boardX = SIMD3<Float>(boardMatrix.columns.0.x, boardMatrix.columns.0.y, boardMatrix.columns.0.z)
        let boardY = SIMD3<Float>(boardMatrix.columns.1.x, boardMatrix.columns.1.y, boardMatrix.columns.1.z)
        let boardZ = SIMD3<Float>(boardMatrix.columns.2.x, boardMatrix.columns.2.y, boardMatrix.columns.2.z)
        let wristX = SIMD3<Float>(wristMatrix.columns.0.x, wristMatrix.columns.0.y, wristMatrix.columns.0.z)
        let wristY = SIMD3<Float>(wristMatrix.columns.1.x, wristMatrix.columns.1.y, wristMatrix.columns.1.z)
        let wristZ = SIMD3<Float>(wristMatrix.columns.2.x, wristMatrix.columns.2.y, wristMatrix.columns.2.z)
        let kind = force ? "BoardOrientationInitial" : "BoardOrientation"
        DuelLog.state(
            kind,
            "boardX=\(shortVector(boardX)) boardY=\(shortVector(boardY)) boardZ=\(shortVector(boardZ)) wristX=\(shortVector(wristX)) wristY=\(shortVector(wristY)) wristZ=\(shortVector(wristZ))"
        )
    }

    func shortVector(_ vector: SIMD3<Float>) -> String {
        String(format: "(%.2f,%.2f,%.2f)", vector.x, vector.y, vector.z)
    }

    func logCardVisualState(entity: Entity, context: String) {
        let attachmentChildren = entity.children.filter { $0.name == "CardAttachment" }
        let childNames = entity.children.map(\.name).joined(separator: ",")
        let scale = entity.scale(relativeTo: nil)
        var details = "children=\(entity.children.count) attachmentChildren=\(attachmentChildren.count) childNames=[\(childNames)] worldScale=\(shortVector(scale))"

        if let attachment = attachmentChildren.first {
            let bounds = attachment.visualBounds(relativeTo: nil)
            details += " attachmentBoundsExtents=\(shortVector(bounds.extents)) attachmentBoundsCenter=\(shortVector(bounds.center))"
        }

        DuelLog.state("CardVisualState", "context=\(context) \(details)")
    }
}

// MARK: - 手札扇 Entity 同期

private extension YugiohDuelDiskImmersiveView {
    func rebuildHandFan(cards: [DuelCard]) {
        guard let fanRoot = leftPinchFanRoot else { return }

        // 既存 Entity を全削除
        for (_, entity) in fanCardEntities {
            entity.removeFromParent()
        }
        fanCardEntities.removeAll()

        // 新規生成 + 扇レイアウト
        let total = cards.count

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
            // 視線を合わせたカードがはっきり分かるよう、強めの黄ハイライトにする。
            entity.components.set(DuelHoverStyle.handCard)

            entity.transform = fanTransform(
                total: total,
                index: i,
                lift: card.id == sessionStore.selectedHandCardId ? DuelDiskMetrics.selectedCardLift : 0
            )
            fanRoot.addChild(entity)
            fanCardEntities[card.id] = entity
            logCardVisualState(entity: entity, context: "HandFan[\(i)]")
        }
    }

    func applySelectedHighlight() {
        let orderedCards = sessionStore.hand
        let total = orderedCards.count

        for (index, card) in orderedCards.enumerated() {
            guard let entity = fanCardEntities[card.id] else { continue }
            let lift: Float = (card.id == sessionStore.selectedHandCardId)
                ? DuelDiskMetrics.selectedCardLift
                : 0
            entity.transform = fanTransform(total: total, index: index, lift: lift)
        }
    }

    func fanTransform(total: Int, index: Int, lift: Float) -> Transform {
        // 平面の扇(手で持つカード)。扇ルート原点(指先)を要(かなめ)にして、
        // カードは「扇の平面内」で下端を要に合わせて左右に開く。前後方向には広がらない。
        //
        // 扇ルート基底: +Y = カード上端方向(親指側) / +Z = カード面の法線(手のひら側=見える側)。
        //  - faceUserRotation: カード素材を「面が +Z を向き、上端が +Y」になる向きにする。
        //  - roll: 扇ルート +Z(=面の法線)まわりに回す → 面内で左右に開く。
        //    (roll を base の "後" に掛けるのがポイント。base の前に掛けると前後方向に開いてしまう)
        let perCard = DuelDiskMetrics.fanDegreesPerCard * .pi / 180
        let centeredIndex = Float(index) - Float(total - 1) / 2
        // index が増えるほど右へ開くように角度符号を取る。
        let angle = -centeredIndex * perCard

        let faceUserRotation = simd_quatf(angle: -.pi / 2, axis: SIMD3<Float>(1, 0, 0))
        let roll = simd_quatf(angle: angle, axis: SIMD3<Float>(0, 0, 1))
        let rotation = roll * faceUserRotation

        // カードの「上方向」= 扇平面内で roll した +Y(= (-sinθ, cosθ, 0))。z 成分は 0 なので前後に開かない。
        let up = roll.act(SIMD3<Float>(0, 1, 0))
        // 下端を要(指先原点)に合わせ、中心はカード高さの半分 + 選択時の持ち上げ量だけ先端側へ。
        let halfHeight = DuelDiskMetrics.cardDepth / 2
        // 重なりの前後を確定させる微小段差。全カード共通の「扇の法線(=見える側 +Z, 固定)」方向へ index 順にずらす。
        // (カードごとに回転した軸を使うと、裏から見た時に前後がバラつく=真ん中が手前に見える不具合になる)
        let position = up * (halfHeight + lift + DuelDiskMetrics.fanBottomGap)
            + SIMD3<Float>(0, 0, 1) * (Float(index) * DuelDiskMetrics.fanDepthStagger)

        return Transform(scale: .one, rotation: rotation, translation: position)
    }
}

// MARK: - 右手ドロー中カード Entity 同期

private extension YugiohDuelDiskImmersiveView {
    func syncRightHandCardEntity(card: DuelCard?) {
        // 既存を一旦消す
        rightHandCardEntity?.removeFromParent()
        rightHandCardEntity = nil

        guard let card = card else { return }
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
        entity.transform.rotation = simd_quatf(angle: -.pi / 2, axis: SIMD3<Float>(1, 0, 0))
        rootEntity.addChild(entity)
        rightHandCardEntity = entity
        // ドロー直後から人差し指+中指の間に保持されている見え方にする
        // (追従と表示可否は updateRightHandRig が毎 tick 更新する)
        if let indexPos = trackedPosition(rightIndexTipAnchor),
           let middlePos = trackedPosition(rightMiddleTipAnchor) {
            entity.setPosition((indexPos + middlePos) / 2, relativeTo: nil)
        } else {
            entity.isEnabled = false
        }
        logCardVisualState(entity: entity, context: "RightHand")
        DuelLog.event("RightHandCardEntityAttached", "cardId=\(card.id.uuidString)")
    }
}

// MARK: - ディスクスロット配置カード Entity 同期

private extension YugiohDuelDiskImmersiveView {
    func syncDiskSlotCardEntities(newSlots: [DuelCard?]) {
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
            // ゾーン面から board ローカル垂直方向へ 2cm 浮かせて「ディスクの上に載っている」見え方にする
            entity.transform.translation = slot.position + SIMD3<Float>(0, DuelDiskMetrics.diskPlacedCardLift, 0)
            // 翼の後退角 (±12°) を持つスロットに合わせて配置カードも回転させる
            entity.transform.rotation = slot.orientation * faceUpCardRotation(topDirection: SIMD3<Float>(0, 0, -1))
            // PlacedCardLocationComponent で「ディスクスロットの i 番目」と明示
            entity.components.set(PlacedCardLocationComponent(location: .diskSlot(i)))
            board.addChild(entity)
            placedDiskCardEntities[card.id] = entity
            triggerDiskSummonEffect(slotIndex: i, card: card)
            logCardVisualState(entity: entity, context: "DiskSlot[\(i)]")
            DuelLog.event("DiskCardPlacedEntityAttached", "slot=\(i) cardId=\(card.id.uuidString)")
            // fieldBackRow への同期は Store 層 (`placeSelectedCardToDiskSlot`) で実施済み。
        }
    }

    /// ディスクの魔法・トラップ挿入口(SpellSlot_i)の同期。
    /// 魔法・トラップはモンスターゾーンのようにディスク上へカードを立てて配置する必要はないため、
    /// ディスク側には何も描画しない(挿入されているかは SpellSlot への視線フォーカスで判別する)。
    /// 実際のカード表示はフィールド手前列(裏向き)が担う。
    func syncSpellSlotCardEntities(newSlots: [DuelCard?]) {
        // no-op (意図的にディスク上へは描画しない)
        _ = newSlots
    }
}

// MARK: - 召喚エリア(地面) Entity 同期 + sugiy 召喚

private extension YugiohDuelDiskImmersiveView {
    func syncFieldBackEntities(newSlots: [DuelCard?]) {
        guard let field = fieldInteractionRoot else { return }

        // 削除分: col 単位で field 子エンティティをクリーンアップ + Task をキャンセル
        for (col, entity) in fieldCardEntities {
            if newSlots.indices.contains(col) == false || newSlots[col] == nil {
                entity.removeFromParent()
                fieldCardEntities.removeValue(forKey: col)
                fieldMonsterEntities[col]?.removeFromParent()
                fieldMonsterEntities.removeValue(forKey: col)
                fieldSummonTasks[col]?.cancel()
                fieldSummonTasks.removeValue(forKey: col)
                fieldSummonEffects[col]?.stop()
                fieldSummonEffects.removeValue(forKey: col)
            }
        }

        // 追加分: 各 col で並列に Task 起動(直列 await による累積待ちを回避)
        for (col, optCard) in newSlots.enumerated() {
            guard let card = optCard else { continue }
            if fieldCardEntities[col] != nil { continue }
            // 旧 Task が残っていればキャンセル
            fieldSummonTasks[col]?.cancel()
            let task = Task { @MainActor in
                await summon(into: field, at: col, card: card)
            }
            fieldSummonTasks[col] = task
        }
    }

    /// フィールド手前列(魔法・トラップ)のカード Entity を同期する。
    /// モンスターと違い召喚エフェクト/モンスター出現は無く、カードを伏せる(置く)だけ。
    func syncFieldFrontEntities(newSlots: [DuelCard?]) {
        guard let field = fieldInteractionRoot else { return }

        // 削除分
        for (col, entity) in fieldFrontCardEntities {
            if newSlots.indices.contains(col) == false || newSlots[col] == nil {
                entity.removeFromParent()
                fieldFrontCardEntities.removeValue(forKey: col)
            }
        }

        // 追加分
        let pitchX = DuelDiskMetrics.fieldSlotWidth + DuelDiskMetrics.fieldGapX
        let totalCols = DuelDiskMetrics.diskSlotCount
        for (col, optCard) in newSlots.enumerated() {
            guard let card = optCard else { continue }
            if fieldFrontCardEntities[col] != nil { continue }
            let offsetX = (Float(col) - Float(totalCols - 1) / 2) * pitchX
            let position = SIMD3<Float>(
                offsetX,
                DuelDiskMetrics.fieldSurfaceHeight + 0.003,
                DuelDiskMetrics.fieldFrontZ - fieldLocalCenterOffsetZ
            )

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
            entity.transform.scale = SIMD3<Float>(repeating: DuelDiskMetrics.fieldCardScale)
            entity.transform.translation = position
            entity.transform.rotation = faceUpCardRotation(topDirection: SIMD3<Float>(0, 0, -1))
            entity.components.set(PlacedCardLocationComponent(location: .fieldFront(col)))
            field.addChild(entity)
            fieldFrontCardEntities[col] = entity
            DuelLog.event("FieldFrontCardSpawned", "col=\(col) cardId=\(card.id.uuidString)")
        }
    }

    func summon(into field: Entity, at col: Int, card: DuelCard) async {
        // デモ用: ディスクにカードを置いてからフィールドに出現するまで少し待つ。
        // 遅延が無いと配置と同時に召喚され、確認する間もなく出現を見逃すため。
        try? await Task.sleep(nanoseconds: UInt64(DuelDiskMetrics.fieldSummonDelay * 1_000_000_000))
        // 待機中にスロットが変更/削除されていたら中止
        guard sessionStore.fieldBackRow.indices.contains(col),
              sessionStore.fieldBackRow[col]?.id == card.id else { return }

        let pitchX = DuelDiskMetrics.fieldSlotWidth + DuelDiskMetrics.fieldGapX
        let totalCols = DuelDiskMetrics.diskSlotCount
        let offsetX = (Float(col) - Float(totalCols - 1) / 2) * pitchX
        let basePosition = SIMD3<Float>(
            offsetX,
            DuelDiskMetrics.fieldSurfaceHeight + 0.003,
            DuelDiskMetrics.fieldBackZ - fieldLocalCenterOffsetZ
        )

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
            repeating: DuelDiskMetrics.fieldCardScale
        )
        cardEntity.transform.translation = basePosition
        cardEntity.transform.rotation = faceUpCardRotation(topDirection: SIMD3<Float>(0, 0, -1))
        // タップ時に「アリーナ奥列 col 番目」と Component で確定識別できるようにする
        cardEntity.components.set(PlacedCardLocationComponent(location: .fieldBack(col)))
        field.addChild(cardEntity)
        fieldCardEntities[col] = cardEntity
        logCardVisualState(entity: cardEntity, context: "FieldBack[\(col)]")
        DuelLog.event("FieldCardSpawned", "col=\(col) cardId=\(card.id.uuidString) position=\(basePosition)")

        // 上昇アニメ
        var goal = cardEntity.transform
        goal.translation.y = basePosition.y + DuelDiskMetrics.cardRiseHeight
        cardEntity.move(
            to: goal,
            relativeTo: cardEntity.parent,
            duration: DuelDiskMetrics.cardRiseDuration,
            timingFunction: .easeOut
        )

        // 召喚エフェクト: 共通コントローラで放射バーストを発火する。
        // 同 col の旧エフェクトが残っていれば先に片付ける。
        fieldSummonEffects[col]?.stop()
        await spawnSummonBurst(into: field, at: col, position: SIMD3<Float>(
            basePosition.x,
            DuelDiskMetrics.fieldSurfaceHeight,
            basePosition.z
        ))

        // 1秒待ち(キャンセル耐性付き)
        do {
            try await Task.sleep(nanoseconds: UInt64(DuelDiskMetrics.monsterSpawnDelay * 1_000_000_000))
        } catch {
            return // キャンセルされた
        }

        // stale チェック: 待っている間に削除/再追加で col の Entity が変わっていたら中止
        guard fieldCardEntities[col] === cardEntity else { return }

        // モンスターカードに応じた 3D オブジェクト(たい焼き / 緋天竜)を出す
        let model: SummonModel = {
            if case .monster(let m) = card { return m.summonModel }
            return .taiyaki(.redBean)
        }()
        await spawnMonster(into: field, at: col, above: cardEntity, model: model)
    }

    /// 召喚モデルの種類に応じて 3D オブジェクトを出す。
    func spawnMonster(into field: Entity, at col: Int, above cardEntity: Entity, model: SummonModel) async {
        switch model {
        case .taiyaki(let flavor):
            await spawnTaiyaki(into: field, at: col, above: cardEntity, flavor: flavor)
        case .hitenryu:
            await spawnHitenryu(into: field, at: col, above: cardEntity)
        }
    }

    /// RCP(SummonEffectAssets)の放射バーストを読み込んで発火する。
    /// ループ emitter なので、一定時間発生させたあと発生停止 → 粒の寿命分待って取り外す
    /// (いきなり remove すると粒が瞬断するため)。
    func spawnSummonBurst(into field: Entity, at col: Int, position: SIMD3<Float>) async {
#if canImport(SummonEffectAssets)
        // 共通コントローラ SummonBurstController を使用(緋天竜と同一実装)。
        // フィールドは 3x スケールなので、素材は控えめに縮小して配置する。
        guard let burst = await SummonBurstController.make(
            scale: DuelDiskMetrics.summonBurstScale,
            intensity: DuelDiskMetrics.summonBurstIntensity
        ) else {
            DuelLog.warning("Failed to load summon burst")
            return
        }
        // 召喚断面(フィールド面)に置く → 下半分はオクルーダーで隠れて半球ドームになる
        burst.root.position = position
        field.addChild(burst.root)
        fieldSummonEffects[col] = burst
        burst.fire(emitDuration: DuelDiskMetrics.summonBurstEmitDuration)
        DuelLog.event("SummonEffectStarted", "col=\(col) position=\(shortVector(position))")
#endif
    }

    func spawnTaiyaki(into field: Entity, at col: Int, above cardEntity: Entity, flavor: TaiyakiFlavor) async {
#if canImport(Sugiy)
        do {
            // Sugiy.rkassets には Taiyaki.usdz が含まれ、具材4種(Filling_*)を内包する。
            // カードの種類に対応する具材だけを表示する。
            let monster = try await Entity(named: "Taiyaki", in: sugiyBundle)
            let fillingNames = ["Filling_RedBeans", "Filling_Custard", "Filling_Matcha", "Filling_Chocolate"]
            for name in fillingNames {
                monster.findEntity(named: name)?.isEnabled = (name == flavor.fillingNodeName)
            }
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
            // 「光の中から現れた」ように見せるため、最終位置より下から
            // フェードイン + 上昇で出現させる(上昇パーティクルのピークに紛れる)。
            container.transform.translation = cardEntity.transform.translation
                + SIMD3<Float>(0, 0.15 - DuelDiskMetrics.monsterRevealRise, 0)
            // デモ用にモンスターの正面はプレイヤー(こちら)側を向かせる(既定のまま=回転なし)。
            container.transform.rotation = simd_quatf(angle: 0, axis: SIMD3<Float>(0, 1, 0))
            container.components.set(OpacityComponent(opacity: 0))
            field.addChild(container)
            fieldMonsterEntities[col] = container
            DuelLog.event("MonsterSpawned", "col=\(col) entity=\(container.name)")

            var goal = container.transform
            goal.translation.y += DuelDiskMetrics.monsterRevealRise + DuelDiskMetrics.cardRiseHeight
            container.move(
                to: goal,
                relativeTo: container.parent,
                duration: DuelDiskMetrics.monsterRevealDuration,
                timingFunction: .easeOut
            )
            let fadeIn = FromToByAnimation<Float>(
                from: 0,
                to: 1,
                duration: DuelDiskMetrics.monsterRevealDuration,
                timing: .easeOut,
                bindTarget: .opacity
            )
            if let resource = try? AnimationResource.generate(with: fadeIn) {
                container.playAnimation(resource)
            } else {
                container.components.set(OpacityComponent(opacity: 1))
            }
        } catch {
            // モデルが読み込めなかった場合は何も出さない(ダミー表示はかえって混乱するため)。
            DuelLog.warning("Failed to load Taiyaki entity: \(error)")
        }
#endif
    }

    /// 緋天竜(アニメ付き USDZ)を召喚する。出現アニメ(上昇→とぐろ)を再生する。
    func spawnHitenryu(into field: Entity, at col: Int, above cardEntity: Entity) async {
#if canImport(Sugiy)
        do {
            let dragon = try await Entity(named: "Hitenryu", in: sugiyBundle)
            let bounds = dragon.visualBounds(relativeTo: nil)
            let maxExtent = max(bounds.extents.x, max(bounds.extents.y, bounds.extents.z))
            let targetMax: Float = 0.6
            if maxExtent > 0 {
                dragon.scale = SIMD3<Float>(repeating: targetMax / maxExtent)
            }
            // 足元(bounds 下端)を container 原点に合わせる(とぐろの底が召喚面に来る)
            dragon.position = SIMD3<Float>(
                -bounds.center.x * dragon.scale.x,
                -bounds.min.y * dragon.scale.y,
                -bounds.center.z * dragon.scale.z
            )

            let container = Entity()
            container.name = "Monster_col\(col)"
            container.addChild(dragon)
            container.transform.translation = cardEntity.transform.translation
                + SIMD3<Float>(0, 0.15 - DuelDiskMetrics.monsterRevealRise, 0)
            // デモ用にモンスターの正面はプレイヤー(こちら)側を向かせる(既定のまま=回転なし)。
            container.transform.rotation = simd_quatf(angle: 0, axis: SIMD3<Float>(0, 1, 0))
            container.components.set(OpacityComponent(opacity: 0))
            field.addChild(container)
            fieldMonsterEntities[col] = container
            DuelLog.event("HitenryuSpawned", "col=\(col)")

            // USDZ に焼き込まれた「出現(上昇→とぐろ)→ 揺れ(浮遊)」アニメを再生する。
            // 全体を1回再生 → 完了後に「揺れ区間」だけをトリムして無限ループ再生する。
            // (コードで上下を付けるのではなく、モデル本来の揺れアニメを使う)
            if let (holder, animation) = firstAvailableAnimation(in: dragon) {
                holder.playAnimation(animation, transitionDuration: 0)
                startHitenryuFloatLoop(holder: holder, fullAnimation: animation, container: container, col: col)
            }

            var goal = container.transform
            goal.translation.y += DuelDiskMetrics.monsterRevealRise + DuelDiskMetrics.cardRiseHeight
            container.move(
                to: goal,
                relativeTo: container.parent,
                duration: DuelDiskMetrics.monsterRevealDuration,
                timingFunction: .easeOut
            )
            let fadeIn = FromToByAnimation<Float>(
                from: 0, to: 1,
                duration: DuelDiskMetrics.monsterRevealDuration,
                timing: .easeOut, bindTarget: .opacity
            )
            if let resource = try? AnimationResource.generate(with: fadeIn) {
                container.playAnimation(resource)
            } else {
                container.components.set(OpacityComponent(opacity: 1))
            }
        } catch {
            DuelLog.warning("Failed to load Hitenryu entity: \(error)")
        }
#endif
    }

    /// 出現アニメ(全体)を1回再生し終えたら、USDZ に焼き込まれた「揺れ(浮遊)区間」だけを
    /// トリムして無限ループ再生する。コードで上下を付けず、モデル本来の揺れアニメを使う。
    /// (Blender タイムライン: 出現 = 先頭〜hitenryuFloatLoopStart、以降が完全周期の揺れ)
    func startHitenryuFloatLoop(holder: Entity, fullAnimation: AnimationResource, container: Entity, col: Int) {
        let duration = fullAnimation.definition.duration
        Task { @MainActor in
            // 出現アニメ全体を再生し終えるまで待つ。
            try? await Task.sleep(nanoseconds: UInt64(max(duration, 0.1) * 1_000_000_000))
            // 待機中に差し替え/削除されていたら何もしない。
            guard fieldMonsterEntities[col] === container else { return }
            // 揺れ区間だけをトリムしてループ。
            let trimmed = AnimationView(
                source: fullAnimation.definition,
                trimStart: DuelDiskMetrics.hitenryuFloatLoopStart
            )
            if let floatLoop = try? AnimationResource.generate(with: trimmed) {
                holder.playAnimation(floatLoop.repeat(), transitionDuration: 0.3)
                DuelLog.event("HitenryuFloatLoopStarted", "col=\(col) start=\(DuelDiskMetrics.hitenryuFloatLoopStart)")
            }
        }
    }

    /// availableAnimations を持つエンティティをツリーから探す。
    func firstAvailableAnimation(in entity: Entity) -> (Entity, AnimationResource)? {
        if let animation = entity.availableAnimations.first {
            return (entity, animation)
        }
        for child in entity.children {
            if let result = firstAvailableAnimation(in: child) {
                return result
            }
        }
        return nil
    }

    // NOTE: 削除時の Entity removeFromParent は `syncDiskSlotCardEntities` / `syncFieldBackEntities`
    // の onChange 経由でのみ行う(`onDelete` → Store のみ更新 → onChange で View 同期)。
    // View 層から直接 Entity を消す経路は廃止した(2 重実行の責務分散を解消するため)。
}

// MARK: - Attachment 位置更新

private extension YugiohDuelDiskImmersiveView {
    func updateAttachmentPlacement(_ attachments: RealityViewAttachments) {
        guard let menu = attachments.entity(for: AttachmentID.placedCardMenu) else { return }
        // メニューは頭アンカー配下の固定位置(視界正面)に置いてあるので、表示/非表示だけ切り替える。
        menu.isEnabled = (sessionStore.tappedPlacedCardContext != nil)
    }

    func anchorPosition(for ctx: PlacedCardContext) -> SIMD3<Float>? {
        switch ctx {
        case .diskSlot(let i):
            if let entity = sessionStore.diskSlots[safe: i].flatMap({ $0.flatMap { placedDiskCardEntities[$0.id] } }) {
                return entity.position(relativeTo: nil)
            }
        case .spellSlot(let i):
            if let entity = sessionStore.spellSlots[safe: i].flatMap({ $0.flatMap { placedSpellCardEntities[$0.id] } }) {
                return entity.position(relativeTo: nil)
            }
        case .fieldBack(let c):
            if let entity = fieldCardEntities[c] {
                return entity.position(relativeTo: nil)
            }
        case .fieldFront(let c):
            if let entity = fieldFrontCardEntities[c] {
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
    /// 子(anchor / board / deck / fieldRoot / attachment menu)を **手動で全部 removeFromParent**
    /// する必要がある。これを忘れると再入場時に二重生成する。
    func tearDown() {
        DuelLog.event("ImmersiveViewTearDown")
        duelAppModel.updateImmersiveSpaceState(.closed)

        // Polling Task
        pinchPollTask?.cancel()
        pinchPollTask = nil

        // 衝突購読
        collisionSubscriptions.forEach { $0.cancel() }
        collisionSubscriptions.removeAll()

        // 召喚 Task
        fieldSummonTasks.values.forEach { $0.cancel() }
        fieldSummonTasks.removeAll()

        // 召喚エフェクト(Entity 取り外し。粒が残留したまま再入場するのを防ぐ)
        fieldSummonEffects.values.forEach { $0.stop() }
        fieldSummonEffects.removeAll()

        // rootEntity 配下のすべての子(anchor / board / deck / fieldRoot / attachment menu 等)を取り外す。
        // Array コピーを取ってから iterate(removeFromParent で children が変動するため)。
        Array(rootEntity.children).forEach { $0.removeFromParent() }

        // Entity 辞書クリア
        fanCardEntities.removeAll()
        placedDiskCardEntities.removeAll()
        placedSpellCardEntities.removeAll()
        fieldFrontCardEntities.removeAll()
        diskSummonEffectEntities.removeAll()
        activeDiskSummonEffects.removeAll()
        fieldCardEntities.removeAll()
        fieldMonsterEntities.removeAll()
        rightHandCardEntity = nil

        // anchor / probe / fieldRoot の参照もクリア
        leftWristAnchor = nil
        diskPoseInitialized = false
        wristJumpHoldFrames = 0
        boardEntity = nil
        deckEntity = nil
        diskModelEntity = nil
        diskSlotEntities.removeAll()
        leftThumbTipAnchor = nil
        leftIndexTipAnchor = nil
        leftMiddleTipAnchor = nil
        leftIndexKnuckleAnchor = nil
        leftLittleKnuckleAnchor = nil
        leftThumbKnuckleAnchor = nil
        leftPalmAnchor = nil
        leftPinchFanRoot = nil
        rightThumbTipAnchor = nil
        rightIndexTipAnchor = nil
        rightMiddleTipAnchor = nil
        rightIndexKnuckleAnchor = nil
        rightLittleKnuckleAnchor = nil
        rightDrawProbe = nil
        rightIndexProbe = nil
        isDeckDrawArmed = false
        wasRightFingersTouching = false
        isRightHandNearLeftFan = false
        fieldRoot = nil
        fieldInteractionRoot = nil
        fieldMoveHandle = nil
        fieldRotateHandle = nil
        fieldScaleHandle = nil
        fieldRecenterHandle = nil
        fieldHandleArea = nil
        fieldAreaHandle = nil
        fieldHandleAreaDragStart = nil
        fieldScaleDragStart = nil
        fieldDragStartPosition = nil
        fieldRotateStartAngle = nil
        fieldRotateStartOrientation = nil
        fieldRotateStartPosition = nil
        fieldRotateCenterWorld = nil
        fieldRotateHandleStartWorld = nil

        // HandTrackingComponent もクリア(Entity 参照を保持し続けないように)
        leftHandComponent = nil
        rightHandComponent = nil

        // attachment フラグもリセット
        attachmentInstalled = false
        lifeDisplayInstalled = false
        menuHeadAnchor = nil
        spellSlotHighlightEntities.removeAll()

        // SpatialTrackingSession を停止
        Task { await spatialTrackingSession.stop() }
    }

    func summarizeSlots(_ slots: [DuelCard?]) -> String {
        let summary = slots.enumerated().map { index, card in
            "\(index):\(card == nil ? "-" : "X")"
        }.joined(separator: ",")
        return "slots=[\(summary)]"
    }
}

// MARK: - 補助

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

#if canImport(YugiohCardEffect)
private struct DiskSummonEffectView: View {
    let card: YugiohCardEffect.CardModel
    let animationID: UUID

    var body: some View {
        // カードは常にキャンバス中央(0.5, 0.5)。向きは 3D 側(holder)がスロット姿勢で回すので、
        // ここでは 2D 回転は 0。キャンバスは「カード周囲の局所エリア」のアスペクトに固定する。
        let areaW = CGFloat(DuelDiskMetrics.diskSummonEffectAreaWidth)
        let areaD = CGFloat(DuelDiskMetrics.diskSummonEffectAreaDepth)
        // 発生源(中央の空き=カード領域)は、実カード実寸 × hole倍。
        // エフェクト平面は配置カードより少し上にあるため、視差で線がカードに被るのを防ぐため
        // カードより一回り大きくして、線がカードの投影の外側から出るようにする。
        let hole = CGFloat(DuelDiskMetrics.diskSummonEffectCardHoleScale)
        let cardSize = CGSize(
            width: CGFloat(DuelDiskMetrics.diskSlotWidth) / areaW * hole,
            height: CGFloat(DuelDiskMetrics.diskSlotDepth) / areaD * hole
        )
        DuelDiskSummonLinesView(
            card: card,
            cardCenter: CGPoint(x: 0.5, y: 0.5),
            cardSize: cardSize,
            cardAngle: 0,
            animationID: animationID,
            // 実カードは別途表示されるため中央カードは出さない(二重表示防止)
            showsCard: false
        )
        .frame(width: areaW * 2000, height: areaD * 2000)
    }
}
#endif

/// ディスクのライフ表示(デジタル風の数字)。
private struct LifeDisplayView: View {
    let life: Int

    var body: some View {
        HStack(spacing: 6) {
            Text("LP")
                .font(.system(size: 34, weight: .heavy, design: .rounded))
                .foregroundStyle(Color(red: 0.7, green: 1.0, blue: 0.8).opacity(0.9))
            Text(String(format: "%04d", life))
                .font(.system(size: 70, weight: .black, design: .monospaced))
                .foregroundStyle(Color(red: 0.4, green: 1.0, blue: 0.5))
                .shadow(color: Color.green.opacity(0.9), radius: 8)
                .overlay {
                    // セグメント風の走査線
                    LinearGradient(
                        colors: [.white.opacity(0.0), .white.opacity(0.15), .white.opacity(0.0)],
                        startPoint: .top, endPoint: .bottom
                    )
                    .blendMode(.overlay)
                }
        }
        .padding(.horizontal, 26)
        .padding(.vertical, 14)
        // 黒い半透明の背景板は付けない(ディスク面に直接、数字だけが乗るように)。
        .fixedSize()
    }
}

#Preview(immersionStyle: .mixed) {
    YugiohDuelDiskImmersiveView()
}
#endif
