//
//  TitleSlide.swift
//  ChibaSwiftSlide
//
//  Created by Yugo Sugiyama on 2024/09/08.
//

import SwiftUI
import SlideKit
import SlidysCore

@Slide
struct TitleSlide: View {
    private let title1 = String(localized: "titlePrefix", defaultValue: "iOSDCのスライドで使った")
    private let title2 = String(localized: "titleSuffix", defaultValue: "アニメーションを深掘る")
    private let dateString = "2024/09/20"
    private let eventName = "Chiba.swift #1 LT"
    private let authorName = String(localized: "titleSugiy", defaultValue: "すぎー/Sugiy")
    private let supporterName = String(localized: "titlePartner", defaultValue: "千葉監修・協力: きょん(パートナー)")
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
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .foregroundStyle(.themeColor)
            Spacer()
                .frame(height: 20)
            HStack(spacing: 0) {
                ZStack {
                    Image(.chibaPortTower)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 320)
                        .offset(.init(width: -100, height: -150))
                    Image(.peanuts)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 320)
                        .offset(.init(width: 0, height: 150))
                    Image(.rapeBlossoms)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 320)
                        .offset(.init(width: 200, height: -150))
                }
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
                        Image(.icon)
                            .resizable()
                            .frame(width: 160, height: 160)
                            .aspectRatio(contentMode: .fit)
                            .clipShape(Circle())
                    }
                    HStack(spacing: 20) {
                        Spacer()
                        Text(supporterName)
                            .font(.system(size: 80, weight: .heavy))
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        Image(.kyonIcon)
                            .resizable()
                            .frame(width: 160, height: 160)
                            .aspectRatio(contentMode: .fit)
                            .clipShape(Circle())
                    }
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
}
