//
//  SlideConfiguration.swift
//  FlutterKaigi2026Slide
//
//  FlutterKaigi 2026 LT「その不具合、どのWidgetですか？ ― アプリ内で“直せるバグ報告”を作る」(10分)
//  のスライド定義。
//  方針:
//   - スライドはシンプルに、口頭の説明を主役にする(スライドを読ませない)
//   - コードは出さない(AIに書かせる人が多いので、大枠と「どこが壁だったか」だけ話す)
//   - 「デモ」と銘打ったスライドは作らず、Flutter の実機画面(FlutterView)を各章の説明スライドに埋め込む
//     (一連の流れをまとめて見せるページも置かない。各章のデモで十分なため)
//   - 自己紹介に社名は入れない。起票先のリポジトリ名などの固有名詞も出さない
//

import Foundation
import SlideKit
import SwiftUI
import SlidesCore

public struct SlideConfiguration: SlideConfigurationProtocol {

    /// 日本語 / 英語に対応(文言は Localizable.xcstrings)。発表者メニューから切り替えられる
    public let supportedLanguages: [SlideLanguage] = [.japanese, .english]

    @MainActor
    public let slideIndexController = SlideIndexController(index: 0) {
        centerText("FlutterKaigi 2026", script: "(登壇前の待機スライド。話し始めたら次へ)")

        // つかみ: いつもの質問から
        centerText("みなさん", script: "みなさん。")
        centerText("エンジニアの人？", script: "エンジニアの人、手を挙げてもらえますか？")
        centerText("バグチケットの対応を\nしたことある人？", script: "バグチケットの対応をしたことある人？")
        centerText("QAテストをしたことある人？", script: "QAテストをしたことある人？")
        centerText(
            "バグチケットの対応は\n場合によっては大変なことが多い",
            script: "バグチケットの対応って、場合によってはけっこう大変ですよね。"
        )
        // 足りない情報を吹き出しで 1 つずつ → 最後に「起票も大変」
        BugTicketPainSlide()
        centerText(
            "できる限り省力化して\nチケットを起票する方法の一例を\nお話しします",
            script: "そこで今日は、できる限り省力化してチケットを起票する方法の一例をお話しします。"
        )

        TitleSlide()
        Readme2026Slide()
        IOSFeedbackOverviewSlide()
        TalkPlanSlide()

        // 1. 画面上のWidgetをタップして選ぶ
        ChapterDividerSlide(activeIndex: 0, script: "ではまず1つ目、画面上のWidgetをタップして選ぶ仕組みです。")
        PickerMotivationSlide()
        ElementPickerFlowSlide()
        ThreeTreesSlide()
        ElementPickerInsightsSlide()

        // 2. 静止画リングバッファ + デバイスで動画化
        ChapterDividerSlide(activeIndex: 1, script: "次に2つ目、静止画のリングバッファをデバイスで動画化する話です。")
        ReplayMotivationSlide()
        ReplayStepsSlide()
        ReplayCaveatsSlide()

        // 3. Widget階層・ログ・環境情報を添付する
        ChapterDividerSlide(activeIndex: 2, script: "最後に3つ目、Widget階層・ログ・環境情報を一緒にチケットに添付する話です。")
        DiagnosticsTableSlide()
        LogBufferSlide()
        ServerPipelineSlide()

        // まとめ
        MotivationSlide()
        QAFeedbackSlide()
        WrapUpSlide()

        // 締め
        centerText("終わり", script: "以上です。ご清聴ありがとうございました！")
    }

    public init() {}
}

/// 中央に 1 文だけ出すスライド。文言はこのデッキの String Catalog から表示言語で引く(キーは日本語の文言)
private func centerText(_ text: String, script: String) -> CenterTextSlide {
    CenterTextSlide(text: text, localizationBundle: .module, script: script)
}
