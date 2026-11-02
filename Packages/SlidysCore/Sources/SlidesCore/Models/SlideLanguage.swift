//
//  SlideLanguage.swift
//  SlidesCore
//
//  スライドの表示言語。OS の設定アプリで選んだアプリの言語が既定で、
//  多言語対応しているデッキでは発表中にもメニューから切り替えられる。
//

import SwiftUI

/// スライドの表示言語
public enum SlideLanguage: String, CaseIterable, Identifiable, Sendable {
    case japanese = "ja"
    case english = "en"

    public var id: String { rawValue }

    /// メニューに出す名前(その言語自身での呼び名)
    public var displayName: String {
        switch self {
        case .japanese: "日本語"
        case .english: "English"
        }
    }

    public var locale: Locale { Locale(identifier: rawValue) }

    /// アプリに適用されている言語(OS の設定アプリで選んだ言語。日本語以外は英語にする)
    public static var appDefault: SlideLanguage {
        // 先頭が「どれにも当てはまらないとき」の既定になるので、英語を先に置く
        let preferred = Bundle.preferredLocalizations(from: [english.rawValue, japanese.rawValue]).first
        return preferred == japanese.rawValue ? .japanese : .english
    }
}

/// 表示言語の現在値。スライドの文言は描画のたびにここを見て String Catalog から引く。
public final class SlideLanguageStore: ObservableObject, @unchecked Sendable {
    public static let shared = SlideLanguageStore()

    @Published public var language: SlideLanguage = .appDefault

    private let lock = NSLock()
    private var bundleCache: [String: Bundle] = [:]

    private init() {}

    /// スライドを開いたときに呼ぶ: アプリに適用されている言語に戻す
    public func resetToAppDefault() {
        let appDefault = SlideLanguage.appDefault
        if language != appDefault { language = appDefault }
    }

    /// `bundle` の String Catalog から、いまの表示言語の文言を引く。
    /// キーは日本語の文言そのもの。訳が無いキーや、その言語のリソースが無いときはキーをそのまま返す。
    public func localized(_ key: String, bundle: Bundle) -> String {
        guard let languageBundle = languageBundle(in: bundle, language: language) else { return key }
        return languageBundle.localizedString(forKey: key, value: key, table: nil)
    }

    private func languageBundle(in bundle: Bundle, language: SlideLanguage) -> Bundle? {
        let cacheKey = "\(bundle.bundlePath)|\(language.rawValue)"
        lock.lock()
        defer { lock.unlock() }
        if let cached = bundleCache[cacheKey] { return cached }
        guard let path = bundle.path(forResource: language.rawValue, ofType: "lproj"),
              let languageBundle = Bundle(path: path) else { return nil }
        bundleCache[cacheKey] = languageBundle
        return languageBundle
    }
}

private struct SlideLanguageFollower: ViewModifier {
    @ObservedObject private var store = SlideLanguageStore.shared

    func body(content: Content) -> some View {
        content
            // 文言は描画時に引くので、言語が変わったら作り直して引き直させる
            .id(store.language)
            .environment(\.locale, store.language.locale)
    }
}

public extension View {
    /// 表示言語(SlideLanguageStore)が切り替わったら、中のスライドを作り直して文言を引き直す
    func followsSlideLanguage() -> some View {
        modifier(SlideLanguageFollower())
    }
}
