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
    }

    @Published public private(set) var presentation: Presentation?

    private init() {}

    /// スライド表示開始時に呼ぶ。既に別デッキが登録されていても上書きする(最後に開いたデッキが勝つ)。
    public func attach(_ slideIndexController: SlideIndexController, slideTheme: CustomSlideTheme) {
        presentation = Presentation(slideIndexController: slideIndexController, slideTheme: slideTheme)
    }

    /// スライドを閉じたときに呼ぶ。他のデッキに切り替わった後で古い方の onDisappear が
    /// 走っても新しい登録を消さないよう、同じコントローラのときだけ解除する。
    public func detach(_ slideIndexController: SlideIndexController) {
        guard presentation?.slideIndexController === slideIndexController else { return }
        presentation = nil
    }
}
