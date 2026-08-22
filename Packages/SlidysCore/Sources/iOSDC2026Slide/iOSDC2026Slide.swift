//
//  iOSDC2026Slide.swift
//  iOSDC2026Slide
//
//  iOSDC Japan 2026「「いつかやってみたかった」を形にする -アニメのカードバトルを再現するまで-」
//  のスライド定義。
//  NOTE: 発表では作品名(遊戯王など)を出さない方針。スライド文言に固有名詞を入れないこと。
//

import SlideKit
import SlidesCore
import SwiftUI

public struct iOSDC2026SlideView: SlideViewProtocol {
    let configuration = SlideConfiguration()

    public init() {}

    public var body: some View {
        SlideBaseView(slideConfiguration: configuration, timerDuration: Duration.seconds(60 * 20))
    }
}

struct SlideConfiguration: SlideConfigurationProtocol {
    @MainActor
    let slideIndexController = SlideIndexController {
        CenterTextSlide(text: "iOSDC Japan 2026")

        // つかみ: プロポーザル冒頭の問いかけから入る
        CenterTextSlide(text: "アニメやゲーム、映画を見ながら\n「自分もこんな体験をしてみたい」と\n思ったことはないでしょうか")
        CenterTextSlide(text: "空間コンピューティングデバイスの登場で、\nその憧れを自分の手で実装できる\n時代になりました")
        CenterTextSlide(text: "今回はアニメのカードバトルを\nApple Vision Proで再現します！")

        TitleSlide()
        PrequelSlide()
        ReadmeSlide(
            title: "README",
            info: .init(
                name: "すぎー/Sugiy",
                image: .icon,
                firstText: "DeNAでFlutterのスポーツ系ライブ配信アプリplay-by-sports開発中",
                secondText: "iOSDCのスタッフしてます",
                thirdText: "最近車を買いました🚗",
                fourthText: "3Dプリンターも買いました。ものづくりが捗っています🖨️",
                fifthText: "" // TODO: 5つ目の近況ネタが決まったら差し替え
            )
        )
        TalkPlanSlide()

        // 1. 3Dモデルを用意して表示する
        CenterTextSlide(text: "1. 3Dモデルを用意して表示する")
        ModelPipelineSlide()
        NodeContractSlide()
        ModelLoadingSlide()
        CoordinateGotchaSlide()
        MonsterVariationSlide()
        // TODO: Blenderモデリング画面 or 完成モデルの画像/動画スライドを追加

        // 2. Hand Gestureでカードを操作する
        CenterTextSlide(text: "2. Hand Gestureで\nカードを操作できるようにする")
        TrackingSetupSlide()
        WristAttachmentSlide()
        HandFanSlide()
        DeckDrawSlide()
        CardPlacementSlide()
        DuelDemoSlide()
        // TODO: デモのバックアップ動画スライド(VideoSlide)を追加

        // 3. エフェクトとアニメーションで演出する
        CenterTextSlide(text: "3. エフェクトとアニメーションで\nそれらしい体験にする")
        SummonSequenceSlide()
        ParticleEffectSlide()
        MonsterRevealSlide()
        CardAttachmentSlide()
        // TODO: 召喚エフェクトのデモ動画スライドを追加

        // まとめ
        LimitationsSlide()
        PossibilitiesSlide()
        WrapUpSlide()
        ReferenceSlide()
        CenterTextSlide(text: "おわり")
        EndSlide()
    }
}
