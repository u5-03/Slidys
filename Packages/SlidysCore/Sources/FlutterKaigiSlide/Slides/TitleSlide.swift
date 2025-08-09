//
//  TitleSlide.swift
//  Slidys
//
//  Created by Yugo Sugiyama on 2024/10/29.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct TitleSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    private let title1 = String(localized: "titlePianoCame", defaultValue: "CustomMultiChildLayoutを")
    private let title2 = String(localized: "titleDevelopedApp", defaultValue: "使って、あなたの思い描く自由な")
    private let title3 = String(localized: "titleDevelopedApp", defaultValue: "レイアウトを作ろう！")
    private let dateString = "2024/11/20"
    private let eventName = "FlutterKaigi 前夜祭LT"
    private let authorName = String(localized: "titleSugiy", defaultValue: "すぎー/Sugiy")
    private let authorIconAssetName = "icon"
    private let interval: TimeInterval = 0.2
    private let startDate = Date()

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                Text(title1)
                    .font(.system(size: 100, weight: .heavy))
                    .minimumScaleFactor(0.1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(title2)
                    .font(.system(size: 100, weight: .heavy))
                    .minimumScaleFactor(0.1)
                    .frame(maxWidth: .infinity, alignment: .center)
                Text(title3)
                    .font(.system(size: 100, weight: .heavy))
                    .minimumScaleFactor(0.1)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .foregroundStyle(.themeColor)
            Spacer()
                .frame(height: 20)
            VStack(alignment: .trailing, spacing: 20) {
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
                HStack(spacing: 20) {
                    Spacer()
                    Text(authorName)
                        .font(.system(size: 100, weight: .heavy))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    Image(authorIconAssetName)
                        .resizable()
                        .frame(width: 160, height: 160)
                        .aspectRatio(contentMode: .fit)
                        .clipShape(Circle())
                }
            }
        }
        .padding(80)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.slideBackgroundColor)
        .foregroundColor(.defaultForegroundColor)
    }

    var shouldHideIndex: Bool { true }
}

#Preview {
    SlidePreview {
        TitleSlide()
    }
}
