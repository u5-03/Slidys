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

    @MainActor
    public let slideIndexController = SlideIndexController(index: 0) {
        CenterTextSlide(text: "FlutterNinjas2025 LightingTalk!")
        CenterTextSlide(text: "Let me ask you a question!")
        ContentSlide(headerTitle: "How would you implement this? Part1") {
            FlutterView(type: .icon)
        }
        ContentSlide(headerTitle: "How would you implement this? Part2") {
            FlutterView(type: .flightRouter)
        }
        CenterTextSlide(text: "Let's use path animation!")
        TitleSlide()
        ReadmeSlide(
            title: "README",
            info: ReadmeInfo(
                name: "Sugiy",
                image: .icon,
                firstText: "Developing Flutter live streaming app, play-by-sports at DeNA",
                secondText: "Originally iOS developer, but develop Flutter app for work",
                thirdText: "First time to speak and participate in FlutterNinjas!",
                fourthText: "Interested in iOS/Android platform-optimized UX in Flutter app",
                fifthText: "Building my new home—starting next month."
            )
        )
        ImplementationStepSlide()
        CenterTextSlide(text: "Detailed source code will be available\non blog and GitHub later")
        ImplementationStep1Slide()
        SvgConverterDescriptionSlide()
        PathCodeScrollSlide()
        ImplementationStep2Slide()
        ContentSlide(headerTitle: "After Step2: Display Path") {
            FlutterView(type: .iconWithoutAnimation)
        }
        ImplementationStep3Slide()
        ContentSlide(headerTitle: "After Step3: Trimmed Path") {
            FlutterView(type: .iconWithAnimationHalf)
        }
        ImplementationStep4Slide()
        ContentSlide(headerTitle: "After Step4: Path animation!") {
            FlutterView(type: .icon)
        }
        CenterTextSlide(text: "This is the implementation approach!")
        CenterTextSlide(text: "Let's take a short break while watching a demo of how it actually works")
        CenterTextSlide(text: "Japan Symbol Quiz")
        JapanRegionSwiftMapSlide()
        SymbolsGridSlide()
        ComparePlatformAnimationSlide()
        ContentSlide(headerTitle: "Japan Symbol Quiz 1") {
            FlutterView(type: .symbolQuiz1)
        }
        ContentSlide(headerTitle: "Origami") {
            Image(.origami)
                .resizable()
                .scaledToFit()
        }

        SymbolsGridSlide(selectedSymbolPosition: .bottomRight)
        ImplementationFixedLengthStepSlide()
        ImplementationFixedLengthCodeSlide()
        ContentSlide(headerTitle: "It works like this!") {
            FlutterView(type: .waveFixedLength)
        }
        SymbolsGridSlide(selectedSymbolPosition: .bottomLeft)
        TextAnimationSampleSlide()
        ImplementationTextPathStepSlide()
        CenterTextSlide(text: "Let's check how it works!")
        ContentSlide(headerTitle: "Japan Symbol Quiz 2") {
            FlutterView(type: .symbolQuiz2)
        }
        WebTitleSlide(title: "Toyosu Market", url: URL(string: "https://www.toyosu-market.or.jp/en/")!)
        CenterTextSlide(text: "That wraps up \nthe Swift implementation I did!")
        ContentSlide(headerTitle: "I forgot about this implementation!") {
            FlutterView(type: .flightRouter)
        }
        ImplementationContentMoveSlide()
        ContentSlide(headerTitle: "You can also do this") {
            FlutterView(type: .iconMove)
        }
        ViewSlide {
            FlutterView(type: .moveTab)
        }
        WrapUpSlide()
        ReferenceSlide()
        ShareEndSlide(qrCodeType: .flutter)
    }

    public init() {}
}
