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
//   - 自己紹介に社名は入れない。起票先のリポジトリ名などの固有名詞も出さない
//

import Foundation
import SlideKit
import SwiftUI
import SlidesCore

public struct SlideConfiguration: SlideConfigurationProtocol {

    @MainActor
    public let slideIndexController = SlideIndexController(index: 0) {
        CenterTextSlide(text: "FlutterKaigi 2026", script: "(登壇前の待機スライド。話し始めたら次へ)")

        // つかみ: いつもの質問から
        CenterTextSlide(text: "みなさん", script: "みなさん。")
        CenterTextSlide(text: "エンジニアの人？", script: "エンジニアの人、手を挙げてもらえますか？")
        CenterTextSlide(text: "QAテストをしたことある人？", script: "QAテストをしたことある人？")
        CenterTextSlide(text: "バグチケットの対応を\nしたことある人？", script: "バグチケットの対応をしたことある人？")
        CenterTextSlide(
            text: "バグチケットの対応は\n場合によっては大変なことが多い",
            script: "バグチケットの対応って、場合によってはけっこう大変ですよね。"
        )
        CenterTextSlide(
            text: "再現手順がない\nOS・デバイス・ビルド番号がわからない\n画像や動画の添付がない\n…で困ったことはないでしょうか？",
            font: .mediumFont,
            script: "例えば、再現手順が書かれていない。OSやデバイスの種類、ビルド番号がわからない。画像や動画の添付がない。そんな状態でバグ修正のときに困った方もいるのではないでしょうか？"
        )
        CenterTextSlide(
            text: "もちろん、チケットを起票する人も\n書くのは大変です",
            script: "もちろん、チケットを起票する側も、それを全部書くのは大変です。"
        )
        CenterTextSlide(
            text: "できる限り省力化して\nチケットを起票する方法の一例を\nお話しします",
            script: "そこで今日は、できる限り省力化してチケットを起票する方法の一例をお話しします。"
        )

        TitleSlide()
        Readme2026Slide()
        IOSFeedbackOverviewSlide()
        TalkPlanSlide()

        // 最初に Flutter 版の一連の流れを実機で見せる(「デモ」とは銘打たない)
        FlutterEmbedSlide(
            title: "Flutterで作ってみた",
            points: [
                "フローティングボタンから起票画面を開く",
                "「画面から選ぶ」で対象のWidgetをタップして選ぶ(選んだWidgetが枠で囲まれる)",
                "タイトルと一言を書いて送信 → 情報が揃ったIssueに",
            ],
            type: .feedbackDemo,
            script: "これが Flutter で作ったものです。右のアプリで、フローティングボタンから起票画面を開いて、対象の Widget をタップして選び、タイトルと一言だけ書いて送信するまでをお見せします。"
        )

        // 1. 画面上のWidgetをタップして選ぶ
        ChapterDividerSlide(activeIndex: 0, script: "ではまず1つ目、画面上のWidgetをタップして選ぶ仕組みです。")
        PickerMotivationSlide()
        ElementPickerFlowSlide()
        ThreeTreesSlide()
        ElementPickerInsightsSlide()
        CenterTextSlide(
            text: "Widgetツリーは設計図。\n画面に出ているのはElementとRenderObject。\nだから“タップして選ぶ”にはElementを歩く",
            font: .mediumFont,
            script: "Widgetツリーは設計図。実際に画面に出ているのはElementとRenderObject。だから「タップして選ぶ」にはElementを歩くんです。"
        )

        // 2. 静止画リングバッファ + デバイスで動画化
        ChapterDividerSlide(activeIndex: 1, script: "次に2つ目、静止画のリングバッファをデバイスで動画化する話です。")
        ReplayMotivationSlide()
        ReplayStepsSlide()
        ReplayDesignBranchSlide()
        ReplayCaveatsSlide()

        // 3. Widget階層・ログ・環境情報を添付する
        ChapterDividerSlide(activeIndex: 2, script: "最後に3つ目、Widget階層・ログ・環境情報を一緒にチケットに添付する話です。")
        DiagnosticsMotivationSlide()
        DiagnosticsTableSlide()
        WidgetTreeSlide()
        LogBufferSlide()
        IssueBodySlide()
        ServerPipelineSlide()

        // まとめ
        BeforeAfterSlide()
        WrapUpSlide()
        CenterTextSlide(
            text: "観測できないものは直せない。\nまず“観測できるアプリ”にしよう",
            font: .mediumFont,
            script: "観測できないものは直せない。まず「観測できるアプリ」にしよう。というのが締めの一言です。"
        )
        ReferenceSlide()
        EndSlide()
    }

    public init() {}
}
