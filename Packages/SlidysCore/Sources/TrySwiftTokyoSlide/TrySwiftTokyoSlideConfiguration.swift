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
                secondText: "First time to speak at try! Swift",
                thirdText: "Absolutely adore fish, Japanese cuisine/sweets",
                fourthText: "interested in visionOS development",
                fifthText: "I will also speak at Flutter Ninjas 2025 next month"
            )
        )
        AnimationStructureSlide()
        CenterTextSlide(text: "Structure is simple!")
        CenterTextSlide(text: "How can we make use of it?")

        ContentSlide(headerTitle: "Regional Swift events called 'Japan-\\\\(region)-Swift' are being held accross Japan") {
            Image(.japanRegionMap)
                .resizable()
        }
        RegionSymbolQuizSlide()
        TrySwiftSymbolQuizSlide()
        WrapUpSlide()
        CenterTextSlide(text: "By the way...")
        CenterTextSlide(text: "Next Japan-\\(region).swift is...")
        ContentSlide(headerTitle: "Nagoya.swift") {
            Image(.japanRegionMapWithNagoya)
                .resizable()
        }
        ContentSlide(headerTitle: "See you in Nagoya.swift!") {
            Image(.nagoyaSwift)
                .resizable()
        }
        CenterTextSlide(text: "End")
    }
}

#Preview {
    TrySwiftTokyoSlideView()
}
