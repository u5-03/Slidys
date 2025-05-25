//
//  WebTitleSlide.swift
//
//
//  Created by Yugo Sugiyama on 2024/11/10.
//

import SwiftUI
import SlideKit
import WebKit

@Slide
public struct WebTitleSlide: View {
    let title: String
    let url: URL
    let configuration: WKWebViewConfiguration

    public init(title: String, url: URL) {
        self.title = title
        self.url = url
        let configuration = WKWebViewConfiguration()
        // TwitterはWebViewをサポートしてないので、user-agentを書き換える必要がある
        configuration.applicationNameForUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1"
        self.configuration = configuration
    }

    public var body: some View {
        CrossPlatformWebView(url: url, configuration: configuration) 
    }
}

#Preview {
    SlidePreview {
        WebTitleSlide(
            title: "Title",
            url: URL(string: "https://github.com/u5-03")!
        )
    }
}

