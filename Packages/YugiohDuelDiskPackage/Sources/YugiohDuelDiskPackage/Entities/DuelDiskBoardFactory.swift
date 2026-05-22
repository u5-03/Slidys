//
//  DuelDiskBoardFactory.swift
//  YugiohDuelDiskPackage
//
//  腕に装着する仮の直方体「ディスクボード」を作るファクトリ。
//

import Foundation
import RealityKit
import simd
#if canImport(UIKit)
import UIKit
#endif

public enum DuelDiskBoardLayout {
    /// 手首 anchor 座標系での回転。
    /// 30cm の長辺(X) を腕方向に合わせるため、Z 軸まわりに -90° 回転して長辺を Y 軸方向にする。
    /// 実機での座標系が想定とズレた場合はここを調整する。
    public static let rotation: simd_quatf = simd_quatf(
        angle: -.pi / 2,
        axis: SIMD3<Float>(0, 0, 1)
    )

    /// 手首 anchor 座標系での平行移動。
    /// 手の甲側に少しだけずらして装着感を出す。
    public static let translation: SIMD3<Float> = SIMD3<Float>(0, 0, -0.005)
}

public enum DuelDiskBoardFactory {
    /// 厚さ 1cm × 幅 30cm × 奥行き 15cm の仮ディスクボード。
    public static func makeBoard() -> ModelEntity {
        let mesh = MeshResource.generateBox(
            width: DuelDiskMetrics.boardWidth,
            height: DuelDiskMetrics.boardThickness,
            depth: DuelDiskMetrics.boardDepth
        )
        var material = SimpleMaterial()
#if canImport(UIKit)
        material.color = .init(tint: UIColor(red: 0.85, green: 0.85, blue: 0.95, alpha: 1.0))
#endif
        material.metallic = 0.2
        material.roughness = 0.4
        let entity = ModelEntity(mesh: mesh, materials: [material])
        entity.name = "DuelDiskBoard"
        entity.transform.rotation = DuelDiskBoardLayout.rotation
        entity.transform.translation = DuelDiskBoardLayout.translation
        return entity
    }
}
