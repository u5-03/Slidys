//
//  DiskSlotFactory.swift
//  YugiohDuelDiskPackage
//
//  ディスク上の召喚スロット(横並び5枚分の薄い plane)を作るファクトリ。
//

import Foundation
import RealityKit
#if canImport(UIKit)
import UIKit
#endif

public enum DiskSlotFactory {
    /// 1スロット分の Entity を作る。
    /// - 半透明青の plane で表示。
    /// - 識別用 Component (`DiskSlotIndexComponent`) を付ける。
    /// - `CollisionComponent` の filter は呼び出し側で設定する(group/mask 構成が View 層に集約されているため)。
    public static func makeSlot(index: Int) -> ModelEntity {
        let mesh = MeshResource.generatePlane(
            width: DuelDiskMetrics.diskSlotWidth,
            depth: DuelDiskMetrics.diskSlotDepth
        )
        var material = SimpleMaterial()
#if canImport(UIKit)
        material.color = .init(tint: UIColor.systemBlue.withAlphaComponent(0.4))
#endif
        material.metallic = 0.0
        material.roughness = 0.7
        let slot = ModelEntity(mesh: mesh, materials: [material])
        slot.name = "DiskSlot_\(index)" // デバッグ用
#if os(visionOS)
        slot.components.set(DiskSlotIndexComponent(index: index))
#endif
        return slot
    }

    /// 5スロットを横並びに配置した親Entity を返す。
    /// - 親は board 中心が原点になる前提。boardEntity の子として addChild する。
    public static func makeSlots() -> [ModelEntity] {
        let count = DuelDiskMetrics.diskSlotCount
        let pitch = DuelDiskMetrics.diskSlotWidth + DuelDiskMetrics.diskSlotGap
        return (0..<count).map { i in
            let slot = makeSlot(index: i)
            // 5枚並べる: -2,-1,0,+1,+2 を中央0に並べる
            let offsetX = (Float(i) - Float(count - 1) / 2) * pitch
            // ボード上面 (厚み 0.01m の半分 + 微小オフセット) + 奥行きの奥側
            slot.position = SIMD3<Float>(
                offsetX,
                DuelDiskMetrics.boardThickness / 2 + 0.001,
                -DuelDiskMetrics.boardDepth / 4
            )
            return slot
        }
    }
}
