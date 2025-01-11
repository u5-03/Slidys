//
//  WebPageView.swift
//  SlidysCore
//
//  Created by yugo.sugiyama on 2025/01/11.
//

import SwiftUI
import WebUI
import WebKit

public struct WebPageView: View {
    private let url: URL
    let configuration = WKWebViewConfiguration()
    
    public init(url: URL) {
        self.url = url
    }

    public var body: some View {
        WebView(request: URLRequest(url: url))
//        WebViewReader { proxy in
//            ZStack {
//                WebView(configuration: configuration)
//                    .onAppear {
//                        proxy.load(request: URLRequest(url: url))
//                    }
//                if proxy.isLoading {
//                    ProgressView()
//                }
//            }
//        }
    }
}

#Preview {
    WebPageView(url: URL(string: "https://github.com/u5-03/Slidys")!)
}
