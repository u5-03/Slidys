//
//  PanelDescriptionSlide.swift
//  SlidysCore
//
//  Created by Yugo Sugiyama on 2025/03/06.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct PanelDescriptionSlide: View {
    var body: some View {
        HeaderSlide("パネルディスカッション「隣の芝は青く見えるようで実は青くないかもしれない」とは？") {
            Item("普段他のプラットフォームの話を聞くと羨ましく感じることがあるかもしれません", accessory: .number(1)) {
                Item("e.g. FlutterのHot Reload", accessory: .number(1))
            }
            Item("しかしそれは隣の芝(プラットフォーム)が青く見えるだけで、中の人にとっては実は青くないかもしれません", accessory: .number(2))
            Item("各プラットフォームのパネラーが共通のテーマで、それぞれのプラットフォームの良いところや辛いところについてディスカッションします", accessory: .number(3))
            Item("参加者のコメントや質問も拾いながら進めていきます！", accessory: .number(4))
            Item("ChatGPTやCopilotなどのAI系ツールは、もちろんOK！", accessory: .number(5))
        }
    }
}

#Preview {
    SlidePreview {
        PanelDescriptionSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
