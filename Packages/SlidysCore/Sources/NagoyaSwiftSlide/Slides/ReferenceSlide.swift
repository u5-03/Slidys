//
//  WrapUpSlide.swift
//  KanagawaSwiftSlide
//
//  Created by Yugo Sugiyama on 2024/09/09.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct ReferenceSlide: View {
    var body: some View {
        HeaderSlide("参考情報") {
            Item("http://www.expo2005.or.jp/jp/A0/A1/A1.10/index.html", accessory: .number(1))
        }
    }
}

#Preview {
    SlidePreview {
        ReferenceSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}

