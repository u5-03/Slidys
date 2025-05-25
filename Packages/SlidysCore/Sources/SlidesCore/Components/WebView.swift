//
//  Created by yugo.sugiyama on 2025/05/25
//  Copyright ©Sugiy All rights reserved.
//

import SwiftUI
import WebKit

#if os(iOS) || os(visionOS)
import UIKit

struct CrossPlatformWebView: UIViewRepresentable {
    let url: URL
    let configuration: WKWebViewConfiguration

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
#elseif os(macOS)
import AppKit

struct CrossPlatformWebView: NSViewRepresentable {
    let url: URL
    let configuration: WKWebViewConfiguration

    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {}
}
#endif
