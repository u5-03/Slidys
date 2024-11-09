//
//  ReferenceSlide.swift
//  Slidys
//
//  Created by Yugo Sugiyama on 2024/11/09.
//

import SwiftUI
import SlideKit
import SlidysCore

@Slide
struct ReferenceSlide: View {
    var body: some View {
        HeaderSlide("参考資料") {
            Item("CustomMultiChildLayout class", accessory: .number(1)) {
                Item("https://api.flutter.dev/flutter/widgets/CustomMultiChildLayout-class.html", accessory: .number(1))
            }
            Item("FlutterのCustomMultiChildLayoutとCustomSingleChildLayoutの使い方", accessory: .number(2)) {
                Item("https://zenn.dev/tmhk_tnht/articles/633b93fd685f7a", accessory: .number(1))
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
