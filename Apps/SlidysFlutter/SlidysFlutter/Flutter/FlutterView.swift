//
//  FlutterView.swift
//  Slidys
//
//  Created by Yugo Sugiyama on 2024/10/27.
//

import SwiftUI
import Flutter
import FlutterKaigiSlide
import FlutterNinjasSlide
import FlutterKaigi2026Slide

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
        let flutterViewController = FlutterViewController(project: nil, initialRoute: type.path, nibName: nil, bundle: nil)
        // Ref: https://github.com/flutter/flutter/issues/21808#issuecomment-493609075
        flutterViewController.isViewOpaque = false
        // FlutterViewController ごとに独立したエンジンが作られるため、MethodChannel もここで登録する。
        // (FlutterKaigi2026 の画面リプレイデモが PNG 連番 → mp4 のエンコードをネイティブに依頼する)
        ScreenReplayChannel.register(messenger: flutterViewController.binaryMessenger)
        return flutterViewController
    }

    func updateUIViewController(_ uiViewController: FlutterViewController, context: Context) {
    }
}
