//
//  QuizTitleSlide.swift
//  KanagawaSwiftSlide
//
//  Created by Yugo Sugiyama on 2024/09/08.
//

import SwiftUI
import SlideKit

public enum RegionKind {
    case chiba
    case kanagawa
    case osaka
    case gifu
    case aichi

    public var displayName: String {
        switch self {
        case .chiba:
            return "千葉"
        case .kanagawa:
            return "神奈川"
        case .osaka:
            return "大阪"
        case .gifu:
            return "岐阜"
        case .aichi:
            return "愛知"
        }
    }

    public var imageResource: ImageResource {
        switch self {
        case .chiba:
            return .chiba
        case .kanagawa:
            return .kanagawa
        case .osaka:
            return .osaka
        case .gifu:
            return .gifu
        case .aichi:
            return .aichi
        }
    }
}

@Slide
public struct QuizTitleSlide: View {
    public let regionKind: RegionKind
    public let isAlmostSymbol: Bool

    public init(regionKind: RegionKind, isAlmostSymbol: Bool = false) {
        self.regionKind = regionKind
        self.isAlmostSymbol = isAlmostSymbol
    }

    public var body: some View {
        ZStack {
            Image(regionKind.imageResource)
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .foregroundStyle(Color(.lightGray))
                .offset(.init(width: 80, height: 0))
                .blur(radius: 8)
                .padding(20)
            Text("\(regionKind.displayName) シンボル\(isAlmostSymbol ? "?" : "")クイズ！")
                .font(.extraLargeFont)
                .shadow(radius: 30, x: 20, y: 20)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundStyle(.strokeColor)
        }
        .background(.slideBackgroundColor)
    }
}

#Preview {
    SlidePreview {
        QuizTitleSlide(regionKind: .kanagawa)
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
