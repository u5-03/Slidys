//
//  FlutterView.swift
//  Slidys
//
//  Created by Yugo Sugiyama on 2024/10/27.
//

import SwiftUI
import Flutter

enum FlutterViewType: String {
    case piano
    case circle
    case calendar
    case circleAnimation

    fileprivate var path: String {
        return "/\(rawValue)"
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
