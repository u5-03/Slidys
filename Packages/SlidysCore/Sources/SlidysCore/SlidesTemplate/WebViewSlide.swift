//
//  WebViewSlide.swift
//
//
//  Created by Yugo Sugiyama on 2024/11/10.
//

import SwiftUI
import SlideKit
import WebUI

@Slide
public struct WebViewSlide: View {
    let url: URL

    public init(url: URL) {
        self.url = url
    }

    public var body: some View {
        WebViewReader { proxy in
            ZStack {
                WebView()
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
        WebViewSlide(url: URL(string: "https://github.com/u5-03")!)
    }
}

