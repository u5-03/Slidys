//
//  WrapupSlide.swift
//  iOSDC2024Slide
//
//  Created by Yugo Sugiyama on 2024/08/09.
//

import SwiftUI
import SlideKit
import PianoUI
import SlidysCore

@Slide
struct WrapupSlide: View {
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            HeaderSlide("まとめ・感想") {
                Item("ピアノめっちゃむずかしい", accessory: .number(1)) {
                    Item("そもそもどこの鍵盤がどの音なのかがわからない", accessory: .number(1))
                    Item("ピアノ弾くと手と腕がめっちゃ疲れる", accessory: .number(2))
                }
                Item("ガジェットを使って遊ぶのは面白い", accessory: .number(2))
                Item("SwiftUIのアニメーションの表現力はすごい", accessory: .number(3)) {
                    Item("これはスライドを作った感想(笑)", accessory: .number(1))
                    Item("もっと色々試してみたい！", accessory: .number(2))
                }
            }
            ZStack(alignment: .center) {
                CircleMusicAnimatedNoteView(
                    radius: 280,
                    musicNoteSize: .init(width: 100, height: 100),
                    keyStrokes: KeyTemplate.openingKeyStrokes
                )
                GradientMusicStrokeAnimationView(lineWidth: 5, duration: 10, delay: 5)
                    .frame(width: 350, height: 350)
            }
            .offset(.init(width: -200, height: -200))
        }
    }
}

#Preview {
    SlidePreview {
        WrapupSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
