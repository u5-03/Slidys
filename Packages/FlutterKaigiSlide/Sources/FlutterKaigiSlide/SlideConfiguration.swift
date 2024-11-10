//
//  SlideConfiguration.swift
//  Slidys
//
//  Created by Yugo Sugiyama on 2024/10/27.
//

import Foundation
import SlideKit
import SwiftUI
import SlidysCore

public struct SlideConfiguration: SlideConfigurationProtocol {

    public let slideIndexController = SlideIndexController(index: 0) {
        CenterTextSlide(text: "みなさん")
        CenterTextSlide(text: "早速ですが質問です！")
        QuestionCircleSlide()
        QuestionCircleWithInfoSlide()
        CenterTextSlide(text: "各Widgetをいい感じに自由に\n配置できる方法はないかな？")
        TitleSlide()
        ReadmeSlide()
        DescriptionSlide()
        CharactersSlide()
        ShowDemoSlide()
        SplitContentSlide {
            Text("円環")
                .font(.largeFont)
                .foregroundStyle(.tint)
        } trailingContent: {
            FlutterView(type: .circle)
        }
        CodeSlide(title: "円環のUIの実装1", code: CodeConstants.circleCode1)
        CodeSlide(title: "円環のUIの実装2", code: CodeConstants.circleCode2, fontSize: 30)
        CodeSlide(title: "円環のUIの実装3", code: CodeConstants.circleCode3)
        SplitContentSlide(leadingWidthRatio: 0.4) {
            Text("ピアノのUI")
                .font(.largeFont)
                .foregroundStyle(.tint)
        } trailingContent: {
            FlutterView(type: .piano)
                .frame(height: 600)
        }
        TitleVideoSlide(
            title: "Vision Proで動くピアノのUIをSwiftUIで\n実装して、iOSDC2024で発表しました！",
            videoName: "opening_input",
            fileExtension: "mp4"
        )
        PianoSlide()
        LayoutComparisonSlide()
        SplitContentSlide(leadingWidthRatio: 0.6) {
            Text("Googleカレンダー風の\nタイムラインUI")
                .font(.mediumFont)
                .foregroundStyle(.tint)
        } trailingContent: {
            FlutterView(type: .calendar)
                .padding(.trailing, 60)
        }
        SplitContentSlide(leadingWidthRatio: 0.65) {
            VStack(alignment: .leading) {
                Text("ライブ配信アプリのUI")
                    .font(.largeFont)
                    .foregroundStyle(.tint)
                Text("play-by-sportsの配信・視聴画面")
                    .font(.mediumFont)
                    .foregroundStyle(.tint)
            }
        } trailingContent: {
            Image(.playBySports)
                .resizable()
                .scaledToFit()
                .padding(.horizontal, 20)
        }
        LiveDescriptionSlide()
        SplitContentSlide(leadingWidthRatio: 0.6) {
            Text("円環(アニメーション)")
                .font(.largeFont)
                .foregroundStyle(.tint)
        } trailingContent: {
            FlutterView(type: .circleAnimation)
        }
        CircleAnimationDescriptionSlide()
        WrapUpSlide()
        ReferenceSlide()
        CenterTextSlide(text: "おしまい")
    }

    public init() {}
}
