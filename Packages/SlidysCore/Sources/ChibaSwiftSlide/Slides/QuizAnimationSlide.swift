//
//  QuizAnimationSlide.swift
//  ChibaSwiftSlide
//
//  Created by Yugo Sugiyama on 2024/09/08.
//

import SwiftUI
import SlideKit
import SlidesCore
import SymbolKit

@Slide
struct QuizAnimationSlide<S: Shape>: View {
    let title: String
    let answer: String
    let shape: S
    @State private var isPaused = true
    @State private var shouldShowCorrectMark = false
    @State private var shouldShowNotCorrectMark = false
    @State private var shouldShowAnswer = false
    @State private var shouldShowAnswerName = false
    @FocusState private var isFocused: Bool
    let answerDuration: CGFloat = 5

    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            Text(title)
                .font(.largeFont)
                .foregroundStyle(.themeColor)
            ZStack {
                Group {
                    if shouldShowAnswer {
                        StrokeAnimationShapeView(
                            shape: shape,
                            lineWidth: 10,
                            lineColor: .white,
                            duration: .seconds(answerDuration),
                            isPaused: false
                        )
                    } else {
                        StrokeAnimationShapeView(
                            shape: shape,
                            lineWidth: 10,
                            lineColor: .white,
                            duration: .seconds(60),
                            isPaused: isPaused
                        )
                    }
                }
                .aspectRatio(1, contentMode: .fit)
                Image(systemName: "circle")
                    .resizable()
                    .frame(width: 500, height: 500)
                    .foregroundStyle(.red)
                    .shadow(radius: 10)
                    .opacity(shouldShowCorrectMark ? 1 : 0)
                Image(systemName: "xmark")
                    .resizable()
                    .frame(width: 500, height: 500)
                    .foregroundStyle(.blue)
                    .shadow(radius: 10)
                    .opacity(shouldShowNotCorrectMark ? 1 : 0)
            }
            HStack(spacing: 50) {
                Button {
                    isPaused.toggle()
                } label: {
                    Image(systemName: isPaused ? "play.fill" : "stop.fill")
                        .resizable()
                        .padding(20)
                        .frame(width: 120, height: 120)
                }
                Button {
                    shouldShowAnswer.toggle()
                    Task {
                        try? await Task.sleep(for: .seconds(answerDuration))
                        withAnimation(.easeInOut) {
                            shouldShowAnswerName = true
                        }
                    }
                } label: {
                    Text("正解を表示")
                        .font(.midiumFont)
                        .foregroundStyle(.defaultForegroundColor)
                        .padding()
                        .frame(height: 120)
                }
                Spacer()
                HStack(spacing: 4) {
                    Text("正解:")
                        .font(.midiumFont)
                        .foregroundStyle(.defaultForegroundColor)
                        .padding()
                        .frame(height: 120)
                    Text(answer)
                        .font(.largeFont)
                        .foregroundStyle(.strokeColor)
                        .padding()
                        .frame(height: 120)
                }
                .opacity(shouldShowAnswerName ? 1 : 0)


            }
            .padding(.horizontal, 40)
        }
        .padding(28)
        .frame(maxWidth: .infinity)
        .background(.slideBackgroundColor)
        .focusable()
        .focused($isFocused)
        .focusEffectDisabled()
        .onKeyPress(.space) {
            isPaused.toggle()
            return .handled
        }
        .onKeyPress(.init("c")) {
            withAnimation(.easeInOut) {
                shouldShowCorrectMark = true
            } completion: {
                Task {
                    try? await Task.sleep(for: .seconds(5))
                    withAnimation(.easeInOut) {
                        shouldShowCorrectMark = false
                    }
                }
            }
            return .handled
        }
        .onKeyPress(.init("u")) {
            withAnimation(.easeInOut) {
                shouldShowNotCorrectMark = true
            } completion: {
                Task {
                    try? await Task.sleep(for: .seconds(5))
                    withAnimation(.easeInOut) {
                        shouldShowNotCorrectMark = false
                    }
                }
            }
            return .handled
        }
        .onAppear {
            isFocused = true
        }
    }
}

#Preview {
    SlidePreview {
        QuizAnimationSlide(
            title: "千葉シンボルクイズ 第1問",
            answer: "ピーナッツ",
            shape: PeanutsShape()
        )
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
