//
//  BlenderSampleView.swift
//  SlidysCore
//
//  Created by Yugo Sugiyama on 2026/05/17.
//

import SwiftUI
import RealityKit
import simd
import os
import Sugiy
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// 分析用に共通のプレフィックスを付けて出力するログヘルパー
/// Console.appやXcodeコンソールで "[Blender]" でフィルタすると関連ログだけ抽出できる
@inline(__always)
private func blog(_ message: @autoclosure () -> String) {
    print("[Blender] \(message())")
}

/// Blenderで作成しReality Composer Proに取り込んだモデルを`RealityView`でプレビューするサンプル
struct BlenderSampleView: View {
    /// 回転の中心となるpivot Entity(この子としてモデルを配置する)
    @State private var pivotEntity: Entity?
    /// 読み込んだモデル本体(scene)。pivotの子になっているはず
    @State private var sceneEntity: Entity?
    /// 現在のモデルの回転(ドラッグで更新する)
    @State private var modelRotation: simd_quatf = simd_quatf(ix: 0, iy: 0, iz: 0, r: 1)
    /// ドラッグ中の前回の移動量(差分計算用)
    @State private var lastDragTranslation: CGSize = .zero
    /// モデル読み込み失敗時のメッセージ
    @State private var loadErrorMessage: String?

    /// デバッグ: onChangedが呼ばれた回数
    @State private var debugDragCount = 0
    /// デバッグ: 直近でヒットしたエンティティ名
    @State private var debugHitEntity = "-"
    /// デバッグ: update呼び出し回数
    @State private var debugUpdateCount = 0

