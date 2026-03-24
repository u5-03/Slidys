//
//  CharactersSlide.swift
//  Slidys
//
//  Created by Yugo Sugiyama on 2024/11/06.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct CharactersSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        HeaderSlide("登場人物") {
            Item("MyCustomLayoutDelegate", accessory: .number(1)) {
                Item("CustomMultiChildLayoutのchildrenに渡すwidgetたちの制御条件を指定する", accessory: .number(1))
            }
            Item("performLayout", accessory: .number(2)) {
                Item("MyCustomLayoutDelegateのメソッドで具体的な条件を指定", accessory: .number(1))
                Item("layoutChildメソッドでサイズを指定し、positionChildメソッドで位置を指定する", accessory: .number(2))
            }
            Item("shouldRelayout", accessory: .number(3)) {
                Item("レイアウトの再計算を行うかを指定", accessory: .number(1))
            }
        }
    }
}

#Preview {
    SlidePreview {
        CharactersSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
