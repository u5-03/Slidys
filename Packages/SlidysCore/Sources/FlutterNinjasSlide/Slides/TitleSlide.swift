//
//  TitleSlide.swift
//  Slidys
//
//  Created by Yugo Sugiyama on 2024/10/29.
//

import SwiftUI
import SlideKit

@Slide
struct TitleSlide: View {
    private let dateString = "2025/5/30"
    private let interval: TimeInterval = 0.2
    private let startDate = Date()

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                Text("Exploring Flutter Path Animations")
                    .font(.system(size: 100, weight: .heavy))
                    .minimumScaleFactor(0.1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("")
                    .font(.system(size: 100, weight: .heavy))
                    .minimumScaleFactor(0.1)
                    .frame(maxWidth: .infinity, alignment: .center)
                Text("")
                    .font(.system(size: 100, weight: .heavy))
                    .minimumScaleFactor(0.1)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .foregroundStyle(.themeColor)
            Spacer()
                .frame(height: 20)
            VStack(alignment: .trailing, spacing: 20) {
                HStack(spacing: 20) {
                    Spacer()
                    Text(dateString)
                        .font(.system(size: 80, weight: .heavy))
                        .frame(alignment: .trailing)
                    Text("FlutterNinjas 2025")
                        .font(.system(size: 80, weight: .heavy))
                        .frame(alignment: .trailing)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.leading)
                HStack(spacing: 20) {
                    Spacer()
                    Text("Sugiy/Yugo Sugiyama")
                        .font(.system(size: 100, weight: .heavy))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    Image(.icon)
                        .resizable()
                        .frame(width: 160, height: 160)
                        .aspectRatio(contentMode: .fit)
                        .clipShape(Circle())
                }
            }
        }
        .padding(80)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.slideBackgroundColor)
        .foregroundColor(.defaultForegroundColor)
    }

    var shouldHideIndex: Bool { true }
}

#Preview {
    SlidePreview {
        TitleSlide()
    }
}
