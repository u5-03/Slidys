//
//  CodeBlockView.swift
//  SlidesCore
//
//  Created by Claude on 2025/01/20.
//

import SwiftUI
import SlideKit
import SyntaxInk

/// コードブロックを表示する共通コンポーネント
/// SyntaxInkを使用してシンタックスハイライトを提供
public struct CodeBlockView: View {
    let code: String
    let fontSize: CGFloat

    public init(
        _ code: String,
        fontSize: CGFloat = 32
    ) {
        self.code = code
        self.fontSize = fontSize
    }
    
    public var body: some View {
        Code(
            code,
            syntaxHighlighter: .presentationDark(fontSize: fontSize)
        )
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    VStack(spacing: 20) {
        CodeBlockView("""
        let anchorEntity = AnchorEntity(
            .hand(.left, location: .thumbTip)
        )
        """)
        
        CodeBlockView(
            """
            func detectGesture() -> Bool {
                return true
            }
            """,
            fontSize: 40
        )
    }
    .padding()
}
