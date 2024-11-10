//
//  SlidysApp.swift
//  Slidys
//
//  Created by Yugo Sugiyama on 2024/10/27.
//

import SwiftUI
import SlideKit
import FlutterKaigiSlide

@main
struct SlidysApp: App {
    @UIApplicationDelegateAdaptor (FlutterAppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}


