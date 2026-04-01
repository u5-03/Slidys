//
//  DynamicSlideView.swift
//  SlidysShareCore
//
//  Created by Claude on 2026/03/23.
//

import SwiftUI
import SlideKit

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
    let style: SlideStyle

    public init(pageData: SlidePageData?, style: SlideStyle = .default) {
        self.pageData = pageData
        self.style = style
    }

    public var body: some View {
        Group {
            if let pageData {
                switch pageData.type {
                case .centerText(let text):
                    Text(text)
                        .lineSpacing(24)
                        .font(.system(size: 100, weight: .bold))
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                case .titleList(let title, let items):
                    TitleListContentView(title: title, items: items, style: style, listBulletStyle: pageData.listBulletStyle)
                case .titleImage(let title, let imageData):
                    TitleImageContentView(title: title, imageData: imageData, style: style)
                case .centerImage(let imageData):
                    CenterImageContentView(imageData: imageData, style: style)
                case .code(let title, let code):
                    CodeContentView(title: title, code: code, style: style)
                }
            } else {
                Text("Loading...")
                    .font(.system(size: 100, weight: .bold))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .foregroundStyle(style.textColor.color)
        .tint(style.accentColor.color)
        .background(style.backgroundColor.color)
    }
}
