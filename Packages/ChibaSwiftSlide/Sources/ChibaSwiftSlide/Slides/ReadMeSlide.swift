//
//  ReadMeSlide.swift
//  ChibaSwiftSlide
//
//  Created by Yugo Sugiyama on 2024/09/20.
//

import SwiftUI
import SlideKit
import SlidysCore

@Slide
struct ReadmeSlide: View {
    var body: some View {
        HeaderSlide("README") {
            HStack(spacing: 32) {
                Text("すぎー/Sugiy")
                    .font(.largeFont)
                Image(.icon)
                    .resizable()
                    .frame(width: 160, height: 160, alignment: .leading)
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Circle())
            }
            Item("前々々職(2018~)からiOSエンジニア。元々中高の社会科教員志望", accessory: .number(1))
            Item("現職はDeNAで、Flutter製のスポーツ系のライブ配信アプリを開発中", accessory: .number(2)) {
                Item("業務でSwift使ってないので、Swift力の低下が深刻")
            }
            Item("趣味: 美味しいものを食べる、料理、アニメ/漫画、ガジェット収集", accessory: .number(3))
            Item("Vision Proのお財布へのダメージが大きい😇", accessory: .number(4))
            Item("去年のiOSDCで発表したパイナップル🍎はベランダで成長中", accessory: .number(5))
        }
    }
}

#Preview {
    SlidePreview {
        ReadmeSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
