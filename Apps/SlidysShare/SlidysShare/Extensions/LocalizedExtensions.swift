import Foundation
import SlidysShareCore

extension ImageQuality {
    var localizedDisplayName: String {
        switch self {
        case .low: String(localized: "低画質（高速転送）")
        case .medium: String(localized: "中画質")
        case .high: String(localized: "高画質（低速転送）")
        }
    }
}

extension ListBulletStyle {
    var localizedDisplayName: String {
        switch self {
        case .bullet: String(localized: "箇条書き")
        case .numbered: String(localized: "番号付き")
        }
    }
}

extension SlidePageData {
    var localizedDisplayTitle: String {
        switch type {
        case .centerText(let text): text
        case .titleList(let title, _): title
        case .titleImage(let title, _): title
        case .centerImage: String(localized: "画像")
        case .code(let title, _): title
        }
    }
}
