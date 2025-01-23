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

    public init(url: URL) {
        self.url = url
    }

    public var body: some View {
        #if os(iOS)
        SafariView(url: url)
            .edgesIgnoringSafeArea(.all) // iOSで全画面表示
        #elseif os(macOS)
        WebView(request: URLRequest(url: url))
        #endif
    }
}

#if os(iOS)
// iOS用のSafariView
import SafariServices

struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        // 更新ロジックが必要ならここに記述
    }
}
#endif

#Preview {
    WebPageView(url: URL(string: "https://github.com/u5-03/Slidys")!)
}
