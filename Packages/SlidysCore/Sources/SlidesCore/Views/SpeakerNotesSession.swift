//
//  SpeakerNotesSession.swift
//  SlidesCore
//
//  発表中のスライドデッキ(SlideIndexController)を、別Scene/Windowで開く
//  スピーカーノート画面(iPhone Duo の内側ディスプレイなど)と共有するためのセッション。
//
//  SwiftUI の WindowGroup(id:for:) は Codable/Hashable な値しか受け渡せず、
//  SlideIndexController(ObservableObject)は渡せないため、プロセス内シングルトンで共有する。
//  SlideBaseView が表示中に attach し、閉じたときに detach する。
//

import SlideKit
import SwiftUI

@MainActor
public final class SpeakerNotesSession: ObservableObject {
    public static let shared = SpeakerNotesSession()

    /// ノート画面が購読する対象。スライド未表示なら nil。
    public struct Presentation {
        public let slideIndexController: SlideIndexController
        public let slideTheme: CustomSlideTheme
        /// 外部ディスプレイ用のスライドに環境値(Flutter の Router など)を付け直す処理。nil ならそのまま描く
        public let externalDisplaySlideDecorator: ExternalDisplaySlideDecorator?
    }

    @Published public private(set) var presentation: Presentation?

    /// 経過時間の起点。ノート画面(SpeakerNotesView)が表示のたびに作り直されても、
    /// 「手元にもスライドを表示」→「外部ディスプレイに出力」の往復で時間がリセットされないよう、ここで持つ
    @Published public var timerStartDate = Date()

    private init() {}

    /// スライド表示開始時に呼ぶ。既に別デッキが登録されていても上書きする(最後に開いたデッキが勝つ)。
    /// 別のデッキに切り替わったときだけ経過時間を 0 に戻す(同じデッキの再登録では保つ)。
    public func attach(
        _ slideIndexController: SlideIndexController,
        slideTheme: CustomSlideTheme,
        externalDisplaySlideDecorator: ExternalDisplaySlideDecorator? = nil
    ) {
        if presentation?.slideIndexController !== slideIndexController {
            timerStartDate = Date()
        }
        presentation = Presentation(
            slideIndexController: slideIndexController,
            slideTheme: slideTheme,
            externalDisplaySlideDecorator: externalDisplaySlideDecorator
        )
    }

    /// スライドを閉じたときに呼ぶ。他のデッキに切り替わった後で古い方の onDisappear が
    /// 走っても新しい登録を消さないよう、同じコントローラのときだけ解除する。
    public func detach(_ slideIndexController: SlideIndexController) {
        guard presentation?.slideIndexController === slideIndexController else { return }
        presentation = nil
    }
}
