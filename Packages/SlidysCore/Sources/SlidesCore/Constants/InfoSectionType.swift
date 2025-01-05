//
//  InfoSection.swift
//
//
//  Created by Yugo Sugiyama on 2024/11/24.
//

import SwiftUI

public enum InfoSectionType: String, CaseIterable, Identifiable {
    case share
    case howToUse
#if DEBUG
    case debugPage
#endif

    public var id: String {
        return rawValue
    }

    public var displayValue: String {
        switch self {
        case .share:
            return "Share Page"
        case .howToUse:
            return "How to use"
#if DEBUG
        case .debugPage:
            return "Debug Page"
#endif
        }
    }

    @ViewBuilder
    public var view: some View {
        switch self {
        case .share:
            ShareQrCodeView()
        case .howToUse:
            HowToUseSlide()
#if DEBUG
        case .debugPage:
            DebugPageView()
#endif
        }
    }
}
