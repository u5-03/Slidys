//
//  SampleYugiohCardEffectView.swift
//  SlidysCore
//
//  Created by Yugo Sugiyama on 2025/03/01.
//

import SwiftUI
import YugiohCardEffect

struct SampleYugiohCardEffectView: View {
    var body: some View {
        YugiohCardEffectView(
            controller: .init(
                cardModels: [
                    .sample,
                    .chibaCard,
                    .kanagawaCard,
                    .osakaCard,
                    .minokamoCard,
                    .sample2,
                    .kyon
                ]
            )
        )
    }
}

#Preview {
    SampleYugiohCardEffectView()
}
