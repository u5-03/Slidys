//
//  ContentView.swift
//  Slidys
//
//  Created by Yugo Sugiyama on 2024/10/27.
//

import SwiftUI
import FlutterKaigiSlide
import ChibaSwiftSlide
import KanagawaSwiftSlide
import iOSDCSlide

enum SlideType: CaseIterable, Identifiable {
    case flutterKaigi
    case chibaSwift
    case kanagawaSwift
    case iosdcSlide

    var id: String {
        return displayValue
    }

    var displayValue: String {
        switch self {
        case .flutterKaigi:
            return "FlutterKaigi2024"
        case .chibaSwift:
            return "Chiba.swift #1"
        case .kanagawaSwift:
            return "Kanagawa.swift #1"
        case .iosdcSlide:
            return "iOSDC2024"
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
                case .chibaSwift:
                    ChibaSwiftSlideView()
                case .kanagawaSwift:
                    KanagawaSwiftSlideView()
                case .iosdcSlide:
                    iOSDCSlideView()
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
