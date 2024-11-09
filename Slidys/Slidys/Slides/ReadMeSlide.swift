//
//  ReadMeSlide.swift
//  Slidys
//
//  Created by Yugo Sugiyama on 2024/11/06.
//


import SwiftUI
import SlideKit

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
            Item("2023年7月からDeNA", accessory: .number(1)) {
                Item("現在はiOSエンジニアからFlutterエンジニアに転生中", accessory: .number(1))
                Item("Flutter製のスポーツ系のライブ配信アプリを開発中", accessory: .number(2))
            }
            Item("今回Flutterについて初登壇", accessory: .number(2)) {
                Item("iOSDC2024のLTもあったので、ずーとLTの準備やらをしている気がする笑", accessory: .number(1))
            }
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
