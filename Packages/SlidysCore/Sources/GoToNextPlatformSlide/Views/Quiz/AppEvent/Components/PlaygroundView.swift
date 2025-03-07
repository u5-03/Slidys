//
//  PlaygroundView.swift
//  SlidysCore
//
//  Created by yugo.sugiyama on 2025/02/19.
//

import SwiftUI

struct PlaygroundView: View {
    var body: some View {
        VStack(spacing: 0) {
            Color.brown
                .frame(height: 8)
            Color.white
                .frame(height: 4)
            Color.brown
                .frame(height: 12)
            Color.white
                .frame(height: 4)
            Color.brown
                .frame(height: 16)
            Color.white
                .frame(height: 4)
            Color.brown
                .frame(height: 20)
        }
    }
}

#Preview {
    PlaygroundView()
}
