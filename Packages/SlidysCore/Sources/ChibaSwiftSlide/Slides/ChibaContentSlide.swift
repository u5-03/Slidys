//
//  ChibaContentSlide.swift
//  ChibaSwiftSlide
//
//  Created by Yugo Sugiyama on 2024/09/08.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct ChibaContentSlide: View {
    @Phase var phase: SlidePhase
    enum SlidePhase: Int, PhasedState {
        case initial
        case second
        case third
        case fourth
    }
    var body: some View {
        ZStack {
            HeaderSlide("スライドに載せた千葉イラスト") {
                if phase.isAfter(.second) {
                    Item("千葉ポートタワー", accessory: .number(1)) {
                        Item("千葉県の中央区にある高さ約125ｍのタワー", accessory: .number(1))
                        Item("いらすとやで出てきた笑", accessory: .number(2))
                    }
                }
                if phase.isAfter(.third) {
                    Item("ピーナッツ", accessory: .number(2)) {
                        Item("有名な農作物・お土産(日本シェア80%超えらしい)", accessory: .number(1))
                    }
                }
                if phase.isAfter(.fourth) {
                    Item("菜の花", accessory: .number(3)) {
                        Item("千葉県の県花", accessory: .number(1))
                        Item("千葉県民には、「なのはな体操」でもお馴染みらしい", accessory: .number(2))
                    }
                }
            }

            ZStack {
                Image(.speechBallon)
                    .resizable()
                    .frame(width: 580, height: 250)
                Text("千葉といえば..")
                    .font(.midiumFont)
                    .foregroundStyle(.themeColor)
                    .padding()
                    .frame(height: 120)
                Image(.kyonIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300)
                    .clipShape(Circle())
                    .offset(.init(width: 340, height: 200))
            }
            .offset(.init(width: 420, height: -350))

        }
    }
}

#Preview {
    SlidePreview {
        ChibaContentSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
