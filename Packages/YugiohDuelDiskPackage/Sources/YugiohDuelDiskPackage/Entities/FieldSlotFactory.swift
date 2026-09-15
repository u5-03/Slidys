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
    /// スロットの配色。対戦モードでは相手陣を別の色味にして、自陣との境界を一目で分かるようにする。
    public enum Style: Sendable {
        /// 自陣(従来どおり: 半透明グレー + 白枠)
        case own
        /// 相手陣(赤みがかった fill + 淡い赤枠)
        case opponent
    }

    /// 1スロットの Entity (fill plane + 枠線4辺)。
    public static func makeSlot(row: Int, col: Int, style: Style = .own) -> Entity {
        let container = Entity()
        container.name = "FieldSlot_r\(row)_c\(col)"

        let width = DuelDiskMetrics.fieldSlotWidth
        let depth = DuelDiskMetrics.fieldSlotDepth

        // fill: 半透明(自陣=グレー / 相手陣=赤み)
        let fillMesh = MeshResource.generatePlane(width: width, depth: depth)
        var fillMaterial = SimpleMaterial()
#if canImport(UIKit)
        switch style {
        case .own:
            fillMaterial.color = .init(tint: UIColor.gray.withAlphaComponent(0.15))
        case .opponent:
            fillMaterial.color = .init(tint: UIColor(red: 1.0, green: 0.35, blue: 0.35, alpha: 0.16))
        }
#endif
        let fill = ModelEntity(mesh: fillMesh, materials: [fillMaterial])
        container.addChild(fill)

        // 枠線: 4本の細い直方体
        let borderColor: SimpleMaterial = {
            var m = SimpleMaterial()
#if canImport(UIKit)
            switch style {
            case .own:
                m.color = .init(tint: UIColor.white.withAlphaComponent(0.5))
            case .opponent:
                m.color = .init(tint: UIColor(red: 1.0, green: 0.55, blue: 0.55, alpha: 0.7))
            }
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
    public static func makeField(style: Style = .own) -> Entity {
        let field = Entity()
        field.name = "FieldSlots"

        let count = DuelDiskMetrics.diskSlotCount
        let pitchX = DuelDiskMetrics.fieldSlotWidth + DuelDiskMetrics.fieldGapX
        let centerOffsetZ = (DuelDiskMetrics.fieldBackZ + DuelDiskMetrics.fieldFrontZ) / 2

        // 奥列 (row 0)
        for col in 0..<count {
            let slot = makeSlot(row: 0, col: col, style: style)
            let offsetX = (Float(col) - Float(count - 1) / 2) * pitchX
            slot.position = SIMD3<Float>(offsetX, DuelDiskMetrics.fieldSurfaceHeight, DuelDiskMetrics.fieldBackZ - centerOffsetZ)
            field.addChild(slot)
        }
        // 手前列 (row 1) は将来用だが先に枠だけ用意
        for col in 0..<count {
            let slot = makeSlot(row: 1, col: col, style: style)
            let offsetX = (Float(col) - Float(count - 1) / 2) * pitchX
            slot.position = SIMD3<Float>(offsetX, DuelDiskMetrics.fieldSurfaceHeight, DuelDiskMetrics.fieldFrontZ - centerOffsetZ)
            field.addChild(slot)
        }

        return field
    }

    /// 対戦モードで自陣と相手陣の間に置く仕切りライン(センターライン)。
    /// フィールドの横幅いっぱいに伸びる、発光して見える帯 + 中央の細い明るい芯線。
    /// 位置(Z)は呼び出し側で決める(原点 = ラインの中心、Y = フィールド面の高さ基準)。
    public static func makeCenterDivider() -> Entity {
        let container = Entity()
        container.name = "FieldCenterDivider"

        let count: Float = Float(DuelDiskMetrics.diskSlotCount)
        let slotWidth: Float = DuelDiskMetrics.fieldSlotWidth
        let gapX: Float = DuelDiskMetrics.fieldGapX
        let slotsWidth: Float = count * slotWidth
        let gapsWidth: Float = (count - 1) * gapX
        let fieldWidth: Float = slotsWidth + gapsWidth
        // フィールドより少し長くして「台の境目」感を出す
        let width: Float = fieldWidth + slotWidth * 0.5
        let depth: Float = DuelDiskMetrics.fieldDividerDepth

        // 外側の帯: 半透明のシアン(Unlit なので照明に関係なく発光して見える)
        var bandMaterial = UnlitMaterial()
#if canImport(UIKit)
        bandMaterial.color = .init(tint: UIColor(red: 0.35, green: 0.85, blue: 1.0, alpha: 0.35))
#endif
        bandMaterial.blending = .transparent(opacity: 0.35)
        let band = ModelEntity(
            mesh: .generateBox(width: width, height: 0.003, depth: depth, cornerRadius: 0.0015),
            materials: [bandMaterial]
        )
        container.addChild(band)

        // 中央の芯線: 細く明るい
        var coreMaterial = UnlitMaterial()
#if canImport(UIKit)
        coreMaterial.color = .init(tint: UIColor(red: 0.8, green: 0.97, blue: 1.0, alpha: 0.9))
#endif
        coreMaterial.blending = .transparent(opacity: 0.9)
        let core = ModelEntity(
            mesh: .generateBox(width: width, height: 0.004, depth: depth * 0.18),
            materials: [coreMaterial]
        )
        core.position.y = 0.001
        container.addChild(core)

        return container
    }
}
