//
//  ReadmeSlide.swift
//  SlidysCore
//
//  Created by yugo.sugiyama on 2025/02/19.
//

import SwiftUI
import SlideKit

public struct ReadmeInfo {
    let name: String
    let image: ImageResource
    let firstText: String
    let secondText: String
    let thirdText: String
    let fourthText: String
    let fifthText: String
}

@Slide
public struct ReadmeSlide: View {
    let title: String
    let info: ReadmeInfo

    public init(title: String, info: ReadmeInfo) {
        self.title = title
        self.info = info
    }

    public var body: some View {
        HeaderSlide(.init(stringLiteral: title)) {
            HStack(spacing: 32) {
                Text(.init(stringLiteral: info.name))
                    .font(.largeFont)
                Image(info.image)
                    .resizable()
                    .frame(width: 160, height: 160, alignment: .leading)
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Circle())
            }
            Item(.init(stringLiteral: info.firstText), accessory: .number(1))
            Item(.init(stringLiteral: info.secondText), accessory: .number(2))
            Item(.init(stringLiteral: info.thirdText), accessory: .number(3))
            Item(.init(stringLiteral: info.fourthText), accessory: .number(4))
            Item(.init(stringLiteral: info.fifthText), accessory: .number(5))
        }
    }
}

#Preview {
    SlidePreview {
        ReadmeSlide(
            title: "README",
            info: .init(
                name: "すぎー/Sugiy",
                image: .icon,
                firstText: "前々々職(2018~)からiOSエンジニア。元々中高の社会科教員志望",
                secondText: "現職はDeNAで、Flutter製のスポーツ系のライブ配信アプリを開発中",
                thirdText: "趣味: 美味しいものを食べる、料理、アニメ/漫画、ガジェット収集",
                fourthText: "Vision Proのお財布へのダメージが大きい😇",
                fifthText: "去年発表したパイナップル🍎はベランダですくすく成長中"
            )
        )
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}

