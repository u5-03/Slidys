//
//  ReferenceSlide.swift
//  Slidys
//
//  Created by Yugo Sugiyama on 2024/11/09.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct ReferenceSlide: View {
    var body: some View {
        HeaderSlide("Reference") {
            Item("【Flutter】TextをPathに追従させて動かす", accessory: .number(1)) {
                Item("https://zenn.dev/s134/articles/follow_path_text", accessory: .number(1))
            }
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
