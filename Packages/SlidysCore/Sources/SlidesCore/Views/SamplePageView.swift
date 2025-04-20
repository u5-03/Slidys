//
//  SamplePageView.swift
//  SlidysCore
//
//  Created by Yugo Sugiyama on 2025/03/01.
//

import SwiftUI
import SymbolKit

enum SamplePageType: String, CaseIterable, Identifiable {
    case yugiohEffect
    case japanSymbolQuizExtra1
    case japanSymbolQuizExtra2
    case japanSymbolQuizExtra3
    case pixelImage

    public var id: String {
        return rawValue
    }

    public var displayValue: String {
        switch self {
        case .yugiohEffect:
            return "Yugioh Effect"
        case .japanSymbolQuizExtra1:
            return "Japan Symbol Quiz Extra1"
        case .japanSymbolQuizExtra2:
            return "Japan Symbol Quiz Extra2"
        case .japanSymbolQuizExtra3:
            return "Japan Symbol Quiz Extra3"
        case .pixelImage:
            return "PixelUIView"
        }
    }

    @ViewBuilder
    public var view: some View {
        switch self {
        case .yugiohEffect:
            SampleYugiohCardEffectView()
        case .japanSymbolQuizExtra1:
            SymbolQuizSampleView(
                title: "JapanSymbolQuiz Extra1",
                answer: "Mt.Fuji/富士山",
                answerHint: "",
                shape: MtFujiShape(),
                shapeAspectRatio: MtFujiShape.aspectRatio,
                questionDrawingDuration: .seconds(20),
                answerDrawingDuration: .seconds(6),
                pathAnimationType: .progressiveDraw
            )
        case .japanSymbolQuizExtra2:
            SymbolQuizSampleView(
                title: "JapanSymbolQuiz Extra2",
                answer: "Origami/折り紙",
                answerHint: "",
                shape: OrigamiShape(),
                shapeAspectRatio: OrigamiShape.aspectRatio,
                questionDrawingDuration: .seconds(60),
                answerDrawingDuration: .seconds(6),
                pathAnimationType: .progressiveDraw
            )
        case .japanSymbolQuizExtra3:
            SymbolQuizSampleView(
                title: "JapanSymbolQuiz Extra3",
                answer: "Dragon Ball",
                answerHint: "",
                shape: DragonBallShape(),
                shapeAspectRatio: DragonBallShape.aspectRatio,
                lineWidth: 2,
                questionDrawingDuration: .seconds(60),
                answerDrawingDuration: .seconds(6),
                pathAnimationType: .progressiveDraw
            )
        case .pixelImage:
            PixelImageSettingView(imageResource: .icon)
                .padding(.top, 60)
        }
    }
}

struct SamplePageView: View {
    @State private var selectedType: SamplePageType?

    var body: some View {
        GeometryReader { proxy in
            NavigationStack {
                List(selection: $selectedType) {
                    ForEach(SamplePageType.allCases) { type in
                        Text(type.displayValue)
                            .padding()
                            .tag(type)
                    }
                }
                .listRowBackground(Color.clear)
                .navigationTitle("Sample Page")
            }
#if os(macOS)
            .sheet(item: $selectedType) { type in
                let size = proxy.size
                ZStack(alignment: .topTrailing) {
                    type.view
                        .frame(width: size.width, height: size.height)
                    closeButton
                        .padding()
                }
            }
#elseif os(iOS)
            .fullScreenCover(item: $selectedType) { type in
                ZStack(alignment: .topTrailing) {
                    type.view
                    closeButton
                        .padding()
                }
            }
#endif
        }
    }

    var closeButton: some View {
        Button(action: {
            selectedType = nil
        }) {
            Circle()
                .strokeBorder(Color.gray, lineWidth: 2)
                .background(Image(systemName: "xmark").foregroundStyle(.gray))
                .frame(width: 24, height: 24)
                .padding(.all, 4)

        }
        .buttonStyle(.borderless)
    }
}

#Preview {
    SamplePageView()
}
