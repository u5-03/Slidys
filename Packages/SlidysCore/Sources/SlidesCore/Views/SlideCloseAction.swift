//
//  SlideCloseAction.swift
//  SlidesCore
//
//  スライド画面を閉じる操作。呼び出し側(SlidysCommonView など)が環境値で渡し、
//  SlideBaseView の発表者メニューの「スライドを閉じる」から呼ぶ。
//

import SwiftUI

private struct SlideCloseActionKey: EnvironmentKey {
    static let defaultValue: (() -> Void)? = nil
}

public extension EnvironmentValues {
    /// スライド画面を閉じる操作(nil なら閉じる項目を出さない)
    var slideCloseAction: (() -> Void)? {
        get { self[SlideCloseActionKey.self] }
        set { self[SlideCloseActionKey.self] = newValue }
    }
}
