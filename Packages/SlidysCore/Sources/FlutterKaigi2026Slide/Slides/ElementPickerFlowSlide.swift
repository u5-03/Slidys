//
//  ElementPickerFlowSlide.swift
//  FlutterKaigi2026Slide
//
//  右に実機の Flutter 画面を埋め込み、話しながらその場で Widget をタップして選ぶ。
//  左はそこでできることの手順。
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct ElementPickerFlowSlide: View, ExternalDisplayMirroringPreferred {
    /// スピーカーノート。デモ中にページ送りはしないので、手順は最初から全部出しておく
    var script: String {
        """
        実際にやってみましょう。(右下の「要素を選ぶ」をタップ)選択モードに入ります。
        (カウンターのカードをタップ)タップした Widget が枠で囲まれて、identifier が出ます。
        (カード内の「カウント」ボタンをタップ)入れ子の場合は、一番小さい要素が選ばれます。
        (「この要素にする」をタップ)これで確定です。
        """
    }

    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        // デモ画面は右端に高さいっぱいで重ね、本文は左に寄せる(会場で見える大きさにする)
        HeaderSlide(loc: "タップした Widget が枠で囲まれる") {
            VStack(alignment: .leading, spacing: 40) {
                Item(loc: "「要素を選ぶ」で選択モードへ", accessory: .number(1))
                Item(loc: "報告したい Widget をタップ", keywords: ["タップ"], accessory: .number(2))
                Item(loc: "入れ子は一番小さい要素が選ばれる", keywords: ["一番小さい要素"], accessory: .number(3))
                Item(loc: "「この要素にする」で確定して起票画面へ反映", keywords: ["確定"], accessory: .number(4))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .demoPhoneOverlay {
            FlutterView(type: .elementPicker)
        }
    }
}

#Preview {
    SlidePreview {
        ElementPickerFlowSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}
