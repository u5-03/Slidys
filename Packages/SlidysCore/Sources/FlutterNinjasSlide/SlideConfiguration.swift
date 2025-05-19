//
//  SlideConfiguration.swift
//  Slidys
//
//  Created by Yugo Sugiyama on 2024/10/27.
//

import Foundation
import SlideKit
import SwiftUI
import SlidesCore

public struct SlideConfiguration: SlideConfigurationProtocol {

    public let slideIndexController = SlideIndexController(index: 0) {
        CenterTextSlide(text: "FlutterNinjas2025")
        CenterTextSlide(text: "早速ですが質問です！")
        ContentSlide(headerTitle: "どうやって実装しますか？ Part1") {
            FlutterView(type: .icon)
        }
        ContentSlide(headerTitle: "どうやって実装しますか？ Part2") {
            HelloAnimationView()
        }
        ContentSlide(headerTitle: "どうやって実装しますか？ Part3") {
            FlutterView(type: .flightRouter)
        }
        CenterTextSlide(text: "Pathのアニメーションを使ってみよう！")
        TitleSlide()
        ReadmeSlide(
            title: "README",
            info: ReadmeInfo(
                name: "Sugiy",
                image: .icon,
                firstText: "Developing Flutter live streaming app, play-by-sports at DeNA",
                secondText: "I'm originally and currently iOS developer, but develop Flutter app for work",
                thirdText: "First time to speak and participate in FlutterNinjas!",
                fourthText: "Interested in 脱single-app対応",
                fifthText: "来月から私が買った注文住宅の工事が始まります"
            )
        )
        ImplementationStepSlide()
        CenterTextSlide(text: "詳細なソースコードについては、\n後ほどブログやGitHubで確認できます")
        ImplementationStep1Slide()
        SvgConverterDescriptionSlideswift()
        PathCodeScrollSlide()
        ImplementationStep2Slide()
        ImplementationStep3Slide()
        ImplementationStep4Slide()
        CenterTextSlide(text: "実装の方針はこんな感じ！")
        CenterTextSlide(text: "ここで実際にどのように動くかのデモと\nインターバルを兼ねてこんなことをしてみましょう")
        CenterTextSlide(text: "Japan Symbol Quiz")
        JapanRegionSwiftMapSlide()
        SymbolsGridSlide()
        ContentSlide(headerTitle: "Japan Symbol Quiz 1") {
            FlutterView(type: .symbolQuiz1)
        }
        ContentSlide(headerTitle: "折り紙") {
            Image(.origami)
                .resizable()
                .scaledToFit()
        }

        SymbolsGridSlide()
        ImplementationFixedLengthStepSlide()
        ImplementationFixedLengthCodeSlide()
        ContentSlide(headerTitle: "こんな感じに動きます！") {
            FlutterView(type: .waveFixedLength)
        }
        SymbolsGridSlide()
        TextAnimationSampleSlide()
        ImplementationTextPathStepSlide()
        CenterTextSlide(text: "では動作確認をしましょう！")
        ContentSlide(headerTitle: "Japan Symbol Quiz 2") {
            FlutterView(type: .symbolQuiz2)
        }
        CenterTextSlide(text: "これでSwiftで実装したことの\n確認は終わりました！")
        ContentSlide(headerTitle: "この実装について忘れてました！") {
            FlutterView(type: .flightRouter)
        }
        ImplementationTextPathStepSlide()
        ContentSlide(headerTitle: "こんなこともできる") {
            FlutterView(type: .iconMove)
        }
        ViewSlide {
            FlutterView(type: .moveTab)
        }
        WrapUpSlide()
        ReferenceSlide()
        CenterTextSlide(text: "Thank you for listening!")
    }

    public init() {}
}
