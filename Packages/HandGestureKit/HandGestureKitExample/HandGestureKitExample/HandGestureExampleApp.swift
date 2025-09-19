//
//  HandGestureExampleApp.swift
//  HandGestureKitExample
//
//  Created by HandGestureKit Contributors
//

import SwiftUI
import HandGestureKit

@main
struct HandGestureExampleApp: App {
    @State private var appModel = AppModel()
    
    var body: some SwiftUI.Scene {
        WindowGroup {
            ContentView()
                .environment(appModel)
        }
        .windowStyle(.plain)
        
        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView()
                .environment(appModel)
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
    }
}
