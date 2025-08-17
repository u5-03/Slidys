//
//  SignLanguageDemoSlide.swift
//  iOSDC2025Slide
//
//  Created by Claude on 2025/01/09.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct SignLanguageDemoSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        VStack(spacing: 40) {
            Text("Demo")
                .font(.system(size: 120, weight: .heavy))
                .foregroundStyle(.themeColor)
            
            Text("手話ジェスチャーの検知")
                .font(.system(size: 80, weight: .bold))
                .foregroundStyle(.defaultForegroundColor)
            
            VStack(spacing: 35) {
                SignLanguageItem(
                    emoji: "🙏",
                    word: "ありがとう",
                    description: "両手を合わせて下に動かす"
                )
                SignLanguageItem(
                    emoji: "👌",
                    word: "OK / 良い",
                    description: "親指と人差し指で輪を作る"
                )
                SignLanguageItem(
                    emoji: "🤟",
                    word: "愛してる（I Love You）",
                    description: "親指・人差し指・小指を立てる"
                )
                SignLanguageItem(
                    emoji: "🤙",
                    word: "電話 / あとで",
                    description: "親指と小指を立てる"
                )
                SignLanguageItem(
                    emoji: "👋",
                    word: "こんにちは / さようなら",
                    description: "手を振る動作"
                )
            }
            .padding(.horizontal, 100)
            
            Text("※ 実際の手話はより複雑で、表情や動きも重要な要素です")
                .font(.system(size: 35))
                .foregroundColor(.gray)
                .padding(.top, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(80)
        .background(.slideBackgroundColor)
        .foregroundColor(.defaultForegroundColor)
    }
}

struct SignLanguageItem: View {
    let emoji: String
    let word: String
    let description: String
    
    var body: some View {
        HStack(spacing: 30) {
            Text(emoji)
                .font(.system(size: 70))
            
            VStack(alignment: .leading, spacing: 5) {
                Text(word)
                    .font(.system(size: 45, weight: .bold))
                Text(description)
                    .font(.system(size: 35))
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
    }
}

#Preview {
    SlidePreview {
        SignLanguageDemoSlide()
    }
}