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
import SlidysCore

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

    @ViewBuilder
    public var view: some View {
        switch self {
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
    }
}

enum SlideSectionType: Identifiable, Hashable {
    case slides(SlideType)
    case info(InfoSectionType)

    var id: String {
        switch self {
        case .slides(let slideType):
            return slideType.id
        case .info(let infoSectionType):
            return infoSectionType.id
        }
    }

    @ViewBuilder
    var view: some View {
        switch self {
        case .slides(let slideType):
            slideType.view
        case .info(let infoSectionType):
            infoSectionType.view
        }
    }
}

struct ContentView: View {
    @State private var selectedSectionType: SlideSectionType?

    var body: some View {
        NavigationStack {
            List(selection: $selectedSectionType) {
                Section("Slides") {
                    ForEach(SlideType.allCases) { type in
                        Text(type.displayValue)
                            .padding()
                            .tag(SlideSectionType.slides(type))
                    }
                }
                Section("Other") {
                    ForEach(InfoSectionType.allCases) { type in
                        Text(type.displayValue)
                            .padding()
                            .tag(SlideSectionType.info(type))
                    }
                }
            }
            .listRowBackground(Color.clear)
            .navigationTitle("Slidys")
        }
        .fullScreenCover(item: $selectedSectionType) { type in
            ZStack(alignment: .topTrailing) {
                type.view
                closeButton
            }
        }
    }

    var closeButton: some View {
        Button(action: {
            selectedSectionType = nil
        }) {
            Circle()
                .strokeBorder(Color.gray, lineWidth: 2)
                .background(Image(systemName: "xmark").foregroundStyle(.gray))
                .frame(width: 50, height: 50)
                .padding()

        }
    }
}



#Preview {
    ContentView()
}
