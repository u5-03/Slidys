//
//  ConnectionChartSlide.swift
//  iOSDC2024Slide
//
//  Created by Yugo Sugiyama on 2024/08/08.
//

import SwiftUI
import SlideKit
import PianoUI
import SlidesCore

@Slide
struct ConnectionChartSlide: View {
    private let connectionHeight: CGFloat = 120
    private let animationDuration: CGFloat = 1
    @State private var inputAlignment: Alignment = .trailing
    @State private var outputAlignment: Alignment = .leading
    @State private var isMusicNoteScaling = false
    @State private var inputKey: KeyType?
    @State private var buttonScale: CGFloat = 1
    @Phase var phase: SlidePhase
//    @State var phase: SlidePhase = .createOutput
    private var localizedKeyType: String {
        let preferredLanguage = Bundle.main.preferredLocalizations.first
        if preferredLanguage == "ja" {
            return inputKey?.keyItalicKatakanaName ?? " "
        } else {
            return inputKey?.keyEnglishName ?? " "
        }
    }

    enum SlidePhase: Int, PhasedState {
        case initial
        case createInput
        case createInputConnection
        case runInputConnection
        case createOutput
    }

    var body: some View {
        HeaderSlide("デバイスとピアノの接続イメージ") {
            VStack(spacing: 0) {
                Spacer()
                if phase.isAfter(.createInputConnection) {
                    Text("Connectionを作成")
                } else {
                    // Add default space
                    Text(" ")
                }
                HStack(alignment: .center, spacing: 0) {
                    VStack {
                        Text(" ")
                        ZStack {
                            Image(systemName: "ipad.gen1.landscape")
                                .resizable()
                                .scaledToFit()
                            if phase.isAfter(.runInputConnection) {
                                VStack(spacing: 30) {
                                    Text(localizedKeyType)
                                        .font(.system(size: 100, weight: .bold))
                                        .foregroundStyle(.white)
                                        .transition(AnyTransition.opacity.animation(.easeInOut(duration:0.2)))
                                    Image(systemName: "button.programmable")
                                        .resizable()
                                        .aspectRatio(1, contentMode: .fit)
                                        .frame(width: 100)
                                        .symbolRenderingMode(.hierarchical)
                                        .scaleEffect(.init(buttonScale))
                                }
                            }
                        }
                    }
                    VStack(spacing: 50) {
                        if phase.isAfter(.createInputConnection) {
                            ZStack(alignment: inputAlignment) {
                                RoundedRectangle(cornerRadius: connectionHeight / 2)
                                    .frame(height: connectionHeight)
                                if phase.isAfter(.runInputConnection) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.red)
                                            .frame(height: connectionHeight)
                                            .aspectRatio(1, contentMode: .fit)
                                        Image(.musicNote)
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundStyle(Color.white)
                                            .padding()
                                            .frame(height: connectionHeight)
                                    }
                                    .onAppear {
                                        withAnimation(.linear(duration: animationDuration).repeatForever(autoreverses: false)) {
                                            inputAlignment = .leading
                                        } completion: {
                                            inputAlignment = .trailing
                                        }
                                        Timer.scheduledTimer(withTimeInterval: animationDuration, repeats: true) { _ in
                                            withAnimation {
                                                inputKey = .random
                                            }
                                            withAnimation(.bouncy(duration: 0.5)) {
                                                buttonScale = .random(in: 1.0..<1.8)
                                            } completion: {
                                                buttonScale = 1
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 30)
                        } else {
                            Color.clear
                                .frame(height: connectionHeight)
                        }
                        Rectangle()
                            .foregroundStyle(.white)
                            .frame(height: connectionHeight / 4)
                        if phase.isAfter(.createOutput) {
                            ZStack(alignment: outputAlignment) {
                                RoundedRectangle(cornerRadius: connectionHeight / 2)
                                    .frame(height: connectionHeight)
                                ZStack {
                                    Circle()
                                        .fill(Color.blue)
                                        .frame(height: connectionHeight)
                                        .aspectRatio(1, contentMode: .fit)
                                    Image(.musicNote)
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundStyle(Color.white)
                                        .padding()
                                        .frame(height: connectionHeight)
                                }
                                .onAppear {
                                    withAnimation(.linear(duration: animationDuration).repeatForever(autoreverses: false)) {
                                        outputAlignment = .trailing
                                    } completion: {
                                        outputAlignment = .leading
                                    }

                                }
                            }
                            .padding(.horizontal, 30)
                        } else {
                            Color.clear
                                .frame(height: connectionHeight)
                        }
                    }
                    .frame(width: 500)
                    .offset(y: 50)
                    VStack {
                        HStack(spacing: 20) {
                            if phase.isAfter(.createInput) {
                                Text("Input")
                                    .bold()
                                    .foregroundStyle(Color.red)
                            } else {
                                Text(" ")
                            }
                            if phase.isAfter(.createOutput) {
                                Text(" / ")
                                Text("Output")
                                    .bold()
                                    .foregroundStyle(Color.blue)
                            }
                        }
                        ZStack {
                            Image(.newPiano)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                            if phase.isAfter(.createOutput) {
                                Image(.musicNote)
                                    .resizable()
                                    .foregroundStyle(Color.black)
                                    .scaledToFit()
                                    .frame(height: connectionHeight * 3)
                                    .shadow(color: .white, radius: 10)
                                    .scaleEffect(isMusicNoteScaling ? 1.2 : 0.8)
                                    .onAppear {
                                        withAnimation(.linear(duration: animationDuration / 3).repeatForever()) {
                                            isMusicNoteScaling = true
                                        }
                                    }
                            }
                        }
                    }
                }
                Spacer()
            }
        }
    }
}

#Preview {
    SlidePreview {
        ConnectionChartSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
