//
//  SlidysApp.swift
//  Slidys
//
//  Created by Yugo Sugiyama on 2024/11/10.
//

import SwiftUI
import ChibaSwiftSlide
import KanagawaSwiftSlide

@main
struct SlidysApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        WindowGroup(id: SlideType.kanagawaSwift.id) {
            KanagawaSwiftSlideView()
        }
        WindowGroup(id: SlideType.chibaSwift.id) {
            ChibaSwiftSlideView()
        }
    }
}
