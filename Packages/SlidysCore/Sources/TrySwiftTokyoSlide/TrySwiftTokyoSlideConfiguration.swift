//
//  TrySwiftTokyoSlide.swift
//  SlidysCore
//
//  Created by Yugo Sugiyama on 2025/03/01.
//

import SwiftUI
import SlideKit
import SlidesCore
import SymbolKit

public struct TrySwiftTokyoSlideView: SlideViewProtocol {
    let configuration = SlideConfiguration()

    public init() {}

    public var body: some View {
        SlideBaseView(slideConfiguration: configuration)
    }
}

struct SlideConfiguration: SlideConfigurationProtocol {
    @MainActor
    let slideIndexController = SlideIndexController() {
        CenterTextSlide(text: "try! Swift Tokyo 2025")
        CenterTextSlide(text: "Question!")
        HelloAnimationSlide()
        TitleSlide()
        ReadmeSlide(
            title: "README",
            info: ReadmeInfo(
                name: "Sugiy",
                image: .icon,
                firstText: "Developing Flutter live streaming app in DeNA Co., Ltd.",
                secondText: "First time to speak at try! Swift Tokyo",
                thirdText: "Absolutely adore fish, Japanese cuisine/sweets",
                fourthText: "interested in visionOS development",
                fifthText: "I will also speak at Flutter Ninjas 2025 next month"
            )
        )
        AnimationStructure1Slide()
        CodeSlide(
            title: "Source Code 1",
            code: Constants.strokeAnimatableShapeCodeCode,
            fontSize: 40
        )
        AnimationStructure2Slide()
        CodeSlide(
            title: "Source Code 2",
            code: Constants.strokeAnimationShapeViewCode,
            fontSize: 38
        )
        ContentSlide(headerTitle: "That's all!") {
            HelloAnimationView(duration: .seconds(2))
        }
        CenterTextSlide(text: "Structure is simple!")
        CenterTextSlide(text: "How can we make use of it?")

        ContentSlide(headerTitle: "Regional Swift events called 'Japan-\\\\(region).swift' are being held across Japan") {
            Image(.japanRegionMap)
                .resizable()
        }
        RegionSymbolQuizSlide()
        TrySwiftSymbolQuizSlide()
        WrapUpSlide()
        OneMoreThingSlide()
        CenterTextSlide(text: "Next Japan-\\(region).swift is...")
        ContentSlide(headerTitle: "Nagoya.swift at the end of this April") {
            Image(.japanRegionMapWithNagoya)
                .resizable()
        }
        ContentSlide(headerTitle: "See you again at Nagoya.swift!") {
            Image(.nagoyaSwift)
                .resizable()
        }
        ShareEndSlide()
    }
}

#Preview {
    TrySwiftTokyoSlideView()
}
