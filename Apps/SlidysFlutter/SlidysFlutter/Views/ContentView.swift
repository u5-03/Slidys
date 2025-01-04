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
import SlidesCore
import SlidysCommon

enum FlutterSlideType: CaseIterable, Identifiable, SlideTypeProtocol {
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

    public var view: any SlideViewProtocol {
        switch self {
        case .flutterKaigi:
            FlutterKaigiSlideView(router: Router())
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
