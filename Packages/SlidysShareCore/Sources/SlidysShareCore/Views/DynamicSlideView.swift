//
//  DynamicSlideView.swift
//  SlidysShareCore
//
//  Created by Claude on 2026/03/23.
//

import SwiftUI
import SlideKit
import SlidesCore

@Observable
public final class DynamicSlideStore {
    public var pages: [SlidePageData?]

    public init(pageCount: Int) {
        self.pages = Array(repeating: nil, count: pageCount)
    }

    public func update(page: SlidePageData, at index: Int) {
        guard index >= 0 && index < pages.count else { return }
        pages[index] = page
    }
}

public struct DynamicSlideContentView: View {
    let pageData: SlidePageData?

    public init(pageData: SlidePageData?) {
        self.pageData = pageData
    }

    public var body: some View {
        Group {
            if let pageData {
                switch pageData.type {
                case .centerText(let text):
                    Text(text)
                        .lineSpacing(24)
                        .font(.largeFont)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .foregroundStyle(.defaultForegroundColor)
                        .background(.slideBackgroundColor)
                case .titleList(let title, let items):
                    TitleListContentView(title: title, items: items)
                case .titleImage(let title, let imageData):
                    TitleImageContentView(title: title, imageData: imageData)
                case .centerImage(let imageData):
                    CenterImageContentView(imageData: imageData)
                case .code(let title, let code):
                    CodeContentView(title: title, code: code)
                }
            } else {
                Text("Loading...")
                    .font(.largeFont)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .foregroundStyle(.defaultForegroundColor)
                    .background(.slideBackgroundColor)
            }
        }
        .slideTheme(CustomSlideTheme(showSlideIndex: false))
    }
}
