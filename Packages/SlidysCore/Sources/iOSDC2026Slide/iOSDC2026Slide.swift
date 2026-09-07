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

public struct iOSDC2026SlideView: SlideViewProtocol {
    let configuration = SlideConfiguration()

    public init() {}

    public var body: some View {
        // 総ページ数を出すと締めのネタ(次回予告)の存在が予想できてしまうため、現在ページ番号のみ表示する
        SlideBaseView(
            slideConfiguration: configuration,
            timerDuration: Duration.seconds(60 * 20),
            showsTotalSlideCount: false,
            listTextStyle: .large
        )
    }
}

public extension iOSDC2026SlideView {
    /// スクリーンショット書き出しなどの自動化ツール向けに、デッキの SlideIndexController を生成して返す。
    @MainActor static func makeSlideIndexController() -> SlideIndexController {
        SlideConfiguration().slideIndexController
    }

    /// このデッキで使っているリスト文字サイズ(自動化ツールが同じ見た目で描画するために公開)。
    static let listTextStyle: ListTextStyle = .large
}

struct SlideConfiguration: SlideConfigurationProtocol {
    @MainActor
    let slideIndexController = SlideIndexController {
        CenterTextSlide(text: "iOSDC Japan 2026")

        // つかみ
        CenterTextSlide(text: "みなさん")
        CenterTextSlide(text: "アニメやゲーム、映画を見ながら\nかっこいいな、すごいなと思った\n場面はないでしょうか？")
        CenterTextSlide(text: "その場面を見ながら、\n「自分もこんな体験をしてみたい」と\n思ったことはないでしょうか？")
        CenterTextSlide(text: "空間コンピューティングデバイスの\n登場で、その憧れを自分の\n手で実装しやすい時代\nになりました")

        TitleSlide()
        ReadmeSlide(
            title: "README",
            info: .init(
                name: "すぎー/Sugiy",
                image: .icon,
                firstText: "iOS/Flutterエンジニアです",
                secondText: "iOSDCのスタッフもしてます",
                thirdText: "最近車を買いました",
                fourthText: "3Dプリンターも買いました。お金が...💸",
                fifthText: "こないだまで庭でメロンを育ててました"
            )
        )
        PastTalksSlide()
        TalkPlanSlide()

        // デモ1: 最初に一連の流れを全部見せる(たい焼きのモンスターを召喚するまで)
        LiveDemoSlide(title: "デモ 1", caption: "カードを引いて、手札に加えて、\n配置して、召喚するまで")
        VideoSlide(videoType: .duelDemoFull) // デモ1の保険動画

        // 1. 3Dモデルを用意して表示する
        ChapterDividerSlide(activeIndex: 0)
        BlenderModelingSlide()
        ModelPipelineSlide()
        RcpUsageSlide()
        BlenderMcpSlide()
        NodeContractSlide()
        LocatorShowcaseSlide()
        MonsterVariationSlide()

        // 2. Hand Gestureでカードを操作する
        ChapterDividerSlide(activeIndex: 1)
        TrackingSetupSlide()
        TrackingGestureListSlide()
        HandFanSlide()
        DeckDrawSlide()
        CardPlacementSlide()

        // 3. エフェクトとアニメーションで演出する
        ChapterDividerSlide(activeIndex: 2)
        SummonSequenceSlide()

        // デモ2: 終盤のライブデモ(竜のモンスターの召喚)。パーティクルの説明はデモの後
        LiveDemoSlide(title: "デモ 2", caption: "別のモンスターを召喚する")
        VideoSlide(videoType: .duelDemoDragon) // デモ2の保険動画
        ParticleEffectSlide()
        DragonSummonMakingSlide()

        // iOS/iPadOSへの応用
        TaiyakiFocusSlide()

        // まとめ
        LimitationsSlide()
        WrapUpSlide()
        ReferenceSlide()

        // 締め: アニメの次回予告風
        CenterTextSlide(text: "この発表を機に、みなさんも\n何か自分が作ってみたいものを\n作ってもらえるとうれしいです！")

        // One more thing: Swiftだけでたい焼きを生成するおまけデモ
        CenterTextSlide(text: "おわり")
        OneMoreThingSlide()
        CenterTextSlide(text: "最近出たAstraがすごいという\n情報を見たので、\n私のアイコンを作らせてみた")
        AstraIconCompareSlide()
        TaiyakiRealityKitDemoSlide()
        CenterTextSlide(text: "AIすごいな")

        CenterTextSlide(text: "おっと、そろそろ時間が")
        CenterTextSlide(text: "今ここで終わったら、残りの\nスライドはどうなっちゃうの？")
        CenterTextSlide(text: "時間はまだ残ってる。(？)")
        CenterTextSlide(text: "ここを耐えれば、発表は無事終わるんだから！")
        NextEpisodePreviewSlide(mainText: "城⚫︎内死す")
        NextEpisodePreviewSlide(
            content: .imageWithQR(image: .kanagawaSwiftEvent, qrImage: .qrKanagawaEvent)
        )
        CenterTextSlide(text: "デュエルスタンバイ！")
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
