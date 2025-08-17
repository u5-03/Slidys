//
//  Created by Yugo Sugiyama on 2024/09/09.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct GestureDetectionStructionSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        HeaderSlide("今回行うジェスチャーの検出の仕組み") {
            Item("手の必要な関節の情報を整理する", accessory: .number(1)) {
                Item("RealityKitのHandSkeletonを利用", accessory: .number(1))
            }
            Item("関節の位置や向きなどの情報を取得できるようにする", accessory: .number(2)) {
                Item("RealityKitのSystemを利用", accessory: .number(1))
            }
            Item("関節の位置や向きから、ジェスチャーの条件に一致するかどうかを判定する", accessory: .number(3))
        }
    }
}

#Preview {
    SlidePreview {
        GestureDetectionStructionSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}

