//
//  TitleSlide.swift
//  FlutterKaigi2026Slide
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct TitleSlide: View {
    /// スピーカーノート(発表者用の原稿。ノートWindowに表示される)
    var script: String {
        "ということで、「その不具合、どのWidgetですか？ ― アプリ内で“直せるバグ報告”を作る」というタイトルでLTします。"
    }

    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    private let title = "その不具合、どのWidgetですか？"
    private let subtitle = "― アプリ内で“直せるバグ報告”を作る"
    private let dateString = "2026/11/XX" // TODO: 発表日確定後に更新
    private let eventName = "FlutterKaigi 2026"
    private let authorName = "Sugiy/すぎー"

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 16) {
                Text(title)
                    .font(.system(size: 110, weight: .heavy))
                    .minimumScaleFactor(0.1)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(subtitle)
                    .font(.system(size: 76, weight: .heavy))
                    .minimumScaleFactor(0.1)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .foregroundStyle(.themeColor)
            Spacer()
                .frame(height: 28)
            VStack(alignment: .trailing, spacing: 32) {
                HStack(spacing: 20) {
                    Spacer()
                    Text(dateString)
                        .font(.system(size: 80, weight: .heavy))
                        .frame(alignment: .trailing)
                    Text(eventName)
                        .font(.system(size: 80, weight: .heavy))
                        .frame(alignment: .trailing)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.leading)
                HStack(alignment: .top, spacing: 20) {
                    Spacer()
                    Text(authorName)
                        .font(.system(size: 100, weight: .heavy))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    Image(.iconDynamic)
                        .resizable()
                        .frame(width: 160, height: 160)
                        .aspectRatio(contentMode: .fit)
                        .clipShape(Circle())
                }
            }
        }
        .frame(maxHeight: .infinity)
        .padding(80)
        .background(.slideBackgroundColor)
        .foregroundColor(.defaultForegroundColor)
    }

    var shouldHideIndex: Bool { true }
}

#Preview {
    SlidePreview {
        TitleSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}
