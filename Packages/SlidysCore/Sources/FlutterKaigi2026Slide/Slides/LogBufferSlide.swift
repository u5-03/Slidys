//
//  LogBufferSlide.swift
//  FlutterKaigi2026Slide
//
//  「最大の差分: ログは自分で溜める」のページ。スライド全面を Flutter で描いていて、
//  2 項目目に `main()` → `mein()` の誤字をわざと入れてある。左下の Debug ボタンから起票画面を開き、
//  動画の添付と要素ピッカーでの選択(誤字を含む行)まで行う、起票フローのライブデモを兼ねる。
//
//  - Flutter 側: flutter_slide/lib/widgets/feedback/log_slide_demo_page.dart
//  - サムネイル / PDF / スナップショットでは Flutter を起動せず、同じ見た目の SwiftUI 版を出す
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct LogBufferSlide: View, ExternalDisplayMirroringPreferred {
    var script: String {
        """
        次はそのログの取得の仕方についてです。Flutter には iOS の OSLogStore のような API がないので、main() で debugPrint や print をフックして、アプリ内に溜めておきます。
        ログの数も増えすぎると大変なので、上限を設定して保持します。
        このような形でログの取得はしています。
        おっと、よく見ると2行目のmainがtypoしてしまっています。
        これはバグなので、いまここで起票してみましょう。

        (左下の Debug をタップ)内容は入れてあります。実際に書くときは、キーボードの音声入力が便利です。iOS も Android も標準で使えます。
        (一番上の「画面から選ぶ」→ mein() の行をタップ →「この要素にする」)場所は画面から選ぶだけ。
        (下にスクロールして「直近の動画を添付」をタップ)動画は直近の画面から作ります。デモなので 10 秒です。起票画面を開く直前までが入り、その場で再生して確認できます。
        (一番下の「送信」をタップ)送信。細かい直しは、起票後に PC でやる前提です。その場では止まらずに報告してもらうのが大事です。

        あとは起票の処理をするだけですが、ここは使っているサービスによって変わります。
        私たちは GitHub の Issue と Projects を使っているので、その API をアプリの中から呼んでいます。
        Jira など、だいたいのチケット管理サービスには API があるので、それを呼べば同じことができます。
        ここから先は GitHub Actions を前提にした話なので、他のサービスを使っている方は、やり方が変わります。
        (右上をタップして次へ)
        """
    }

    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    @Environment(\.isSlideThumbnail) private var isSlideThumbnail
    @Environment(\.router) private var router

    var body: some View {
        ZStack {
            // Flutter が描画を始めるまでの間と、サムネイル / PDF 用の静的な見た目
            LogBufferStaticContent()
            if !isSlideThumbnail {
                router.build(viewType: .logSlide)
                    .id(FlutterKaigi2026ViewType.logSlide.path)
                    // ページ全面が Flutter なので、左上/右上のタップ送りは Flutter 側で受けて MethodChannel で転送している
                    .excludesFromSlideTapNavigation()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.slideBackgroundColor)
    }
}

/// Flutter 版と同じ見た目の SwiftUI 版(誤字もそのまま)
private struct LogBufferStaticContent: View {
    var body: some View {
        HeaderSlide(loc: "最大の差分: ログは自分で溜める") {
            Item(loc: "Flutter には iOS の OSLogStore 相当の API がない", keywords: ["OSLogStore 相当の API がない"], accessory: .number(1))
            Item(loc: "mein() で debugPrint / print / onError をフックして流し込む", keywords: ["mein() で"], accessory: .number(2))
            Item(loc: "起動時からアプリ内リングバッファに直近 1000 行を保持し、起票時に添付", keywords: ["起動時から"], accessory: .number(3))
        }
    }
}

#Preview {
    SlidePreview {
        LogBufferSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}
