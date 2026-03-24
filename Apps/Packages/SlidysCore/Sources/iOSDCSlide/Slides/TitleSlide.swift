//
//  TitleSlide.swift
//  iOSDC2024Slide
//
//  Created by Yugo Sugiyama on 2024/08/01.
//

import SwiftUI
import SlideKit
import PianoUI
import SlidesCore

@Slide
struct TitleSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    private let title1 = String(localized: "titlePianoCame", defaultValue: "我が家に電子ピアノがやってきたので、")
    private let title2 = String(localized: "titleDevelopedApp", defaultValue: "ピアノと連携するアプリを作ってみた！")
    private let dateString = "2024/08/24"
    private let eventName = "iOSDC2024 LT#1"
    private let authorName = String(localized: "titleSugiy", defaultValue: "すぎー/Sugiy")
    private let supporterName = String(localized: "titlePartner", defaultValue: "ピアノ技術監修: きょん(パートナー)")
    private let authorIconAssetName = "icon"
    private let supporterIconAssetName = "kyonIcon"
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
                HStack(spacing: 20) {
                    Spacer()
                    Text(supporterName)
                        .font(.system(size: 80, weight: .heavy))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    Image(supporterIconAssetName)
                        .resizable()
                        .frame(width: 160, height: 160)
                        .aspectRatio(contentMode: .fit)
                        .clipShape(Circle())
                }
            }
            TimelineView(.periodic(from: startDate, by: interval)) { context in
                let elapsed = context.date.timeIntervalSince(startDate)
                let index = Int(elapsed / interval) % KeyTemplate.openingKeyStrokes.count
                PianoView(pianoStrokes: KeyTemplate.openingKeyStrokes[index])
                    .shadow(radius: 100)
                    .clipShape(RoundedRectangle(cornerSize: .init(width: 20, height: 20)))
                    .padding()
            }
        }
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
