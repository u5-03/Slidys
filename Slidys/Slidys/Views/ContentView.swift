//
//  ContentView.swift
//  Slidys
//
//  Created by Yugo Sugiyama on 2024/10/27.
//

import SwiftUI
import FlutterKaigiSlide

enum SlideType: CaseIterable, Identifiable {
    case flutterKaigi

    var id: String {
        return displayValue
    }

    var displayValue: String {
        switch self {
        case .flutterKaigi:
            return "FlutterKaigi2024"
        }
    }
}

struct ContentView: View {
    @State private var selectedItem: SlideType?

    var body: some View {
        NavigationStack {
            List(SlideType.allCases, selection: $selectedItem) { item in
                Text(item.displayValue)
                    .padding()
                    .tag(item)
            }
            .navigationTitle("Slidys")
        }
        .fullScreenCover(item: $selectedItem) { type in
            ZStack(alignment: .topTrailing) {
                switch type {
                case .flutterKaigi:
                    FlutterKaigiSlideView()
                        .environment(\.router, Router())
                }
                closeButton
            }
        }
    }

    var closeButton: some View {
        Button(action: {
            selectedItem = nil
        }) {
            Circle()
                .strokeBorder(Color.white, lineWidth: 2)
                .background(Image(systemName: "xmark").foregroundStyle(.white))
                .frame(width: 50, height: 50)

        }
    }
}



#Preview {
    ContentView()
}
