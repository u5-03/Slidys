//
//  WrapUpSlide.swift
//  iOSDC2026Slide
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct WrapUpSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        HeaderSlide("まとめ") {
            Item("Blender製モデルは「ノード契約」を仕込むとRealityKitから扱いやすい(向きは座標系変換込みと疑う)", accessory: .number(1))
            Item("手首装着はAnchorEntity直付けではなく、ローパス追従でロストとジッタを吸収する", accessory: .number(2))
            Item("ジェスチャーは関節の特性(ピンチ中の縮退・左右の鏡像)を踏まえて設計する", accessory: .number(3))
            Item("エフェクトはブルームが無い前提で、加算ブレンド + タイミングの重ね方で説得力を出す", accessory: .number(4))
            Item("完全再現には制約も多いが、「いつかやってみたかった」は個人開発でも形にできる！", accessory: .number(5))
        }
    }
}

#Preview {
    SlidePreview {
        WrapUpSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
