//
//  StrokeBackground.swift
//  SlidysCore
//
//  Created by yugo.sugiyama on 2025/02/19.
//

import SwiftUI

struct StrokeBackground: ViewModifier {
    private let id = UUID()

    private var strokeSize: CGFloat

    private var strokeColor: Color

    init(strokeSize: CGFloat, strokeColor: Color) {
        self.strokeSize = strokeSize
        self.strokeColor = strokeColor
    }

    func body(content: Content) -> some View {
        if strokeSize > 0 {
            strokeBackgroundView(content: content)
        } else {
            content
        }
    }

    private func strokeBackgroundView(content: Content) -> some View {
        content
            .padding(strokeSize * 2)
            .background(strokeView(content: content))
    }

    private func strokeView(content: Content) -> some View {
        Rectangle()
            .foregroundColor(strokeColor)
            .mask(maskView(content: content))
    }

    private func maskView(content: Content) -> some View {
        Canvas { context, size in
            context.addFilter(.alphaThreshold(min: 0.01))
            context.drawLayer { ctx in
                if let resolvedView = context.resolveSymbol(id: id) {
                    ctx.draw(resolvedView, at: .init(x: size.width / 2, y: size.height / 2))
                }
            }
        } symbols: {
            content
                .tag(id)
                .blur(radius: strokeSize)
        }
    }
}

extension View {
    public func stroked(color: Color, width: CGFloat = 1) -> some View {
        modifier(StrokeBackground(strokeSize: width, strokeColor: color))
    }
}
