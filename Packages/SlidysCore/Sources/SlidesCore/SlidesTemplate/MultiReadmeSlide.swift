//
//  MultiIntroductionSlide.swift
//  SlidysCore
//
//  Created by yugo.sugiyama on 2025/02/19.
//

import SwiftUI
import SlideKit

public struct MultiReadmeInfo {
    let name: String
    let image: ImageResource
    let firstText: String
    let secondText: String

    public init(name: String, image: ImageResource, firstText: String, secondText: String) {
        self.name = name
        self.image = image
        self.firstText = firstText
        self.secondText = secondText
    }
}

@Slide
public struct MultiIntroductionSlide: View {
    let title: String
    let firstPersonInfo: MultiReadmeInfo
    let secondPersonInfo: MultiReadmeInfo

    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    public init(title: String, firstPersonInfo: MultiReadmeInfo, secondPersonInfo: MultiReadmeInfo) {
        self.title = title
        self.firstPersonInfo = firstPersonInfo
        self.secondPersonInfo = secondPersonInfo
    }

    public var body: some View {
        HeaderSlide(.init(stringLiteral: title)) {
            HStack(spacing: 32) {
                Text(firstPersonInfo.name)
                    .font(.largeFont)
                Image(firstPersonInfo.image)
                    .resizable()
                    .frame(width: 160, height: 160, alignment: .leading)
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Circle())
            }
            Item(.init(stringLiteral: firstPersonInfo.firstText), accessory: .number(1))
            Item(.init(stringLiteral: firstPersonInfo.secondText), accessory: .number(2))
            HStack(spacing: 32) {
                Text(secondPersonInfo.name)
                    .font(.largeFont)
                Image(secondPersonInfo.image)
                    .resizable()
                    .frame(width: 160, height: 160, alignment: .leading)
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Circle())
            }
            Item(.init(stringLiteral: secondPersonInfo.firstText), accessory: .number(1))
            Item(.init(stringLiteral: secondPersonInfo.secondText), accessory: .number(2))
        }
    }
}

#Preview {
    SlidePreview {
        MultiIntroductionSlide(
            title: "README",
            firstPersonInfo: .init(
                name: "すぎー/Sugiy",
                image: .icon,
                firstText: "現職はDeNAで、Flutter製のスポーツ系のライブ配信アプリを開発中",
                secondText: "趣味: 美味しいものを食べる、料理、アニメ/漫画、ガジェット収集"
            ),
            secondPersonInfo: .init(
                name: "すぎー/Sugiy",
                image: .icon,
                firstText: "現職はDeNAで、Flutter製のスポーツ系のライブ配信アプリを開発中",
                secondText: "趣味: 美味しいものを食べる、料理、アニメ/漫画、ガジェット収集"
            )
        )
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
