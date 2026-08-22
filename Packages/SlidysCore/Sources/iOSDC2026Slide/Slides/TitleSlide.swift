//
//  TitleSlide.swift
//  iOSDC2026Slide
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct TitleSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    private let title = "「いつかやってみたかった」を形にする\n-アニメのカードバトルを再現するまで-"
    private let dateString = "2026/09/11" // TODO: 発表日確定後に更新
    private let eventName = "iOSDC Japan 2026"
    private let authorName = "Sugiy/すぎー"

    var body: some View {
        VStack(spacing: 0) {
            Text(title)
                .font(.system(size: 100, weight: .heavy))
                .minimumScaleFactor(0.1)
                .frame(maxWidth: .infinity, alignment: .leading)
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
                    Image(.icon)
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
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
