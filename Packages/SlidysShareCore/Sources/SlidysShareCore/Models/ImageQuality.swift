import Foundation
import CoreGraphics

public enum ImageQuality: String, Codable, CaseIterable, Sendable {
    case low
    case medium
    case high

    public var displayName: String {
        switch self {
        case .low: return "低画質（高速転送）"
        case .medium: return "中画質"
        case .high: return "高画質（低速転送）"
        }
    }

    public var maxBytes: Int {
        switch self {
        case .low: return 100_000      // 100KB
        case .medium: return 300_000   // 300KB
        case .high: return 500_000     // 500KB
        }
    }

    public var maxDimensionSteps: [CGFloat] {
        switch self {
        case .low: return [640, 320]
        case .medium: return [1280, 640, 320]
        case .high: return [1920, 1280, 640, 320]
        }
    }

    public var initialQuality: CGFloat {
        switch self {
        case .low: return 0.5
        case .medium: return 0.7
        case .high: return 0.8
        }
    }
}
