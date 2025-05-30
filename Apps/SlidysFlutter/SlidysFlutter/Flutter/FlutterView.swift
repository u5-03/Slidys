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

enum FlutterViewType {
    case flutterKaigi(type: FlutterKaigiViewType)
    case flutterNinjas(type: FlutterNinjasViewType)

    var path: String {
        switch self {
        case .flutterKaigi(type: let type):
            return type.path
        case .flutterNinjas(type: let type):
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
        return flutterViewController
    }

    func updateUIViewController(_ uiViewController: FlutterViewController, context: Context) {
    }
}
