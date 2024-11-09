//
//  FlutterEngineManager.swift
//  Slidys
//
//  Created by Yugo Sugiyama on 2024/10/27.
//

import Foundation
import Flutter
import FlutterPluginRegistrant

class FlutterEngineManager {
    static let shared = FlutterEngineManager()
    var engine: FlutterEngine?

    private init() {}

    func startEngine() {
        if engine == nil {
            engine = FlutterEngine(name: "my_flutter_engine")
            engine?.run()
//            engine?.run(withEntrypoint: "/circle")
            GeneratedPluginRegistrant.register(with: engine!)
        }
    }
}
