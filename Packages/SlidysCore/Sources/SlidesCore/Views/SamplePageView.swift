//
//  SamplePageView.swift
//  SlidysCore
//
//  Created by Yugo Sugiyama on 2025/03/01.
//

import SwiftUI

enum SamplePageType: String, CaseIterable, Identifiable {
    case yugiohEffect

    public var id: String {
        return rawValue
    }

    public var displayValue: String {
        switch self {
        case .yugiohEffect:
            return "Yugioh Effect"
        }
    }

    @ViewBuilder
    public var view: some View {
        switch self {
        case .yugiohEffect:
            SampleYugiohCardEffectView()
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
