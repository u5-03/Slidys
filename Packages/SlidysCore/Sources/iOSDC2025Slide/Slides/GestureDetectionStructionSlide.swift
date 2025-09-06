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
            Item("手のトラッキングシステムを初期化する", accessory: .number(1)) {
                Item("ARKitSessionで権限リクエスト", accessory: .bullet)
                Item("SpatialTrackingSessionで .hand を有効化", accessory: .bullet)
            }
            Item("手の関節の位置や向きなどの情報を取得する", accessory: .number(2)) {
                Item("HandSkeletonの必要関節を選定", accessory: .bullet)
                Item("AnchorEntityで各関節をリアルタイム追跡", accessory: .bullet)
                Item("HandTrackingComponent で統合管理", accessory: .bullet)
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

