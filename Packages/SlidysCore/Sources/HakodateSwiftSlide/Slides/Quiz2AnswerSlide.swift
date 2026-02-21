//
//  Quiz2AnswerSlide.swift
//  HakodateSwiftSlide
//
//  Created by Yugo Sugiyama on 2024/09/08.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct Quiz2AnswerSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }
    @Phase var phase: SlidePhase
    
    enum SlidePhase: Int, PhasedState {
        case initial
        case second
    }

    var body: some View {
        HeaderSlide("全てのイヤホンのモーションデータは取得できない！") {
            Item("そもそもAirPods 1セット時の接続でも片方のイヤホン分のモーションのみ取得できる(1ストリームのみ)", accessory: .number(1)) {
                Item("CMDeviceMotionのsensorLocationで左右のどちらのイヤホンが取得かを判定できる", accessory: .number(1))
            }
            Item("ただしどちらのAirPodsが優先されるかのドキュメントは見当たらない(自分が探した範囲だと)", accessory: .number(2))
            Item("動作確認したところ、おそらく先に繋いでいたAirPodsが優先されていそう", accessory: .number(3))
            if phase.isAfter(.second) {
                Item("Appleに詳しい人、教えてください!笑", accessory: .number(4))
            }
        }
    }
}

#Preview {
    SlidePreview {
        Quiz2AnswerSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}

