//
//  WebViewSlide.swift
//
//
//  Created by Yugo Sugiyama on 2024/11/10.
//

import SwiftUI
import SlideKit
import WebUI
import WebKit

@Slide
public struct WebViewSlide: View {
    let url: URL
    let configuration: WKWebViewConfiguration

    public init(url: URL) {
        self.url = url
        let configuration = WKWebViewConfiguration()
        // TwitterはWebViewをサポートしてないので、user-agentを書き換える必要がある
        configuration.applicationNameForUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1"
        self.configuration = configuration
    }

    public var body: some View {
        WebViewReader { proxy in
            ZStack {
                WebView(configuration: configuration)
                    .onAppear {
                        proxy.load(request: URLRequest(url: url))
                    }
                if proxy.isLoading {
                    ProgressView()
                }
            }
        }
    }
}

#Preview {
    SlidePreview {
        WebViewSlide(url: URL(string: "https://twitter.com/totokit4/status/1780083727789686992")!)
    }
}

