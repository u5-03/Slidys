import Foundation
import HandGestureKit

/// 利用可能なジェスチャーのリスト
public struct AvailableGestures {
    /// すべての利用可能なジェスチャーインスタンス
    public static let allGestureInstances: [BaseGestureProtocol] = [
        // 片手ジェスチャー
        PeaceSignGesture(),
        ThumbsUpGesture(),
        PointingGesture(),
        // 両手ジェスチャー
        PrayerGesture(),
    ]

    /// すべての利用可能な手話ジェスチャーインスタンス
    public static let allSignLanguageInstances: [BaseGestureProtocol] = [
        // 手話ジェスチャー
        SignLanguageBGesture(),
        SignLanguageGGesture(),
        SignLanguageIGesture(),
        SignLanguageLGesture(),
        SignLanguageOGesture(),
        SignLanguageWGesture(),
        // シリアル手話ジェスチャー(初期位置→最終位置の移動で検出)
        SignLanguageArigatouGesture(),
    ]

    /// すべてのシリアルジェスチャーインスタンス
    public static let allSerialGestureInstances: [SerialGestureProtocol] = [
        SignLanguageArigatouGesture()
    ]

    /// デフォルトで有効なジェスチャーのIDセット(全てのジェスチャーをデフォルトで有効にする)
    public static let defaultEnabledGestureIds: Set<String> = {
        Set(allGestureInstances.map { $0.id })
    }()
}
