//
//  AnimationStructureSlide.swift
//  HakodateSwiftSlide
//
//  Created by Yugo Sugiyama on 2024/09/08.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct HeadMotionIntroductionSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        HeaderSlide("実はAirPodsはモーション情報を取得できる(一部機種)") {
            Item("姿勢・回転速度・加速度などが取得できる", accessory: .number(1))
            Item("主に空間オーディオに対応するために存在？", accessory: .number(2)) {
                Item("AirPodsの設定画面には「頭のジェスチャー」という設定項目もある", accessory: .number(1))
            }
            Item("iOS14~から利用できる", accessory: .number(3)) {
                Item("macOSはmacOS 14(Sonoma)から追加された", accessory: .number(1))
            }
        }
    }
}

#Preview {
    SlidePreview {
        HeadMotionIntroductionSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}

