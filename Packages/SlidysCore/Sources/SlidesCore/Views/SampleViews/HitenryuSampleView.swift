//
//  HitenryuSampleView.swift
//  SlidysCore
//
//  Created by Yugo Sugiyama on 2026/07/29.
//

import SwiftUI
import RealityKit
import simd
import Sugiy
import SummonEffectAssets
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// 分析用ログヘルパー。"[Hitenryu]" でフィルタすると関連ログだけ抽出できる
@inline(__always)
private func hlog(_ message: @autoclosure () -> String) {
    print("[Hitenryu] \(message())")
}

/// Blenderで自作した召喚モンスター「緋天竜」のアニメーション付きUSDZを確認するサンプル。
/// 出現シーケンス(垂直上昇→とぐろ形成→アイドル、150F/30fps)がSkelAnimationとして
/// 焼き込まれており、RealityKitで再生できるかの疎通検証を兼ねる。
struct HitenryuSampleView: View {
    /// 回転の中心となるpivot Entity
    @State private var pivotEntity: Entity?
    /// 読み込んだモデル本体
    @State private var sceneEntity: Entity?
    /// アニメーションの再生対象(SkelAnimationを保持しているエンティティ)
    @State private var animationEntity: Entity?
    /// USDZに焼かれた全編アニメーション(出現→なじませ→浮遊ループ1周)
    @State private var fullAnimation: AnimationResource?
    /// 再生完了イベントの購読(出現1回再生→浮遊ループへの切替に使う)
    @State private var playbackSubscription: EventSubscription?
    /// 出現アニメの開始時刻。playAnimationで再生を差し替えると旧アニメの
    /// PlaybackCompletedが即座に届くため、所要時間未満の完了通知を無視する
    @State private var emergenceStartedAt: Date?
    /// ドラッグによるモデル回転
    @State private var modelRotation: simd_quatf = simd_quatf(ix: 0, iy: 0, iz: 0, r: 1)
    @State private var lastDragTranslation: CGSize = .zero
    @State private var loadErrorMessage: String?
    @State private var statusText = "読み込み中..."
    /// 召喚時に発火する放射バースト(共通コントローラ SummonBurstController)
    @State private var summonBurst: SummonBurstController?
    /// バーストの発火世代。オクルーダーの遅延無効化が古い発火のものか判定する
    @State private var burstGeneration = 0

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if let loadErrorMessage {
                Text(loadErrorMessage)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding()
            } else {
                realityView
                    // 画面全体のドラッグで回転(コリジョン不要の非ターゲット方式)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let sensitivity: Float = 0.012
                                let deltaX = Float(value.translation.width - lastDragTranslation.width)
                                let deltaY = Float(value.translation.height - lastDragTranslation.height)
                                lastDragTranslation = value.translation
                                // 指の移動方向に正面が追従する向き(トラックボール式):
                                // 右ドラッグ→+Y軸回りに正回転で正面が右へ、下ドラッグ→+X軸回りに正回転で正面が下へ
                                let worldY = simd_quatf(angle: deltaX * sensitivity, axis: SIMD3<Float>(0, 1, 0))
                                let worldX = simd_quatf(angle: deltaY * sensitivity, axis: SIMD3<Float>(1, 0, 0))
                                modelRotation = worldY * worldX * modelRotation
                                pivotEntity?.transform.rotation = modelRotation
                            }
                            .onEnded { _ in
                                lastDragTranslation = .zero
                            }
                    )
            }

            VStack {
                HStack {
                    Text(statusText)
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundStyle(.green)
                        .padding(6)
                        .background(.black.opacity(0.6))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    Spacer()
                }
                Spacer()
                // 右下に配置: 中央下だとvisionOSのWindow操作バーと重なり、
                // ウィンドウの移動・クローズ操作をブロックしてしまう
                HStack(spacing: 16) {
                    Spacer()
                    Button {
                        replayAnimation()
                    } label: {
                        Label("最初から再生", systemImage: "arrow.counterclockwise")
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(.white.opacity(0.15))
                            .clipShape(Capsule())
                    }
                    .foregroundStyle(.white)
                }
                .padding(.bottom, 24)
                .padding(.trailing, 8)
            }
            .padding()
        }
    }

    private var realityView: some View {
        RealityView { content in
            hlog("make: start")
#if !os(visionOS)
            content.camera = .virtual
            let camera = PerspectiveCamera()
            camera.position = SIMD3<Float>(0, 0.05, 1.6)
            content.add(camera)
#endif
            let keyLight = DirectionalLight()
            keyLight.light.intensity = 3500
            keyLight.look(at: .zero, from: SIMD3<Float>(1, 1.2, 1.2), relativeTo: nil)
            content.add(keyLight)

            let fillLight = DirectionalLight()
            fillLight.light.intensity = 1200
            fillLight.look(at: .zero, from: SIMD3<Float>(-1, -0.3, -1), relativeTo: nil)
            content.add(fillLight)

            do {
                let scene = try await Entity(named: "Hitenryu", in: sugiyBundle)
                hlog("make: loaded '\(scene.name)' children=\(scene.children.count)")

                // 見やすいサイズに正規化(とぐろポーズ基準)
                let bounds = scene.visualBounds(relativeTo: nil)
                let maxExtent = max(bounds.extents.x, max(bounds.extents.y, bounds.extents.z))
                hlog("make: bounds center=\(bounds.center) extents=\(bounds.extents)")
                if maxExtent > 0 {
                    scene.scale = SIMD3<Float>(repeating: 0.62 / maxExtent)
                }
                let scaled = scene.visualBounds(relativeTo: nil)
                scene.position = -scaled.center

                // カード下の胴はアセット側でボーンスケール0に絞って消しているため、
                // オクルージョンは不要(巨大な箱はカメラを飲み込み「消えるバグ」の原因になる)

                // 召喚カードの平面(文脈用の薄いシアン発光)
                var cardMaterial = UnlitMaterial()
                cardMaterial.color = .init(tint: PlatformColor(
                    red: 0.2, green: 0.75, blue: 0.85, alpha: 0.35))
                let cardPlane = ModelEntity(
                    mesh: .generatePlane(width: 0.24, depth: 0.17),
                    materials: [cardMaterial]
                )
                cardPlane.name = "SummonCard"
                cardPlane.position = SIMD3<Float>(0, 0.001, 0)
                scene.addChild(cardPlane)

                let pivot = Entity()
                pivot.name = "HitenryuPivot"
                pivot.addChild(scene)
                content.add(pivot)
                pivotEntity = pivot
                sceneEntity = scene

                // 召喚バースト(放射線+手裏剣+中央発光)を「召喚断面=カード平面」に仕込む。
                // ルートをカード平面の位置に置くと、下半分がオクルーダーで隠れて
                // 「断面から出る半球ドーム」になる。竜の出現に合わせて発火する。
                if let burst = await SummonBurstController.make(scale: Self.burstScale) {
                    // カード平面(scene ローカル y≒0)の pivot 空間での位置に合わせる
                    burst.root.position = scene.convert(position: SIMD3<Float>(0, 0.001, 0), to: pivot)
                    pivot.addChild(burst.root)
                    summonBurst = burst
                    hlog("make: summon burst loaded at \(burst.root.position)")
                    fireBurst()
                }

                // スキンメッシュはバインドポーズ基準の境界でカリングされるため、
                // ドラッグで大きく回転させると視錐台外と誤判定されて消える。
                // 境界を大きく広げてカリングを事実上無効化する。
                expandCullingBounds(of: scene)

                // SkelAnimation を持つエンティティを探して再生(ルートに無ければ子を探索)
                if let (holder, animation) = findAnimation(in: scene) {
                    animationEntity = holder
                    fullAnimation = animation
                    let duration = animation.definition.duration
                    // 出現(上昇→とぐろ)を1回再生し、完了したら浮遊区間のみをループ。
                    // 再生の差し替え時にも完了イベントが届くため、開始からの経過が
                    // アニメ長に満たない「偽の完了」は無視する
                    playbackSubscription = content.subscribe(
                        to: AnimationEvents.PlaybackCompleted.self, on: holder
                    ) { _ in
                        if let start = emergenceStartedAt,
                           Date().timeIntervalSince(start) < duration - 0.5 {
                            hlog("ignored premature PlaybackCompleted")
                            return
                        }
                        startFloatLoop()
                    }
                    emergenceStartedAt = Date()
                    holder.playAnimation(animation, transitionDuration: 0)
                    statusText = "召喚シーケンス再生中"
                    hlog("make: playing emergence on '\(holder.name)' duration=\(duration)")
                } else {
                    statusText = "アニメーションが見つかりません"
                    hlog("make: no availableAnimations in tree")
                    logTree(scene, depth: 0)
                }
            } catch {
                hlog("make: ERROR \(error)")
                loadErrorMessage = "モデルの読み込みに失敗しました\n\(error.localizedDescription)"
            }
        } update: { _ in
            pivotEntity?.transform.rotation = modelRotation
        }
    }

    /// ツリー内の全ModelComponentのカリング境界を拡張する。
    /// スキンメッシュの境界はバインドポーズから計算されるため、アニメ変形や
    /// pivot回転と組み合わさると画面内でも視錐台カリングで消えることがある
    private func expandCullingBounds(of entity: Entity) {
        if var model = entity.components[ModelComponent.self] {
            model.boundsMargin = 10
            entity.components.set(model)
        }
        for child in entity.children {
            expandCullingBounds(of: child)
        }
    }

    /// availableAnimations を持つエンティティをツリーから探す
    private func findAnimation(in entity: Entity) -> (Entity, AnimationResource)? {
        if let animation = entity.availableAnimations.first {
            return (entity, animation)
        }
        for child in entity.children {
            if let result = findAnimation(in: child) {
                return result
            }
        }
        return nil
    }

    /// 浮遊ループの開始時刻(秒)。Blender側タイムライン 1..237F/30fps のうち、
    /// F=117 以降が「先頭と末尾が同ポーズの完全周期4秒」になるよう焼いてある。
    private static let floatLoopStart: TimeInterval = 116.0 / 30.0

    /// 出現完了後: 浮遊区間だけをトリムして無限ループ再生する
    private func startFloatLoop() {
        guard let animationEntity, let fullAnimation else { return }
        let trimmed = AnimationView(source: fullAnimation.definition,
                                    trimStart: Self.floatLoopStart)
        if let floatLoop = try? AnimationResource.generate(with: trimmed) {
            animationEntity.playAnimation(floatLoop.repeat(),
                                          transitionDuration: 0.2)
            statusText = "浮遊ループ中(4秒周期)"
            hlog("float loop started at \(Self.floatLoopStart)s")
        }
        // 召喚の終わりに合わせてキラキラも止める
        stopBurst()
    }

    private func replayAnimation() {
        guard let animationEntity, let fullAnimation else { return }
        // 召喚は正面向きで見せたいので向きをリセット。
        // 回転したままだとバーストの半球ドーム用オクルーダー(発火中3秒だけ有効)が
        // カメラ側に回り込み、召喚中モデルが隠れてしまうのも防ぐ
        modelRotation = simd_quatf(ix: 0, iy: 0, iz: 0, r: 1)
        pivotEntity?.transform.rotation = modelRotation
        // stopAllAnimations()は使わない: 一瞬バインドポーズ(素のポーズ)が
        // 表示されるうえ、完了イベントが飛んで浮遊ループへ誤遷移する。
        // playAnimationは再生中のアニメをそのまま差し替えられる
        emergenceStartedAt = Date()
        animationEntity.playAnimation(fullAnimation, transitionDuration: 0)
        statusText = "召喚シーケンス再生中(先頭から)"
        // 召喚バーストも再発火
        fireBurst()
    }

    /// バーストを初期状態から再生し、召喚シーケンスの間だけ発生させる。
    /// 発生は出現アニメの長さ(浮遊ループ開始まで)で自動停止し、
    /// 浮遊ループ開始時(startFloatLoop)にも明示的に止める(二重の保険)。
    /// 半球ドーム用オクルーダー(一辺3.6mのOcclusionMaterial箱)はpivot配下で
    /// 一緒に回転するため、常時有効だとドラッグで180°回すとカメラと竜の間に
    /// 入り「全部消える」。召喚中だけ有効にする(無効化は stopBurst 側)
    private func fireBurst() {
        guard let summonBurst else { return }
        burstGeneration += 1
        summonBurst.root.findEntity(named: "SummonBurstOccluder")?.isEnabled = true
        summonBurst.fire(emitDuration: Self.floatLoopStart)
    }

    /// 召喚完了時: バーストの発生を止め、残った粒がフェードした頃に
    /// オクルーダーも無効化してドラッグ回転を安全にする
    private func stopBurst() {
        guard let summonBurst else { return }
        summonBurst.setEmitting(false)
        burstGeneration += 1
        let generation = burstGeneration
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            if burstGeneration == generation {
                summonBurst.root.findEntity(named: "SummonBurstOccluder")?.isEnabled = false
                hlog("burst stopped and occluder disabled")
            }
        }
    }

    // MARK: - 召喚バースト(共通コントローラ)

    /// 竜のスケール(maxExtent→0.62)に合わせたバーストの拡大率。
    /// バースト素材は約1m基準なので、竜サイズに収まるよう縮小する。
    private static let burstScale: Float = 0.6

    private func logTree(_ entity: Entity, depth: Int) {
        let indent = String(repeating: "  ", count: depth)
        hlog("tree \(indent)- '\(entity.name)' anims=\(entity.availableAnimations.count) children=\(entity.children.count)")
        guard depth < 3 else { return }
        for child in entity.children {
            logTree(child, depth: depth + 1)
        }
    }
}

#Preview {
    HitenryuSampleView()
}
