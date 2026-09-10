//
//  FieldSlotFactory.swift
//  YugiohDuelDiskPackage
//
//  目の前の召喚エリアの 5×2 スロット表示を作るファクトリ。
//  C3 確定: 半透明グレーの fill + 薄いグレー枠線。
//

import Foundation
import RealityKit
#if canImport(UIKit)
import UIKit
#endif

public enum FieldSlotFactory {
    /// 1スロットの Entity (fill plane + 枠線4辺)。
    public static func makeSlot(row: Int, col: Int) -> Entity {
        let container = Entity()
        container.name = "FieldSlot_r\(row)_c\(col)"

        let width = DuelDiskMetrics.fieldSlotWidth
        let depth = DuelDiskMetrics.fieldSlotDepth

        // fill: 半透明グレー
        let fillMesh = MeshResource.generatePlane(width: width, depth: depth)
        var fillMaterial = SimpleMaterial()
#if canImport(UIKit)
        fillMaterial.color = .init(tint: UIColor.gray.withAlphaComponent(0.15))
#endif
        let fill = ModelEntity(mesh: fillMesh, materials: [fillMaterial])
        container.addChild(fill)

        // 枠線: 4本の細い直方体
        let borderColor: SimpleMaterial = {
            var m = SimpleMaterial()
#if canImport(UIKit)
            m.color = .init(tint: UIColor.white.withAlphaComponent(0.5))
#endif
            return m
        }()
        let thickness: Float = 0.003
        let height: Float = 0.002

        // 前後の辺(X方向に伸びる)
        for zSign: Float in [-1, 1] {
            let edge = ModelEntity(
                mesh: .generateBox(width: width, height: height, depth: thickness),
                materials: [borderColor]
            )
            edge.position = SIMD3<Float>(0, 0, zSign * depth / 2)
            container.addChild(edge)
        }
        // 左右の辺(Z方向に伸びる)
        for xSign: Float in [-1, 1] {
            let edge = ModelEntity(
                mesh: .generateBox(width: thickness, height: height, depth: depth),
                materials: [borderColor]
            )
            edge.position = SIMD3<Float>(xSign * width / 2, 0, 0)
            container.addChild(edge)
        }

        return container
    }

    /// 召喚エリアの 5列 × 2行 のスロット位置 (アーケード床ベース)。
    /// - 戻り値の Entity は fieldRoot に addChild する。
    public static func makeField() -> Entity {
        let field = Entity()
        field.name = "FieldSlots"

        let count = DuelDiskMetrics.diskSlotCount
        let pitchX = DuelDiskMetrics.fieldSlotWidth + DuelDiskMetrics.fieldGapX
        let centerOffsetZ = (DuelDiskMetrics.fieldBackZ + DuelDiskMetrics.fieldFrontZ) / 2

        // 奥列 (row 0)
        for col in 0..<count {
            let slot = makeSlot(row: 0, col: col)
            let offsetX = (Float(col) - Float(count - 1) / 2) * pitchX
            slot.position = SIMD3<Float>(offsetX, DuelDiskMetrics.fieldSurfaceHeight, DuelDiskMetrics.fieldBackZ - centerOffsetZ)
            field.addChild(slot)
        }
        // 手前列 (row 1) は将来用だが先に枠だけ用意
        for col in 0..<count {
            let slot = makeSlot(row: 1, col: col)
            let offsetX = (Float(col) - Float(count - 1) / 2) * pitchX
            slot.position = SIMD3<Float>(offsetX, DuelDiskMetrics.fieldSurfaceHeight, DuelDiskMetrics.fieldFrontZ - centerOffsetZ)
            field.addChild(slot)
        }

        return field
    }
}
