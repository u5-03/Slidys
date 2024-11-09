//
//  SlidysApp.swift
//  Slidys
//
//  Created by Yugo Sugiyama on 2024/10/27.
//

import SwiftUI
import FlutterPluginRegistrant
import Flutter
import SlideKit

@main
struct SlidysApp: App {
    @UIApplicationDelegateAdaptor (AppDelegate.self) var appDelegate
    static let configuration = SlideConfiguration()

    var presentationContentView: some View {
        SlideRouterView(slideIndexController: Self.configuration.slideIndexController)
            .slideTheme(Self.configuration.theme)
            .foregroundColor(.black)
            .background(.white)
    }

    var body: some Scene {
        WindowGroup {
            PresentationView(slideSize: Self.configuration.size) {
                ZStack {
                    presentationContentView
                    HStack(spacing: 0) {
                        Rectangle()
                            .foregroundStyle(Color.black.opacity(0.01))
                            .onTapGesture {
                                Self.configuration.slideIndexController.back()
                            }
                        Color.clear
                            .containerRelativeFrame(.horizontal) { length, _ in
                                return length * 0.8
                            }
                        Rectangle()
                            .foregroundStyle(Color.black.opacity(0.01))
                            .onTapGesture {
                                Self.configuration.slideIndexController.forward()
                            }
                    }
                }
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    var flutterEngine: FlutterEngine?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FlutterEngineManager.shared.startEngine()

        return true
    }
}
