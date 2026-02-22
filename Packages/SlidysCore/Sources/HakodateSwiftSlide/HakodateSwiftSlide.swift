import SwiftUI
import SlideKit
import SlidesCore

public struct HakodateSwiftSlideView: SlideViewProtocol {
    let configuration = SlideConfiguration()

    public init() {}

    public var body: some View {
        SlideBaseView(slideConfiguration: configuration, showSlideIndex: false)
    }
}

struct SlideConfiguration: SlideConfigurationProtocol {
    @MainActor
    let slideIndexController = SlideIndexController() {
        CenterTextSlide(text: "Hakodate.swift")
        CenterTextSlide(text: "みなさん")
        CenterTextSlide(text: "日頃、姿勢は気にしていますか？")
        CenterTextSlide(text: "特に作業中！")
        CenterImageSlide(imageResource: .computerTabletMan)
        CenterTextSlide(text: "しかし姿勢を意識するのはむずかしい")
        CenterTextSlide(text: "我らがiPhoneだけだと解決難しい")
        CenterTextSlide(text: "💡", font: .extraLargeFont)
        ViewSlide {
            Image(systemName: "airpods.pro")
                .resizable()
                .scaledToFit()
                .frame(width: 400)
        }
        HeadMotionIntroductionSlide()
        TitleSlide()
        ReadmeSlide(
            title: "README",
            info: .init(
                name: "すぎー/Sugiy",
                image: .icon,
                firstText: "北海道と青森、初上陸！",
                secondText: "DeNAでアニメDX系のiPadアプリを開発中",
                thirdText: "毎年11月に実施するKanagawa.swiftの運営もしています(#2ではAppleインディアンポーカーなどをやってました)",
                fourthText: "今年の目標は個人開発を頑張る💪",
                fifthText: "昨日の人生初スケートでの疲労ダメージがでかい笑"
            )
        )
        CenterTextSlide(text: "今日は本当にSymbolQuizはありません！")
        CenterTextSlide(text: "どうやってAirPodsのモーションを取得するの？")
        WebViewSlide(url: URL(string: "https://developer.apple.com/documentation/coremotion/cmheadphonemotionmanager")!)
        DemoAirPodsMotionSlide()
        WebViewSlide(url: URL(string: "https://developer.apple.com/documentation/coremotion/cmdevicemotion")!)
        CMDeviceMotionDescriptionSlide()
        
        CenterTextSlide(text: "質問です！")
        CenterImageTitleSlide(title: "この状態でもモーション検知はできるでしょうか？", imageResource: .audioStatusNotConnected)
        CenterTextSlide(text: "正解発表")
        Quiz1AnswerSlide()

        CenterTextSlide(text: "質問2です！")
        WebTitleSlide(title: "以前こんな発表をしました！", url: URL(string: "https://ulog.sugiy.com/multi-airpods-audio/")!)
        CenterTextSlide(text: "AirPodsを複数接続した時はどうでしょう？")
        CenterTextSlide(text: "正解発表")
        Quiz2AnswerSlide()
        CenterTextSlide(text: "感想: Appleデバイスは奥深い！")
        CenterTextSlide(text: "終わり")
        CenterTextSlide(text: "延長線")
        RegionSymbolQuizSlide()
        QuizTitleSlide(regionKind: .hokkaido, isAlmostSymbol: true)
        HakodateSymbolQuizSlide()
    }
}
