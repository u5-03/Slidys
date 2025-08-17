import Foundation
import simd

/// 手のひらの向きを表す列挙型
public enum PalmDirection: String, CaseIterable {
    case up
    case down
    case left
    case right
    case forward
    case backward
    case unknown

    /// 方向を表す単位ベクトル
    public var vector: SIMD3<Float> {
        switch self {
        case .up:
            return SIMD3<Float>(0, 1, 0)  // Y+
        case .down:
            return SIMD3<Float>(0, -1, 0) // Y-
        case .left:
            return SIMD3<Float>(-1, 0, 0) // X-
        case .right:
            return SIMD3<Float>(1, 0, 0)  // X+
        case .forward:
            return SIMD3<Float>(0, 0, -1) // Z-
        case .backward:
            return SIMD3<Float>(0, 0, 1)  // Z+
        case .unknown:
            return SIMD3<Float>(0, 0, 0)  // 不明
        }
    }

    /// 方向の説明文
    public var description: String {
        switch self {
        case .up:
            return "上"
        case .down:
            return "下"
        case .left:
            return "左"
        case .right:
            return "右"
        case .forward:
            return "前"
        case .backward:
            return "後ろ"
        case .unknown:
            return "不明"
        }
    }
}