    /// 各surface(マテリアルスロット)に割り当てる色
    private let surfaceColors: [SimpleMaterial.Color] = [
        SimpleMaterial.Color(red: 0.20, green: 0.55, blue: 0.95, alpha: 1.0), // 青
        SimpleMaterial.Color(red: 0.95, green: 0.55, blue: 0.15, alpha: 1.0)  // オレンジ
    ]

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
            }

            // デバッグHUD / 操作説明(タッチは透過させる)
            VStack {
                HStack {
                    Text(debugText)
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundStyle(.green)
                        .padding(6)
                        .background(.black.opacity(0.6))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    Spacer()
                }
                Spacer()
                Text("モデルをドラッグして回転")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
                    .padding(.bottom, 48)
            }
            .padding()
            .allowsHitTesting(false)
        }
    }

    /// デバッグ表示テキスト
    private var debugText: String {
        let degrees = Int((modelRotation.angle * 180 / .pi).rounded())
        return """
        pivot   : \(pivotEntity == nil ? "nil" : "loaded")
        drags   : \(debugDragCount)
        updates : \(debugUpdateCount)
        angle   : \(degrees)°
        hit     : \(debugHitEntity)
        """
    }

    private var realityView: some View {
        RealityView { content in
            blog("make: start")

#if !os(visionOS)
            // visionOS以外では仮想カメラを用意してモデルを正面から映す
            content.camera = .virtual
            let camera = PerspectiveCamera()
            camera.position = SIMD3<Float>(0, 0, 1.2)
            content.add(camera)
            blog("make: virtual camera added at z=1.2")
#endif

            // ライトを追加してモデルが暗くならないようにする
            let keyLight = DirectionalLight()
            keyLight.light.intensity = 3000
            keyLight.look(at: .zero, from: SIMD3<Float>(1, 1, 1), relativeTo: nil)
            content.add(keyLight)

            let fillLight = DirectionalLight()
            fillLight.light.intensity = 1200
            fillLight.look(at: .zero, from: SIMD3<Float>(-1, -0.5, -1), relativeTo: nil)
            content.add(fillLight)

            do {
                // Sugiyパッケージのsugiy.usdcを読み込む
                let scene = try await Entity(named: "sugiy", in: sugiyBundle)
                blog("make: scene loaded name='\(scene.name)' id=\(ObjectIdentifier(scene)) childrenCount=\(scene.children.count)")
                logEntityTree(scene, depth: 0, label: "loaded")

                // Blenderエクスポートに含まれる Camera / Light / ReferenceImage / env_light を除去する。
                // 特にシーン内のCameraは content.camera = .virtual と競合し、回転しても
                // カメラごと一緒に回ってしまうため見た目が変わらない原因になり得る。
                pruneToMeshSubtrees(scene)
                logEntityTree(scene, depth: 0, label: "pruned")

                // 分割されたsurface(マテリアルスロット)ごとに別の色を割り当てる
                applyDistinctColors(to: scene)

                // 見やすいサイズに正規化する
                let rawBounds = scene.visualBounds(relativeTo: nil)
                blog("make: rawBounds center=\(rawBounds.center) extents=\(rawBounds.extents)")
                let maxExtent = max(rawBounds.extents.x, max(rawBounds.extents.y, rawBounds.extents.z))
                if maxExtent > 0 {
                    scene.scale = SIMD3<Float>(repeating: 0.6 / maxExtent)
                    blog("make: scaled by \(0.6 / maxExtent)")
                }

                let scaledBounds = scene.visualBounds(relativeTo: nil)
                scene.position = -scaledBounds.center
                blog("make: scaledBounds center=\(scaledBounds.center) extents=\(scaledBounds.extents) → scene.position=\(scene.position)")

                // ドラッグ対象にするため、衝突形状と入力ターゲットを付与する
                scene.generateCollisionShapes(recursive: true)
                scene.components.set(InputTargetComponent())
                removeHoverEffect(from: scene)
                blog("make: collision+input target installed; hover effect removed")

                // pivotの子に配置することで、モデルの中心を軸に回転できるようにする
                let pivot = Entity()
                pivot.name = "BlenderPivot"
                pivot.addChild(scene)
                pivotEntity = pivot
                sceneEntity = scene
                content.add(pivot)
                blog("make: pivot id=\(ObjectIdentifier(pivot)) childrenCount=\(pivot.children.count) sceneParent===pivot? \(scene.parent === pivot) pivotParent=\(String(describing: pivot.parent))")
            } catch {
                blog("make: ERROR loading model: \(error)")
                loadErrorMessage = "モデルの読み込みに失敗しました\n\(error.localizedDescription)"
            }
        } update: { _ in
            debugUpdateCount += 1
            // 多すぎるので最初の数回と10回ごとだけログ出す
            if debugUpdateCount <= 5 || debugUpdateCount % 10 == 0 {
                let pivotInfo: String
                if let p = pivotEntity {
                    pivotInfo = "id=\(ObjectIdentifier(p)) parent=\(p.parent.map{ "set:\(ObjectIdentifier($0))" } ?? "nil") children=\(p.children.count)"
                } else {
                    pivotInfo = "nil"
                }
                blog("update[#\(debugUpdateCount)]: pivot=\(pivotInfo) targetRot.angle=\(modelRotation.angle) targetRot.axis=\(modelRotation.axis)")
            }
            // ドラッグで更新された回転をモデルへ反映する
            pivotEntity?.transform.rotation = modelRotation
            if debugUpdateCount <= 5 || debugUpdateCount % 10 == 0 {
                if let p = pivotEntity {
                    blog("update[#\(debugUpdateCount)]: after-assign pivot.transform.rotation.angle=\(p.transform.rotation.angle) scene.transform.rotation.angle=\(sceneEntity?.transform.rotation.angle ?? -1) sceneParent===pivot? \(sceneEntity?.parent === p)")
                }
            }
        }
        // RealityKitのエンティティを対象にしたドラッグジェスチャー(iOS公式の方式)
        // MonitoringChartViewの実装を踏襲(world座標系でpre-multiply)。
        // Blender→USDで baked された90°回転の影響でデフォルトのままだと回転方向が逆に感じるため、
        // deltaX / deltaY の符号を反転して「ドラッグした方向にモデルが回る」感覚にする。
        .gesture(
            DragGesture()
                .targetedToAnyEntity()
                .onChanged { value in
                    debugDragCount += 1
                    debugHitEntity = value.entity.name.isEmpty ? "(noname)" : value.entity.name

                    // 前回イベントからの移動差分を回転量に変換する
                    let sensitivity: Float = 0.012
                    let deltaX = Float(value.translation.width - lastDragTranslation.width)
                    let deltaY = Float(value.translation.height - lastDragTranslation.height)
                    lastDragTranslation = value.translation

                    // 横ドラッグ → ワールドY軸まわりの回転(上下軸)
                    // 縦ドラッグ → ワールドX軸まわりの回転(左右軸)
                    // ドラッグ方向と同じ向きに回るよう符号を反転
                    let worldYRotation = simd_quatf(angle: -deltaX * sensitivity, axis: SIMD3<Float>(0, 1, 0))
                    let worldXRotation = simd_quatf(angle: -deltaY * sensitivity, axis: SIMD3<Float>(1, 0, 0))
                    let beforeAngle = modelRotation.angle
                    // 新しい回転 * 現在の回転(ワールド座標系で回転を追加)
                    modelRotation = worldYRotation * worldXRotation * modelRotation

                    // updateクロージャを待たず即座に反映する
                    let beforePivotAngle = pivotEntity?.transform.rotation.angle ?? -1
                    pivotEntity?.transform.rotation = modelRotation
                    let afterPivotAngle = pivotEntity?.transform.rotation.angle ?? -1

                    // 過剰ログを避けるため最初の数回 + 5回ごとに出す
                    if debugDragCount <= 5 || debugDragCount % 5 == 0 {
                        blog("""
                            drag[#\(debugDragCount)]: hit='\(value.entity.name)' \
                            translation=(\(Int(value.translation.width)),\(Int(value.translation.height))) \
                            delta=(\(deltaX),\(deltaY)) \
                            modelRot.angle: \(beforeAngle) → \(modelRotation.angle) \
                            pivot.rot.angle: \(beforePivotAngle) → \(afterPivotAngle) \
                            pivotEntity===\(pivotEntity.map{ "\(ObjectIdentifier($0))" } ?? "nil") \
                            sceneParent===pivot? \(sceneEntity?.parent === pivotEntity)
                            """)
                    }
                }
                .onEnded { _ in
                    blog("drag: ended (totalDrags=\(debugDragCount))")
                    lastDragTranslation = .zero
                }
        )
    }

    /// `ModelComponent`を子孫に持たないエンティティ(Camera/Light/参照画像など)を再帰的に取り除く。
    /// メッシュにつながるパスだけが残るようにする。
    private func pruneToMeshSubtrees(_ entity: Entity) {
        let children = Array(entity.children)
        for child in children {
            if subtreeContainsModel(child) {
                pruneToMeshSubtrees(child)
            } else {
                blog("prune: removing '\(child.name)' (no model in subtree)")
                child.removeFromParent()
            }
        }
    }

    /// エンティティとその子孫のいずれかが`ModelComponent`を持つかを判定する
    private func subtreeContainsModel(_ entity: Entity) -> Bool {
        if entity.components[ModelComponent.self] != nil { return true }
        for child in entity.children {
            if subtreeContainsModel(child) { return true }
        }
        return false
    }

    /// エンティティツリーからホバーエフェクトのコンポーネントを再帰的に取り除く
    private func removeHoverEffect(from entity: Entity) {
        entity.components.remove(HoverEffectComponent.self)
        for child in entity.children {
            removeHoverEffect(from: child)
        }
    }

    /// モデルが持つマテリアルスロットごとに、別々の色のマテリアルを割り当てる
    /// - Note: GeomSubsetでマテリアルスロットが2つあるため、両方に別の色が適用される
    private func applyDistinctColors(to entity: Entity) {
        var slotIndex = 0
        var modelComponentCount = 0

        func traverse(_ entity: Entity) {
            if var modelComponent = entity.components[ModelComponent.self] {
                modelComponentCount += 1
                let originalCount = modelComponent.materials.count
                let coloredMaterials: [any RealityKit.Material] = modelComponent.materials.map { _ in
                    let color = surfaceColors[slotIndex % surfaceColors.count]
                    slotIndex += 1
                    var material = SimpleMaterial()
                    material.color = .init(tint: color)
                    material.roughness = 0.4
                    material.metallic = 0.0
                    return material
                }
                if !coloredMaterials.isEmpty {
                    modelComponent.materials = coloredMaterials
                    entity.components.set(modelComponent)
                }
                blog("applyColors: entity='\(entity.name)' originalMaterials=\(originalCount) coloredMaterials=\(coloredMaterials.count)")
            }
            for child in entity.children {
                traverse(child)
            }
        }

        traverse(entity)
        blog("applyColors: done. modelComponentCount=\(modelComponentCount) totalSlots=\(slotIndex)")
    }

    /// エンティティツリー構造をログ出力する(深さ最大3まで)
    private func logEntityTree(_ entity: Entity, depth: Int, label: String) {
        let indent = String(repeating: "  ", count: depth)
        let hasModel = entity.components[ModelComponent.self] != nil
        let hasCollision = entity.components[CollisionComponent.self] != nil
        let hasInputTarget = entity.components[InputTargetComponent.self] != nil
        blog("tree[\(label)] \(indent)- '\(entity.name)' model=\(hasModel) collision=\(hasCollision) input=\(hasInputTarget) children=\(entity.children.count)")
        guard depth < 3 else { return }
        for child in entity.children {
            logEntityTree(child, depth: depth + 1, label: label)
        }
    }
}

#Preview {
    BlenderSampleView()
}
