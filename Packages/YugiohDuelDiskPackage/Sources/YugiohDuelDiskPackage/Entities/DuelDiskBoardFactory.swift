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
    /// 30cm の長辺(X) を腕方向(Y) に、厚み(Y) を腕時計の文字盤法線(X) に合わせる。
    /// つまりディスク面(XZ)ではなく、ディスク面が手首座標系の YZ 面に来るようにする。
    /// 実機での座標系が想定とズレた場合はここを調整する。
    public static let rotation: simd_quatf = {
        simd_quatf(simd_float3x3(
            columns: (
                SIMD3<Float>(0, 1, 0),
                SIMD3<Float>(1, 0, 0),
                SIMD3<Float>(0, 0, 1)
            )
        ))
    }()

    /// 手首 anchor 座標系での平行移動。
    /// 手の甲側に少しだけずらして装着感を出す。
    public static let translation: SIMD3<Float> = SIMD3<Float>(0, 0.0, 0.008)

    /// 手首表面からディスクを浮かせる量 (ディスクのローカル上方向 +Y に沿って適用)。
    /// 手首関節の軸向きに依存しないよう、wrist 空間ではなく board 空間で合成する。
    public static let surfaceLift: Float = 0.03
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
