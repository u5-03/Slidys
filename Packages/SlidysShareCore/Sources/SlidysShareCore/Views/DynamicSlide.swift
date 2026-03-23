//
//  DynamicSlide.swift
//  SlidysShareCore
//
//  Created by Claude on 2026/03/23.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
public struct DynamicSlide: View {
    let store: DynamicSlideStore
    let pageIndex: Int

    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    public init(store: DynamicSlideStore, pageIndex: Int) {
        self.store = store
        self.pageIndex = pageIndex
    }

    public var body: some View {
        DynamicSlideContentView(pageData: store.pages.indices.contains(pageIndex) ? store.pages[pageIndex] : nil)
    }
}
