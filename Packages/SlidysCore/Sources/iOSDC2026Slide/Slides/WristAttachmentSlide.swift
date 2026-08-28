//
//  WristAttachmentSlide.swift
//  iOSDC2026Slide
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct WristAttachmentSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        HeaderSlide("ディスクを手首に「安定して」装着する") {
            Item("手首アンカーの子にすると、ロストの瞬間に消える・暴れる", accessory: .number(1))
            Item("→ 子にせず、毎フレーム手首の姿勢を「追いかける」。ロスト中は最後の姿勢で留まる", accessory: .number(2))
            Item("さらに毎フレーム35%だけ寄せる(ローパス)でブレを吸収", accessory: .number(3))
        }
    }
}

#Preview {
    SlidePreview {
        WristAttachmentSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}
