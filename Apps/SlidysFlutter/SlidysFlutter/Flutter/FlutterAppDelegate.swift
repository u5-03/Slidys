//
//  FlutterAppDelegate.swift
//  Slidys
//
//  Created by Yugo Sugiyama on 2024/11/10.
//

import Foundation
import FlutterPluginRegistrant

final class FlutterAppDelegate: NSObject, UIApplicationDelegate {
    var flutterEngine: FlutterEngine?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FlutterEngineManager.shared.startEngine()

        return true
    }
}

