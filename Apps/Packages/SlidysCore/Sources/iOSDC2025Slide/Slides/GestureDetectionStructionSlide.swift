//
//  Created by Yugo Sugiyama on 2024/09/09.
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct GestureDetectionStructionSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        HeaderSlide("今回行うハンドジェスチャー検出の概要") {
            Item("SpatialTrackingSessionを使用して、手のトラッキングシステムを初期化する", accessory: .number(1))
            Item("HandLocationで手の部位を指定し、その部位の位置や向きの情報を取得する", accessory: .number(2))
            Item("取得した部位の位置や向きから、指定したジェスチャーの条件に一致するかどうかを判定する", accessory: .number(3))
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
