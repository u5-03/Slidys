//
//  FlutterEmbedSlide.swift
//  FlutterKaigi2026Slide
//
//  左に説明、右にスマホ枠で Flutter の実機画面を埋め込むスライド(「デモ」と銘打たず、話しながら動かす)。
//  デモ画面はホストアプリ(SlidysFlutter)の Router 経由で FlutterViewController として表示される。
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct FlutterEmbedSlide: View {
    let title: String
    let points: [String]
    let type: FlutterKaigi2026ViewType
    /// スピーカーノート(発表者用の原稿。ノートWindowに表示される)
    var script: String = ""

    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        HeaderSlide(.init(stringLiteral: title)) {
            HStack(alignment: .top, spacing: 60) {
                VStack(alignment: .leading, spacing: 44) {
                    ForEach(Array(points.enumerated()), id: \.offset) { index, point in
                        Item(.init(stringLiteral: point), accessory: .number(index + 1))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                PhoneFrameView {
                    FlutterView(type: type)
                }
                .frame(maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    SlidePreview {
        FlutterEmbedSlide(
            title: "Flutterで作ってみた",
            points: ["フローティングボタンをタップ", "要素をタップして選ぶ", "Issueができあがる"],
            type: .feedbackDemo
        )
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}
