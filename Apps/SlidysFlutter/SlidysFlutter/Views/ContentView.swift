//
//  ContentView.swift
//  Slidys
//
//  Created by Yugo Sugiyama on 2024/10/27.
//

import SwiftUI
import FlutterKaigiSlide
import FlutterNinjasSlide
import ChibaSwiftSlide
import KanagawaSwiftSlide
import iOSDCSlide
import SlidesCore
import SlidysCommon

enum FlutterSlideType: CaseIterable, Identifiable, SlideTypeProtocol {
    case flutterKaigi
    case FlutterNinjas

    var id: String {
        return displayValue
    }

    var displayValue: String {
        switch self {
        case .flutterKaigi:
            return "FlutterKaigi2024"
        case .FlutterNinjas:
            return "FlutterNinjas2025"
        }
    }

    public var view: any SlideViewProtocol {
        switch self {
        case .flutterKaigi:
            FlutterKaigiSlideView(router: FlutterKaigiRouter())
        case .FlutterNinjas:
            FlutterNinjasSlideView(router: FlutterNinjasRouter())
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
