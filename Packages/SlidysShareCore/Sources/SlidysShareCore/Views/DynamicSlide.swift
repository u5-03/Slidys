//
//  DynamicSlide.swift
//  SlidysShareCore
//
//  Created by Claude on 2026/03/23.
//

import SwiftUI
import SlideKit

@Slide
public struct DynamicSlide: View {
    let store: DynamicSlideStore
    let pageIndex: Int
    let style: SlideStyle

    public init(store: DynamicSlideStore, pageIndex: Int, style: SlideStyle = .default) {
        self.store = store
        self.pageIndex = pageIndex
        self.style = style
    }

    public var body: some View {
        DynamicSlideContentView(pageData: store.pages.indices.contains(pageIndex) ? store.pages[pageIndex] : nil, style: style)
    }
}
