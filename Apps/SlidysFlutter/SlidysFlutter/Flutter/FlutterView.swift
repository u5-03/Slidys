//
//  FlutterView.swift
//  Slidys
//
//  Created by Yugo Sugiyama on 2024/10/27.
//

import SwiftUI
import Flutter
import FlutterPluginRegistrant
import FlutterKaigiSlide
import FlutterNinjasSlide
import FlutterKaigi2026Slide
import SlidesCore

enum FlutterViewType {
    case flutterKaigi(type: FlutterKaigiViewType)
    case flutterNinjas(type: FlutterNinjasViewType)
    case flutterKaigi2026(type: FlutterKaigi2026ViewType)

    var path: String {
        switch self {
        case .flutterKaigi(type: let type):
            return type.path
        case .flutterNinjas(type: let type):
            return type.path
        case .flutterKaigi2026(type: let type):
            return type.path
        }
    }
}

struct FlutterView: UIViewControllerRepresentable {
    let type: FlutterViewType

    func makeUIViewController(context: Context) -> FlutterViewController {
        // FlutterViewControllerを指定したルートで起動
        // スライドの表示言語を Flutter に渡す(Flutter 側は main() でこのクエリを読む)。
        // 発表中に言語を切り替えるとスライドごと作り直されるので、この View も新しいルートで作り直される
        let languageQuery = SlideLanguageStore.shared.language == .english ? "?lang=en" : ""
        let flutterViewController = FlutterViewController(
            project: nil,
            initialRoute: type.path + languageQuery,
            nibName: nil,
            bundle: nil
        )
        // Ref: https://github.com/flutter/flutter/issues/21808#issuecomment-493609075
        flutterViewController.isViewOpaque = false
        // FlutterViewController ごとに独立したエンジンが作られるため、MethodChannel もここで登録する。
        // (FlutterKaigi2026 の画面リプレイデモが PNG 連番 → mp4 のエンコードをネイティブに依頼する)
        // 画面リプレイの撮影(PlatformView も含めて View 階層ごと撮る)と mp4 エンコード
        ScreenReplayChannel.register(messenger: flutterViewController.binaryMessenger, captureView: flutterViewController.view)
        // 全面を Flutter で描くページ(FlutterKaigi2026 のログのページ)から、左上/右上タップのページ送りを受ける
        SlideNavigationChannel.register(messenger: flutterViewController.binaryMessenger)
        // FlutterViewController ごとのエンジンにも pub のプラグインを登録する
        // (起票画面の動画プレイヤーが video_player を使う)
        GeneratedPluginRegistrant.register(with: flutterViewController.pluginRegistry())
        return flutterViewController
    }

    func updateUIViewController(_ uiViewController: FlutterViewController, context: Context) {
    }
}

/// `flutter_slide/slide_navigation` チャネル。Flutter 側で受けたページ送りのタップを、発表中のデッキに転送する。
/// (全面が Flutter のページでは、SwiftUI 側の左上/右上のタップ領域を Flutter に譲っているため)
enum SlideNavigationChannel {
    static let name = "flutter_slide/slide_navigation"

    static func register(messenger: FlutterBinaryMessenger) {
        let channel = FlutterMethodChannel(name: name, binaryMessenger: messenger)
        channel.setMethodCallHandler { call, result in
            Task { @MainActor in
                let controller = SpeakerNotesSession.shared.presentation?.slideIndexController
                switch call.method {
                case "forward":
                    controller?.forward()
                    result(nil)
                case "back":
                    controller?.back()
                    result(nil)
                default:
                    result(FlutterMethodNotImplemented)
                }
            }
        }
    }
}
