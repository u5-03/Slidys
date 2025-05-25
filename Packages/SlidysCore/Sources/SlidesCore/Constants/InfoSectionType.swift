//
//  InfoSection.swift
//
//
//  Created by Yugo Sugiyama on 2024/11/24.
//

import SwiftUI

public enum InfoSectionType: String, CaseIterable, Identifiable {
    case sampleViews
    case share
    case howToUse
    case slidys
    case symbolKit
    case japanRegionSwift
#if DEBUG
    case debugPage
#endif

    public var id: String {
        return rawValue
    }

    public var displayValue: String {
        switch self {
        case .sampleViews:
            return "Sample Views"
        case .share:
            return "Share Page"
        case .howToUse:
            return "How to use"
        case .slidys:
            return "Slidys"
        case .symbolKit:
            return "SymbolKit"
        case .japanRegionSwift:
            return "Japan-\\(region).swift"
#if DEBUG
        case .debugPage:
            return "Debug Page"
#endif
        }
    }

    @ViewBuilder
    public var view: some View {
        switch self {
        case .sampleViews:
            SamplePageView()
        case .share:
            ShareQrCodeView()
        case .howToUse:
            HowToUseSlide()
        case .slidys:
            WebPageView(url: URL(string: "https://github.com/u5-03/Slidys")!)
        case .symbolKit:
            WebPageView(url: URL(string: "https://github.com/u5-03/SymbolKit")!)
        case .japanRegionSwift:
            WebPageView(url: URL(string: "https://japan-region-swift.github.io/Japan-region-swift/")!)
#if DEBUG
        case .debugPage:
            DebugPageView()
#endif
        }
    }
}
