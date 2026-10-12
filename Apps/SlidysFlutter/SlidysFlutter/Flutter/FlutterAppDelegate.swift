//
//  FlutterAppDelegate.swift
//  Slidys
//
//  Created by Yugo Sugiyama on 2024/11/10.
//

import Foundation
import FlutterPluginRegistrant
import SlidesCore
import UIKit

final class FlutterAppDelegate: NSObject, UIApplicationDelegate {
    var flutterEngine: FlutterEngine?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FlutterEngineManager.shared.startEngine()
        // 検証用: 起動引数 -SlidysExternalDisplayPreview で外部ディスプレイの内容を小窓で重ねる(Slidys と同じ)
        ExternalDisplayPreviewOverlay.installIfRequested()
        // クリッカー(矢印 / Page Up/Down)をアプリ全体で受ける(Flutter が first responder でも効くように)
        SlideClickerKeyInterceptor.install()

        return true
    }

    /// 外部ディスプレイ(HDMI / AirPlay)用の Scene を自前の Window にする(スライドを外部、ノートを手元に)
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        ExternalDisplayCoordinator.sceneConfiguration(for: connectingSceneSession)
            ?? UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
    }
}

