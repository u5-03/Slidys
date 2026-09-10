//
//  iOSDC2026Slide.swift
//  iOSDC2026Slide
//
//  iOSDC Japan 2026「「いつかやってみたかった」を形にする -アニメのカードバトルを再現するまで-」
//  のスライド定義。
//  方針:
//   - 文字とコードは最小限にし、話す内容を主役にする(コードの詳細はブログに誘導)
//   - 聞き疲れ防止のため、各章の間にデモ・動画・画像を挟む(MediaPlaceholderSlide は素材が揃い次第差し替え)
//   - 発表では作品名(遊戯王など)を出さない。自己紹介に社名は入れない
//

import SlideKit
import SlidesCore
import SwiftUI

extension ListTextStyle {
    /// iOSDC2026用: キーポイント化で短くなった本文を、大きめの文字と広めの行間で見せる。
    /// 数値を変えればデッキ全体の文字サイズ・行間をまとめて調整できる。
    static let iosdc2026 = ListTextStyle(
        contentFontSize: 68,
        contentSpacing: 64,
        contentLineSpacing: 14,
        headerFontSize: 84,
        headerHeight: 120
    )
}

public struct iOSDC2026SlideView: SlideViewProtocol {
    let configuration = SlideConfiguration()

    public init() {}

    public var body: some View {
        // 総ページ数を出すと締めのネタ(次回予告)の存在が予想できてしまうため、現在ページ番号のみ表示する
        SlideBaseView(
            slideConfiguration: configuration,
            timerDuration: Duration.seconds(60 * 20),
            showsTotalSlideCount: false,
            listTextStyle: .iosdc2026
        )
    }
}

public extension iOSDC2026SlideView {
    /// スクリーンショット書き出しなどの自動化ツール向けに、デッキの SlideIndexController を生成して返す。
    @MainActor static func makeSlideIndexController() -> SlideIndexController {
        SlideConfiguration().slideIndexController
    }

    /// このデッキで使っているリスト文字サイズ(自動化ツールが同じ見た目で描画するために公開)。
    static let listTextStyle: ListTextStyle = .iosdc2026
}

