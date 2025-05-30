//
//  Created by yugo.sugiyama on 2025/03/12
//  Copyright ©Sugiy All rights reserved.
//

import SwiftUI
import SymbolKit

public enum SymbolPosition {
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight
}

public struct RegionSymbolQuizView: View {
    private let selectedSymbolPosition: SymbolPosition?

    public init(selectedSymbolPosition: SymbolPosition? = nil) {
        self.selectedSymbolPosition = selectedSymbolPosition
    }

    public var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 0) {
                symbolView(
                    title: "Chiba.swift",
                    shape: UhooiShape(),
                    aspectRatio: UhooiShape.aspectRatio,
                    symbolPosition: .topLeft,
                    selectedSymbolPosition: selectedSymbolPosition
                )
                symbolView(
                    title: "Kanagawa.swift",
                    shape: TrainShape(),
                    aspectRatio: TrainShape.aspectRatio,
                    symbolPosition: .topRight,
                    selectedSymbolPosition: selectedSymbolPosition
                )
            }
            HStack(spacing: 0) {
                symbolView(
                    title: "Osaka.swift",
                    shape: TextPathShape(
                        "UniversalStudioJapan",
                        textAnimationOrder: .random
                    ),
                    aspectRatio: 546 / 297,
                    symbolPosition: .bottomLeft,
                    selectedSymbolPosition: selectedSymbolPosition
                )
                symbolView(
                    title: "Minokamo.swift",
                    shape: NobunagaShape(),
                    aspectRatio: NobunagaShape.aspectRatio,
                    symbolPosition: .bottomRight,
                    selectedSymbolPosition: selectedSymbolPosition,
                    animationType: .fixedRatioMove(strokeLengthRatio: 0.2)
                )
            }
        }
        .padding(4)
        .background(.slideBackgroundColor)
    }
}

private extension RegionSymbolQuizView {
    func symbolView(
        title: String,
        shape: any Shape,
        aspectRatio: CGFloat,
        symbolPosition: SymbolPosition,
        selectedSymbolPosition: SymbolPosition? = nil,
        animationType: PathAnimationType = .progressiveDraw
    ) -> some View {
        VStack(spacing: 6) {
            StrokeAnimationShapeView(
                shape: shape,
                lineWidth: 4,
                lineColor: .white,
                duration: .seconds(30),
                shapeAspectRatio: aspectRatio,
                viewModel: .init(animationType: animationType)
            )
            Text(title)
                .font(.smallFont)
                .frame(maxWidth: .infinity)
                .foregroundStyle(.defaultForegroundColor)
        }
        .padding()
        .border(.strokeColor, width: selectedSymbolPosition == symbolPosition ? 8 : 0)
    }
}

#Preview {
    RegionSymbolQuizView(selectedSymbolPosition: .topRight)
}
