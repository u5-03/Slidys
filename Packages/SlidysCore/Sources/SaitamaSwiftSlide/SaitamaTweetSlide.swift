import SlideKit
import SlidesCore
import SwiftUI
import WebKit
import OSLog

/// 投稿ページのアプリ誘導モーダルを避け、公式の埋め込みウィジェットを表示する。
@Slide struct SaitamaTweetSlide: View {
    @Environment(\.isSlideThumbnail) private var isThumbnail
    var transition: AnyTransition { SlideTransition.defaultTransition }
    var script: String { "Apple Storeのデモのように、3Dモデルの気になる部分へフォーカスする見せ方です。" }
    var body: some View {
        GeometryReader { proxy in
            Group {
                if isThumbnail {
                    EmbeddedContentPlaceholder(title: "Apple Storeの3Dデモ", systemImage: "play.rectangle", caption: "投稿の動画")
                } else {
                    EmbeddedSaitamaTweet()
                }
            }
                .background(Color.slideBackgroundColor)
                // Keep the shared corner navigation regions outside the interactive post.
                .overlay {
                    Color.clear
                        .frame(width: proxy.size.width * 0.6)
                        .excludesFromSlideTapNavigation()
                        .allowsHitTesting(false)
                }
        }
    }
}

private let tweetLog = Logger(subsystem: "Slidys", category: "PresenterCapture")

private enum TweetDocument {
    static let html = """
    <!doctype html><html lang="ja"><head>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="twitter:dnt" content="on">
    <style>
      html,body { margin:0; padding:0; width:100%; height:100%; overflow:hidden; background:transparent; color:#fff; }
      #post { position:absolute; top:0; left:0; width:550px; transform-origin:top left; }
      #post iframe { margin:0 !important; }
      blockquote { margin:0; }
      a { color:#8ecbff; }
    </style></head><body><div id="post">
    <blockquote class="twitter-tweet" data-theme="dark" data-lang="ja"
      data-conversation="none" data-dnt="true" data-width="550">
      <a href="https://twitter.com/u5_03/status/1918537899894816798">投稿を読み込み中…</a>
    </blockquote></div>
    <script>
      // ウィジェットが返す実際の高さに合わせて、上下いっぱいへ拡大する。
      // cross-origin iframe内部には触れず、公式ウィジェット自体を拡大する。
      const post = document.getElementById('post');
      const observed = new WeakSet();
      function fitPost() {
        const frame = post.querySelector('iframe');
        if (!frame || frame.offsetHeight < 100) return;
        const width = frame.offsetWidth || 550;
        const scale = window.innerHeight / frame.offsetHeight;
        const transform = 'scale(' + scale + ')';
        const left = ((window.innerWidth - width * scale) / 2) + 'px';
        if (post.style.transform !== transform) post.style.transform = transform;
        if (post.style.left !== left) post.style.left = left;
      }
      const resize = new ResizeObserver(fitPost);
      new MutationObserver(() => {
        post.querySelectorAll('iframe').forEach(frame => {
          if (!observed.has(frame)) { observed.add(frame); resize.observe(frame); }
        });
        fitPost();
      }).observe(post, {childList:true, subtree:true});
      window.addEventListener('resize', fitPost);
    </script>
    <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>
    </body></html>
    """

    static func makeWebView(delegate: WKNavigationDelegate) -> WKWebView {
        let config = WKWebViewConfiguration()
#if os(iOS) || os(visionOS)
        config.allowsInlineMediaPlayback = true
        // Keep one inline player on the source display. Do not let WebKit move
        // playback to a separate AirPlay/PiP presentation while mirroring the app.
        config.allowsAirPlayForMediaPlayback = false
        config.allowsPictureInPictureMediaPlayback = false
        config.mediaTypesRequiringUserActionForPlayback = []
#endif
        let view = WKWebView(frame: .zero, configuration: config)
        view.navigationDelegate = delegate
        view.underPageBackgroundColor = .clear
#if os(iOS) || os(visionOS)
        view.isOpaque = false
#endif
        tweetLog.notice("[PresenterCapture] tweet webview-created inline=true airplay=false pip=false")
        view.loadHTMLString(html, baseURL: URL(string: "https://ulog.sugiy.com/"))
        return view
    }
}

private final class TweetNavigationDelegate: NSObject, WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        tweetLog.notice("[PresenterCapture] tweet document-loaded")
    }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: any Error) {
        let detail = error as NSError
        tweetLog.error("[PresenterCapture] tweet load-failed domain=\(detail.domain, privacy: .public) code=\(detail.code)")
    }
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        tweetLog.error("[PresenterCapture] tweet web-content-process-terminated")
    }
    func webView(_ webView: WKWebView, decidePolicyFor action: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        // 投稿の動画は埋め込み内で再生し、リンクから投稿ページやXアプリへ遷移させない。
        let scheme = action.request.url?.scheme?.lowercased()
        let unsupportedScheme = scheme.map { !["https", "http", "about"].contains($0) } ?? false
        if action.navigationType == .linkActivated || unsupportedScheme {
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
}

#if os(iOS) || os(visionOS)
private struct EmbeddedSaitamaTweet: UIViewRepresentable {
    func makeCoordinator() -> TweetNavigationDelegate { TweetNavigationDelegate() }
    func makeUIView(context: Context) -> WKWebView { TweetDocument.makeWebView(delegate: context.coordinator) }
    func updateUIView(_ view: WKWebView, context: Context) {}
    static func dismantleUIView(_ view: WKWebView, coordinator: TweetNavigationDelegate) {
        view.pauseAllMediaPlayback(completionHandler: {})
        view.stopLoading()
        view.navigationDelegate = nil
        tweetLog.notice("[PresenterCapture] tweet webview-dismantled playback-paused")
    }
}
#elseif os(macOS)
private struct EmbeddedSaitamaTweet: NSViewRepresentable {
    func makeCoordinator() -> TweetNavigationDelegate { TweetNavigationDelegate() }
    func makeNSView(context: Context) -> WKWebView { TweetDocument.makeWebView(delegate: context.coordinator) }
    func updateNSView(_ view: WKWebView, context: Context) {}
}
#endif

#Preview("投稿の埋め込み", traits: .fixedLayout(width: 900, height: 900)) {
    SaitamaTweetSlide()
}