struct SlideConfiguration: SlideConfigurationProtocol {
    @MainActor
    let slideIndexController = SlideIndexController {
        CenterTextSlide(text: "iOSDC Japan 2026", script: "(登壇前の待機スライド。話し始めたら次へ)")

        // つかみ
        CenterTextSlide(text: "みなさん", script: "みなさん。")
        CenterTextSlide(
            text: "アニメやゲーム、映画を見ながら\nかっこいいな、すごいなと思った\n場面はないでしょうか？",
            script: "アニメやゲーム、映画を見ながら、「かっこいいな」「すごいな」と思った場面はないですか？"
        )
        CenterTextSlide(
            text: "その場面を見ながら、\n「自分もこんな体験をしてみたい」と\n思ったことはないでしょうか？",
            script: "そして、その場面を見ながら、「自分もこんな体験をしてみたいなー」と思ったことはないですか？"
        )
        CenterTextSlide(
            text: "空間コンピューティングデバイスの\n登場で、その憧れを自分の\n手で実装しやすい時代\nになりました",
            script: "空間コンピューティングデバイスの登場で、その憧れを自分の手で実装しやすい時代になりました。今日はその実例の話をします。"
        )

        TitleSlide()
        // 自己紹介は項目が多いので、従来スタイルで収めるラッパーを使う
        Readme2026Slide()
        PastTalksSlide()
        TalkPlanSlide()

        // デモ1: 最初に一連の流れを全部見せる(たい焼きのモンスターを召喚するまで)
        LiveDemoSlide(
            title: "デモ 1",
            caption: "カードを引いて、手札に加えて、\n配置して、召喚するまで",
            script: "まずはデモします。カードを引いて、手札に加えて、配置し、そのカードを召喚する様子を紹介します。"
        )
        VideoSlide(
            videoType: .duelDemoFull, // デモ1の保険動画
            script: "(デモ失敗時のみ使用。「実機デモの神様が不在のようなので、動画でご覧ください」。成功時はスキップ)"
        )

        // 1. 3Dモデルを用意して表示する
        ChapterDividerSlide(activeIndex: 0, script: "ではまずは「3Dモデルを用意して表示する」から始めます。")
        BlenderModelingSlide()
        ModelPipelineSlide()
        RcpUsageSlide()
        BlenderMcpSlide()
        NodeContractSlide()
        LocatorShowcaseSlide()
        MonsterVariationSlide()

        // 2. Hand Gestureでカードを操作する
        ChapterDividerSlide(activeIndex: 1, script: "それでは次に、Hand Gestureについてです。")
        TrackingSetupSlide()
        TrackingGestureListSlide()
        HandFanSlide()
        DeckDrawSlide()
        CardPlacementSlide()

        // 3. エフェクトとアニメーションで演出する
        ChapterDividerSlide(activeIndex: 2, script: "では最後にエフェクトとアニメーションです。")
        SummonSequenceSlide()

        // デモ2: 終盤のライブデモ(竜のモンスターの召喚)。パーティクルの説明はデモの後
        LiveDemoSlide(
            title: "デモ 2",
            caption: "別のモンスターを召喚する",
            script: "では別のデモをしましょう"
        )
        VideoSlide(
            videoType: .duelDemoDragon, // デモ2の保険動画
            script: "(デモ失敗時のみ使用。動画を流しながら「動画でご覧ください。こういう竜が召喚されます」)"
        )
        ParticleEffectSlide()
        DragonSummonMakingSlide()

        // iOS/iPadOSへの応用
        TaiyakiFocusSlide()

        // まとめ
        LimitationsSlide()
        WrapUpSlide()
        ReferenceSlide()

        // 締め: アニメの次回予告風
        CenterTextSlide(
            text: "この発表を機に、みなさんも\n何か自分が作ってみたいものを\n作ってもらえるとうれしいです！",
            script: "この発表を機に、みなさんも何か自分が「作ってみたかったもの」を作ってもらえるとうれしいです！"
        )

        // One more thing: Swiftだけでたい焼きを生成するおまけデモ
        CenterTextSlide(text: "おわり", script: "(「おわり」")
        OneMoreThingSlide(script: "ではなく実はもう少しだけ続きます。")
        CenterTextSlide(
            text: "最近出たAstraがすごいという\n情報をXで見たので、\n私のアイコンを作らせてみた",
            script: "最近出たAstraがすごいという情報をXで見たので、私のアイコンを作らせてみました。"
        )
        AstraIconCompareSlide()
        TaiyakiRealityKitDemoSlide()
        CenterTextSlide(text: "AIすごいな", script: "AIすごいな。という感想でした。AIの発展でより一層3Dモデル作成のハードルが下がっていきそうですね。")

        CenterTextSlide(text: "おっと、そろそろ時間が", script: "おっと、そろそろ時間が。")
        CenterTextSlide(
            text: "今ここで終わったら、残りの\nスライドはどうなっちゃうの？",
            script: "今ここで終わったら、残りのスライドはどうなっちゃうの？"
        )
        CenterTextSlide(text: "時間はまだ残ってる。(？)", script: "時間はまだ残ってる。")
        CenterTextSlide(
            text: "ここを耐えれば、発表は無事終わるんだから！",
            script: "ここを耐えれば、発表は無事終わるんだから！次回"
        )
        NextEpisodePreviewSlide(
            mainText: "城⚫︎内死す",
            script: ""
        )
        NextEpisodePreviewSlide(
            content: .imageWithQR(image: .kanagawaSwiftEvent, qrImage: .qrKanagawaEvent),
            script: ""
        )
        CenterTextSlide(text: "デュエルスタンバイ！", script: "デュエルスタンバイ！")
        EndSlide()
    }
}

#Preview("発表モード") {
    iOSDC2026SlideView()
}

#Preview("スライド一覧(グリッド)", traits: .fixedLayout(width: 1400, height: 1080)) {
    // ウィンドウサイズは fixedLayout で確保し、中身(固有サイズのグリッド)はスクロールで見る。
    // ライブプレビュー(▶)にするとトラックパッドで縦横スクロールできる。
    ScrollView([.vertical, .horizontal]) {
        SlideGridView(
            slideIndexController: iOSDC2026SlideView.makeSlideIndexController(),
            listTextStyle: iOSDC2026SlideView.listTextStyle,
            columns: 3,
            tileWidth: 456
        )
    }
}
