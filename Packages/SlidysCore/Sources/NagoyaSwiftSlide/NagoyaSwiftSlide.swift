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
        CenterTextSlide(text: "Nagoya.swift！")
        CenterTextSlide(text: "※今回はSwiftUIのパスのアニメーションやそれを使ったシンボルクイズは出てきません！")
        CenterTextSlide(text: "みなさんは思ったことはありませんか？")
        CenterTextSlide(text: "Blurってなに？")
        HospitalSlide()
        TitleSlide()
        ReadmeSlide(
            title: "README",
            info: .init(
                name: "すぎー/Sugiy",
                image: .icon,
                firstText: "DeNAでFlutter製のスポーツ系のライブ配信アプリplay-by-sportsを開発中",
                secondText: "神山.swiftからJapan-Region-Swiftコンプリート中",
                thirdText: "1月に岐阜に来たとき以来の名古屋！",
                fourthText: "今月try!SwiftTokyo2025で登壇して、来月FlutterNinjas2025でも登壇",
                fifthText: "再来月からの家のBuildに向け、購入した土地の雑草抜きを絶賛計画中..!"
            )
        )
        
        VideoSlide(videoType: .bookAnimation)
    }
}
