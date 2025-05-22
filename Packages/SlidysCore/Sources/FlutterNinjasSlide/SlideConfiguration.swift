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
        ContentSlide(headerTitle: "Japan Symbol Quiz 2") {
            FlutterView(type: .symbolQuiz2)
        }
        CenterTextSlide(text: "FlutterNinjas2025")
        CenterTextSlide(text: "Let me ask you a question!")
        ContentSlide(headerTitle: "How would you implement this? Part1") {
            FlutterView(type: .icon)
        }
        ContentSlide(headerTitle: "How would you implement this? Part2") {
            HelloAnimationView()
        }
        ContentSlide(headerTitle: "How would you implement this? Part3") {
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
        SvgConverterDescriptionSlideswift()
        PathCodeScrollSlide()
        ImplementationStep2Slide()
        ImplementationStep3Slide()
        ImplementationStep4Slide()
        CenterTextSlide(text: "This is the implementation approach!")
        CenterTextSlide(text: "Let's see a demo of how it actually works\nand take a short break")
        CenterTextSlide(text: "Japan Symbol Quiz")
        JapanRegionSwiftMapSlide()
        SymbolsGridSlide()
        ContentSlide(headerTitle: "Japan Symbol Quiz 1") {
            FlutterView(type: .symbolQuiz1)
        }
        ContentSlide(headerTitle: "Origami") {
            Image(.origami)
                .resizable()
                .scaledToFit()
        }

        SymbolsGridSlide()
        ImplementationFixedLengthStepSlide()
        ImplementationFixedLengthCodeSlide()
        ContentSlide(headerTitle: "It works like this!") {
            FlutterView(type: .waveFixedLength)
        }
        SymbolsGridSlide()
        TextAnimationSampleSlide()
        ImplementationTextPathStepSlide()
        CenterTextSlide(text: "Let's check how it works!")
        ContentSlide(headerTitle: "Japan Symbol Quiz 2") {
            FlutterView(type: .symbolQuiz2)
        }
        CenterTextSlide(text: "That wraps up the Swift implementation I did!")
        ContentSlide(headerTitle: "I forgot about this implementation!") {
            FlutterView(type: .flightRouter)
        }
        ImplementationTextPathStepSlide()
        ContentSlide(headerTitle: "You can also do this") {
            FlutterView(type: .iconMove)
        }
        ViewSlide {
            FlutterView(type: .moveTab)
        }
        WrapUpSlide()
//        ReferenceSlide()
        CenterTextSlide(text: "Thank you for listening!")
    }

    public init() {}
}
