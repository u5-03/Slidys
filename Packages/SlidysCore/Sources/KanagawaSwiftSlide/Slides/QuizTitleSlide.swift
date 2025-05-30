//
//  QuizTitleSlide.swift
//  KanagawaSwiftSlide
//
//  Created by Yugo Sugiyama on 2024/09/08.
//

import SwiftUI
import SlideKit
import SlidesCore

enum RegionKind {
    case chiba
    case kanagawa

    var displayName: String {
        switch self {
        case .chiba:
            return "千葉"
        case .kanagawa:
            return "神奈川"
        }
    }

    var imageResource: ImageResource {
        switch self {
        case .chiba:
            return .chiba
        case .kanagawa:
            return .kanagawa
        }
    }
}

@Slide
struct QuizTitleSlide: View {
    let regionKind: RegionKind

    var body: some View {
        ZStack {
            Image(regionKind.imageResource)
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .foregroundStyle(Color(.lightGray))
                .offset(.init(width: 80, height: 0))
                .blur(radius: 8)
                .padding(20)
            Text("\(regionKind.displayName) シンボルクイズ！")
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
