//
//  QuestionCircleWithInfoSlide.swift
//  Slidys
//
//  Created by Yugo Sugiyama on 2024/11/06.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct QuestionCircleWithInfoSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        HStack(spacing: 0) {
            HeaderSlide("どうしよう？") {
                Item("RowやColumnだけではむずかしそう", accessory: .number(1))
                Item("StackとPositionを使えば頑張って作ることはできそう", accessory: .number(2))
                Item("できそうだけど、かなり複雑になって、保守が大変そう", accessory: .number(3))
            }
            FlutterView(type: .circle)
                                .aspectRatio(contentMode: .fit)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.slideBackgroundColor)
        .foregroundColor(.defaultForegroundColor)
    }
}

#Preview {
    SlidePreview {
        QuestionCircleWithInfoSlide()
    }
}
