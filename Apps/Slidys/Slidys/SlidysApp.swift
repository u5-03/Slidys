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
import SlidesCore


@main
struct SlidysApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
#if os(visionOS)
        WindowGroup(id: SlideType.slideWindowKey, for: SlideType.self) { slideTypeBinding in
            if let slideType = slideTypeBinding.wrappedValue {
                AnyView(slideType.view)
            }
        }
        WindowGroup(id: InfoSectionType.infoSectionWindowKey, for: InfoSectionType.self) { infoSectionTypeBinding in
            if let infoSectionType = infoSectionTypeBinding.wrappedValue {
                AnyView(infoSectionType.view)
            }
        }
        WindowGroup(id: SamplePageType.samplePageWindowKey, for: SamplePageType.self) { samplePageTypeBinding in
            if let samplePageType = samplePageTypeBinding.wrappedValue {
                AnyView(samplePageType.view)
            }
        }
#endif
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
