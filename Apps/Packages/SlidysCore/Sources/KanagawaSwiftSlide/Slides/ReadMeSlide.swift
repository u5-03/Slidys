//
//  ReadMeSlide.swift
//  KanagawaSwiftSlide
//
//  Created by Yugo Sugiyama on 2024/09/20.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct ReadmeSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

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
            Item("現職はDeNAで、Flutter製のスポーツ系のライブ配信アプリを開発中", accessory: .number(2))
            Item("趣味: 美味しいものを食べる、料理、アニメ/漫画、ガジェット収集", accessory: .number(3))
            Item("Kanagawa.swiftの運営の1人", accessory: .number(4))
            Item("不定期で家でご飯を食べる会を実施", accessory: .number(5))
            Item("戸建て準備中(macOS native Symposiumの裏で設計士と5hのMTG)", accessory: .number(6))
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
