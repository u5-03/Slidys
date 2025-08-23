import Foundation

/// 指の種類を表す列挙型
public enum FingerType: CaseIterable {
    case thumb  // 親指
    case index  // 人差し指
    case middle  // 中指
    case ring  // 薬指
    case little  // 小指

    /// 指の名前(日本語)
    public var description: String {
        switch self {
        case .thumb:
            return "親指"
        case .index:
            return "人差し"
        case .middle:
            return "中"
        case .ring:
            return "薬"
        case .little:
            return "小"
        }
    }

    /// 指の短縮名(距離表示用)
    public var shortDescription: String {
        switch self {
        case .thumb:
            return "親"
        case .index:
            return "人"
        case .middle:
            return "中"
        case .ring:
            return "薬"
        case .little:
            return "小"
        }
    }
}
