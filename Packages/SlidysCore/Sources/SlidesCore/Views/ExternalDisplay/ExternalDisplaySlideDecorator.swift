//
//  ExternalDisplaySlideDecorator.swift
//  SlidesCore
//
//  外部ディスプレイ(presentation モード)は、手元とは別の UIWindow に SlideRouterView を描画する。
//  その Window は SwiftUI の階層の外で作られるため、デッキが `.environment(...)` で注入した値
//  (Flutter の Router など)が届かず、埋め込み View が空になってしまう。
//  デッキ側はこのデコレーターで「外部ディスプレイ用のスライドにも同じ環境値を付ける」処理を登録する。
//

import SwiftUI

/// 外部ディスプレイに描くスライド(SlideRouterView)に環境値などを付け直すための関数
public typealias ExternalDisplaySlideDecorator = @MainActor (AnyView) -> AnyView

private struct ExternalDisplaySlideDecoratorKey: EnvironmentKey {
    static let defaultValue: ExternalDisplaySlideDecorator? = nil
}

public extension EnvironmentValues {
    /// デッキが外部ディスプレイ用のスライドに施す装飾(環境値の注入など)。SlideBaseView が拾って
    /// SpeakerNotesSession に渡し、ExternalDisplayCoordinator が外部ディスプレイの描画時に適用する。
    var externalDisplaySlideDecorator: ExternalDisplaySlideDecorator? {
        get { self[ExternalDisplaySlideDecoratorKey.self] }
        set { self[ExternalDisplaySlideDecoratorKey.self] = newValue }
    }
}
