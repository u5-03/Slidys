//
//  Created by yugo.sugiyama on 2026/02/20
//  Copyright ©Sugiy All rights reserved.
//


import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct DemoAirPodsMotionSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        SplitContentSlide(leadingWidthRatio: 0.65) {
            HeaderSlide("デモ") {
                Item("AirPodsから取得したモーション情報に合わせて、RealityViewのプレビューが動く", accessory: .number(1))
                Item("X, Y, Z軸のスライダーで許容する姿勢の範囲を指定する", accessory: .number(2))
                Item("「開始」を押した位置を基準に計測を開始する", accessory: .number(3))
                Item("指定範囲を指定時間超えたら、指定した方法で警告する", accessory: .none) {
                       Item("Push通知", accessory: .number(1))
                       Item("音声", accessory: .number(2))
                       Item("Haptic Feedback", accessory: .number(3))
               }
            }
        } trailingContent: {
#if os(visionOS)
            Text("visionOSではデモができません")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
#else
            MonitoringView()
                .frame(maxHeight: .infinity)
                .background(.white)
#endif
        }
    }
}

#Preview {
    SlidePreview {
        DemoAirPodsMotionSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
