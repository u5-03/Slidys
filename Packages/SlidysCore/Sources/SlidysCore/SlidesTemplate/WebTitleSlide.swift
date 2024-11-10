//
//  WebTitleSlide.swift
//
//
//  Created by Yugo Sugiyama on 2024/11/10.
//

import SwiftUI
import SlideKit
import WebUI

@Slide
public struct WebTitleSlide: View {
    let title: String
    let url: URL

    public init(title: String, url: URL) {
        self.title = title
        self.url = url
    }

    public var body: some View {
        WebViewReader { proxy in
            VStack(spacing: 0) {
                Text(title)
                    .font(.mediumFont)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 32)
                    .padding()
                    .foregroundStyle(.defaultForegroundColor)
                    .background(.slideBackgroundColor)
                ZStack {
                    WebView()
                        .onAppear {
                            proxy.load(request: URLRequest(url: url))
                        }
                    if proxy.isLoading {
                        ProgressView()
                            .foregroundStyle(.white)
                    }
                }
            }
        }
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

