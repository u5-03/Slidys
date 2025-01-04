//
//  SlidysApp.swift
//  Slidys
//
//  Created by Yugo Sugiyama on 2024/11/10.
//

import SwiftUI
import iOSDCSlide
import ChibaSwiftSlide
import KanagawaSwiftSlide
import SlidysCommon

@main
struct SlidysApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        WindowGroup(id: SlideType.iosdcSlide.id) {
            iOSDCSlideView()
        }
        WindowGroup(id: SlideType.kanagawaSwift.id) {
            KanagawaSwiftSlideView()
        }
        WindowGroup(id: SlideType.chibaSwift.id) {
            ChibaSwiftSlideView()
        }
        WindowGroup(id: SlideType.kanagawaSwift.id) {
            KanagawaSwiftSlideView()
        }
    }
}
