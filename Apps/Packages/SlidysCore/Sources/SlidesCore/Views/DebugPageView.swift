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
                "ABCDEFGHIJKLMNOPQRSTUVWXYZ",
                font: .singlePathLineFont()
            ),
            lineWidth: 3,
            lineColor: .black,
            duration: .seconds(3),
            isPaused: false,
            shapeAspectRatio: 0.5
        )
    }
}

#Preview {
    DebugPageView()
}
