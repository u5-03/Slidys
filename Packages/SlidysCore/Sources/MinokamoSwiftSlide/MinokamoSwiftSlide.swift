import SwiftUI
import SlideKit
import SlidesCore
import SymbolKit

public struct MinokamoSwiftSlideView: SlideViewProtocol {
    let configuration = SlideConfiguration()

    public init() {}

    public var body: some View {
        SlideBaseView(slideConfiguration: configuration)
    }
}

struct SlideConfiguration: SlideConfigurationProtocol {
    let slideIndexController = SlideIndexController() {
        CenterTextSlide(text: "Minokamo.swift！")
        ReadmeSlide()
        CenterTextSlide(text: "Chiba.swift/Kanagawa.swift/Osaka.swift")
        QuizTitleSlide(regionKind: .chiba)
        QuizTitleSlide(regionKind: .kanagawa)
        QuizTitleSlide(regionKind: .osaka, isAlmostSymbol: true)
        QuizAnimationSlide(title: "シンボルクイズ例題", answer: "Sugiy", shape: SugiyShape())
        WebTitleSlide(title: "SymbolKit 爆誕！", url: URL(string: "https://github.com/u5-03/SymbolKit")!)
        CenterTextSlide(text: "Pathを描くアニメーションの\n仕組みを軽く解説します")
        AnimationStructureSlide()
        CodeSlide(
            title: "実際のコード1",
            code: Constants.strokeAnimatableShapeCodeCode,
            fontSize: 40
        )
        CodeSlide(
            title: "実際のコード2",
            code: Constants.strokeAnimationShapeViewCode,
            fontSize: 38
        )
        QuizTitleSlide(regionKind: .gifu, isAlmostSymbol: true)
        QuizDescriptionSlide()
        CenterTextSlide(text: "第1問")
        MinokamoQuizAnimationSlide(symbolInfo: SymbolType.raicho)
        WebViewSlide(url: URL(string: "https://www.pref.gifu.lg.jp/page/99318.html#:~:text=1.%E3%83%A9%E3%82%A4%E3%83%81%E3%83%A7%E3%82%A6%E3%81%AE%E7%B4%B9%E4%BB%8B,-1.%E3%83%A9%E3%82%A4%E3%83%81%E3%83%A7%E3%82%A6%E3%81%A8&text=%E8%BF%91%E5%B9%B4%E3%80%81%E7%94%9F%E6%81%AF%E6%95%B0%E3%81%8C%E6%B8%9B%E5%B0%91,%E3%81%95%E3%82%8C%E3%81%A6%E3%81%84%E3%82%8B%E9%B3%A5%E3%81%A7%E3%81%99%E3%80%82")!)
        CenterTextSlide(text: "第2問")
        MinokamoQuizAnimationSlide(symbolInfo: SymbolType.worldHeritage)
        WebViewSlide(url: URL(string: "https://bunka.nii.ac.jp/suisensyo/shirakawago/index.html")!)
        WrapUpSlide()
        CenterTextSlide(text: "おしまい")
        OneMoreThingSlide()
        CenterTextSlide(text: "このまま終わっては、Osaka.swiftと\n同じでつまらん！(n回目)")
        CenterTextSlide(text: "SymbolKitを再進化させよう！")
        WebTitleSlide(title: "SymbolKit v3 爆誕！", url: URL(string: "https://github.com/u5-03/SymbolKit/tree/3.0.0")!)
        MarkAnimationSlide()
        CodeSlide(
            title: "2つの値の変化をアニメーションで表現",
            code: Constants.strokePairAnimationShapeViewCode,
            fontSize: 40
        )
        CenterTextSlide(text: "ということで")
        CenterTextSlide(text: "最終問題")
        MinokamoQuizAnimationSlide(symbolInfo: SymbolType.nobunaga)
        WebViewSlide(url: URL(string: "https://www.irasutoya.com/2013/09/blog-post_21.html")!)
        CenterTextSlide(text: "ほんとうにおしまい！")
    }
}
