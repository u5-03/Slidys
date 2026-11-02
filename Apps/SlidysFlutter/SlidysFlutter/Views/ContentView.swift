//
//  ContentView.swift
//  Slidys
//
//  Created by Yugo Sugiyama on 2024/10/27.
//

import SwiftUI
import FlutterKaigiSlide
import FlutterNinjasSlide
import FlutterKaigi2026Slide
import ChibaSwiftSlide
import KanagawaSwiftSlide
import iOSDCSlide
import SlidesCore
import SlidysCommon

enum FlutterSlideType: CaseIterable, Identifiable, SlideTypeProtocol {
    case flutterKaigi
    case FlutterNinjas
    case flutterKaigi2026

    var id: String {
        return displayValue
    }

    var displayValue: String {
        switch self {
        case .flutterKaigi:
            return "FlutterKaigi2024"
        case .FlutterNinjas:
            return "FlutterNinjas2025"
        case .flutterKaigi2026:
            return "FlutterKaigi2026"
        }
    }

    public var view: any SlideViewProtocol {
        switch self {
        case .flutterKaigi:
            FlutterKaigiSlideView(router: FlutterKaigiRouter())
        case .FlutterNinjas:
            FlutterNinjasSlideView(router: FlutterNinjasRouter())
        case .flutterKaigi2026:
            FlutterKaigi2026SlideView(router: FlutterKaigi2026Router())
        }
    }
}

struct ContentView: View {
    var body: some View {
        SlidysCommonView(
            slideTypes: SlideType.allCases + FlutterSlideType.allCases
        )
    }
}



#Preview {
    ContentView()
}
