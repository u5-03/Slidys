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
            Item("DeNAでFlutter製のスポーツ系のライブ配信アプリplay-by-sportsを開発中", accessory: .number(1)) {
                Item("大型アップデート準備中で忙しい", accessory: .number(1))
            }
            Item("Kanagawa.swiftの運営してました", accessory: .number(2))
            Item("戸建て準備中(次は電気系の仕様を決めるMTG)", accessory: .number(3))
            Item("確定申告でVisionProをどうやって減価償却するかを悩み中", accessory: .number(4))
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
