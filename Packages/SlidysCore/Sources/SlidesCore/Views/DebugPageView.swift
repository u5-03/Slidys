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
            shape: PathTextShape(
                "Hello, world!",
                font: .singlePathLineFont()
            ),
            duration: .seconds(3)
        )
    }
}

#Preview {
    DebugPageView()
}
