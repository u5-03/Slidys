//
//  SlideClickerKeyInterceptor.swift
//  SlidesCore
//
//  クリッカー(プレゼン用リモコン。HID キーボードとして矢印 / Page Up/Down を送る)のページ送りを、
//  アプリ全体で受けるための仕組み。
//
//  SwiftUI の onKeyPress はキー Window の first responder に依存するため、
//   - 外部ディスプレイ用の Window を作ったとき
//   - 埋め込んだ Flutter の View をタップして Flutter が first responder になったとき
//     (Flutter は矢印 / Page Up/Down をフォーカス移動・スクロールとして自分で処理し、UIKit に返さない)
//  にキー入力が届かなくなる。UIApplication.sendEvent はどの Window 宛てのキーイベントも最初に通るので、
//  ここを差し替えて拾い、表示中のデッキ(SpeakerNotesSession に登録されたもの)を直接送る。
//
//  - Note: SwiftUI の App ライフサイクルは Info.plist の NSPrincipalClass を無視して自前の
//    SwiftUIApplication を使う(ログで確認済み)ので、UIApplication のサブクラスでは差し込めない。
//    そのため起動時(AppDelegate の didFinishLaunching)に実際の UIApplication クラスの sendEvent を
//    ObjC ランタイムで差し替える。
//

#if os(iOS)
import ObjectiveC
import OSLog
import UIKit

private let clickerLog = Logger(subsystem: "Slidys", category: "Clicker")

@MainActor
public enum SlideClickerKeyInterceptor {
    private static var isInstalled = false

    /// AppDelegate の didFinishLaunching から呼ぶ(両アプリで呼び出し済み)
    public static func install() {
        guard !isInstalled else { return }
        isInstalled = true

        let applicationClass: AnyClass = type(of: UIApplication.shared)
        let selector = #selector(UIApplication.sendEvent(_:))
        guard let method = class_getInstanceMethod(applicationClass, selector) else {
            clickerLog.error("sendEvent not found on \(String(describing: applicationClass), privacy: .public)")
            return
        }
        typealias SendEvent = @convention(c) (AnyObject, Selector, UIEvent) -> Void
        let original = unsafeBitCast(method_getImplementation(method), to: SendEvent.self)
        let replacement: @convention(block) (AnyObject, UIEvent) -> Void = { application, event in
            // sendEvent はメインスレッドで呼ばれる
            let handled = MainActor.assumeIsolated { handle(event) }
            if handled { return }
            original(application, selector, event)
        }
        // 実際のクラス(SwiftUIApplication など)に override として差し込む。
        // 元の実装(そのクラス自身か、継承した UIApplication のもの)は original で呼び続ける
        class_replaceMethod(
            applicationClass,
            selector,
            imp_implementationWithBlock(replacement),
            method_getTypeEncoding(method)
        )
        clickerLog.info("installed on \(String(describing: applicationClass), privacy: .public)")
    }

    /// 矢印 / Page Up/Down をページ送りにする。デッキを表示していないときは何もしない(false)。
    /// ページ送りとして処理したキーは、Flutter や SwiftUI に二重に届けない(true を返して握りつぶす)
    static func handle(_ event: UIEvent) -> Bool {
        guard event.type == .presses, let pressesEvent = event as? UIPressesEvent else { return false }
        guard let slideIndexController = SpeakerNotesSession.shared.presentation?.slideIndexController else {
            return false
        }
        var handled = false
        for press in pressesEvent.allPresses {
            guard let key = press.key else { continue }
            switch key.keyCode {
            case .keyboardRightArrow, .keyboardPageDown:
                // 押した瞬間だけ送る(離したときのイベントも UIKit には渡さない)
                if press.phase == .began { slideIndexController.forward() }
                handled = true
            case .keyboardLeftArrow, .keyboardPageUp:
                if press.phase == .began { slideIndexController.back() }
                handled = true
            default:
                break
            }
        }
        return handled
    }
}
#endif
