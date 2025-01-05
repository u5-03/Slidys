//
//  DebugPageView.swift
//  SlidysCore
//
//  Created by Yugo Sugiyama on 2025/01/05.
//

import SwiftUI
import SymbolKit

public struct DebugPageView: View {
    public var body: some View {
        StrokeAnimationShapeView(
            shape: TextPathShape(
                "UniversalStudioJapan",
                font: .singlePathLineFont(),
                textAnimationOrder: .random
            ),
            duration: .seconds(60)
        )
    }
}

#Preview {
    DebugPageView()
}
