//
//  Quiz1AnswerSlide.swift
//  HakodateSwiftSlide
//
//  Created by Yugo Sugiyama on 2024/09/08.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct Quiz1AnswerSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        HeaderSlide("繋がる！") {
            Item("この状態でもBluetoothでイヤホンと接続ができている", accessory: .number(1))
            Item("あくまで音声再生のデバイスとして有効になっていないだけ", accessory: .number(2))
            Item("そのためモーション情報の取得はできる", accessory: .number(3))
        }
    }
}

#Preview {
    SlidePreview {
        Quiz1AnswerSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}

