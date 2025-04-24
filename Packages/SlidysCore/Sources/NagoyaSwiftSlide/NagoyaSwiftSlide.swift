import SwiftUI
import SlideKit
import SlidesCore
import SymbolKit

public struct NagoyaSwiftSlideView: SlideViewProtocol {
    let configuration = SlideConfiguration()

    public init() {}

    public var body: some View {
        SlideBaseView(slideConfiguration: configuration)
    }
}

struct SlideConfiguration: SlideConfigurationProtocol {
    let slideIndexController = SlideIndexController() {
        CenterTextSlide(text: "Nagoya.swift #1")
        CenterTextSlide(text: "※今回はSwiftUIのパスのアニメーションやそれを使ったシンボルクイズは出ません！")
        CenterTextSlide(text: "本題")
        CenterTextSlide(text: "みなさんは思ったことはありませんか？")
        CenterTextSlide(text: "Blurってなに？")
        HospitalSlide()
        TitleSlide()
        ReadmeSlide(
            title: "README",
            info: .init(
                name: "すぎー/Sugiy",
                image: .icon,
                firstText: "DeNAでFlutterのスポーツ系ライブ配信アプリplay-by-sports開発中",
                secondText: "神山.swiftからJapan-\\\\(Region)-Swiftコンプリート中",
                thirdText: "1月に岐阜(minokamo.swift)に来たとき以来の名古屋！",
                fourthText: "今月try!SwiftTokyo2025で登壇して、来月FlutterNinjas2025でも登壇",
                fifthText: "再来月からの家のBuildに向け、土地の雑草抜きを絶賛計画中..!"
            )
        )
        BlurSummarySlide()
        GaussianBlurSlide()
        BlurEffectComparisonSlide()
        CenterTextSlide(text: "なるほど？")
        CenterTextSlide(text: "ちょっと試しに実装してみよう")
        ContentSlide(headerTitle: "SwiftUIでBlurのUIを再現") {
            PixelImageSettingView(imageResource: .icon, isBlurred: true, dimension: 50, blurDistance: 5)
        }
        CenterTextSlide(text: "めちゃくちゃ処理重い....")
        CenterTextSlide(text: "パフォーマンス向上の\nリファクタリングチャレンジの\n挑戦者、募集中！", alignment: .center)
        HospitalSlide()
        VideoSlide(videoType: .bookAnimation)
        CenterTextSlide(text: "なんか入院中のパフォーマンスが高い？笑")
        CenterTextSlide(text: "じゃあ最後に！")
        QuizTitleSlide(regionKind: .aichi)
        CenterTextSlide(text: "固まったら、ごめんなさい🙇")
        ContentSlide(headerTitle: "愛知シンボルクイズ") {
            PixelImageSettingView(imageResource: .morizoKikkoroQuiz, isBlurred: true, dimension: 50, blurDistance: 20)
        }
        CenterImageSlide(imageResource: .morizoKikkoroQuiz)
        CenterImageSlide(imageResource: .morizoKikkoroAnswer)

        WrapUpSlide()
        ReferenceSlide()
        JapanRegionSwiftMapSlide()
        CenterTextSlide(text: "またどこかの\nJapan-\\(region).swiftで\n会いましょう！")
        ShareEndSlide()
        OneMoreThingSlide()
        CenterTextSlide(text: "実はJapan-\\(region).swiftの特別イベントが...")
        CenterImageSlide(imageResource: .regionWwdcRecap)
    }
}
