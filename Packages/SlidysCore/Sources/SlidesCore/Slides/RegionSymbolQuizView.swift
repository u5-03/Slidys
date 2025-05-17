//
//  Created by yugo.sugiyama on 2025/03/12
//  Copyright ©Sugiy All rights reserved.
//

import SwiftUI
import SymbolKit

public struct RegionSymbolQuizView: View {
    public init() {}

    public var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 0) {
                symbolView(
                    title: "Chiba.swift",
                    shape: UhooiShape(),
                    aspectRatio: UhooiShape.aspectRatio
                )
                symbolView(
                    title: "Kanagawa.swift",
                    shape: TrainShape(),
                    aspectRatio: TrainShape.aspectRatio
                )
            }
            HStack(spacing: 0) {
                symbolView(
                    title: "Osaka.swift",
                    shape: TextPathShape(
                        "UniversalStudioJapan",
                        textAnimationOrder: .random
                    ),
                    aspectRatio: 546 / 297
                )
                symbolView(
                    title: "Minokamo.swift",
                    shape: NobunagaShape(),
                    aspectRatio: NobunagaShape.aspectRatio,
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
        animationType: PathAnimationType = .progressiveDraw
    ) -> some View {
        VStack(spacing: 6) {
            StrokeAnimationShapeView(
                shape: shape,
                lineWidth: 4,
                lineColor: .white,
                duration: .seconds(5),
                shapeAspectRatio: aspectRatio,
                viewModel: .init(animationType: animationType)
            )
            Text(title)
                .font(.smallFont)
                .frame(maxWidth: .infinity)
                .foregroundStyle(.defaultForegroundColor)
        }
    }
}

#Preview {
    RegionSymbolQuizView()
}
