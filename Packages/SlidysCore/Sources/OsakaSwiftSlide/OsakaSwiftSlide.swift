import SwiftUI
import SlideKit
import SlidesCore

public struct OsakaSwiftSlideView: SlideViewProtocol {
    let configuration = SlideConfiguration()

    public init() {}

    public var body: some View {
        SlideBaseView(slideConfiguration: configuration)
    }
}

struct SlideConfiguration: SlideConfigurationProtocol {
    let slideIndexController = SlideIndexController() {
        CenterTextSlide(text: "Osaka.swift始まりました")
        ReadmeSlide()
        CenterTextSlide(text: "Chiba.swift/Kanagawa.swift")
        QuizTitleSlide(regionKind: .chiba)
        QuizTitleSlide(regionKind: .kanagawa)
        QuizAnimationSlide(title: "千葉シンボルクイズ 第3問", answer: "Uhooi", shape: UhooiShape())
        WebTitleSlide(title: "SymbolKit 爆誕！", url: URL(string: "https://github.com/u5-03/SymbolKit")!)
        CenterTextSlide(text: "iOSDCのLTスライドで色々な\nアニメーションで遊んだ")
        MusicNoteAnimationSlide()
        CenterTextSlide(text: "この線を描くアニメーションの\n仕組みを軽く解説しました")
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
        MarkAnimationSlide()
        QuizTitleSlide(regionKind: .osaka, isAlmostSymbol: true)
        QuizDescriptionSlide()
        CenterTextSlide(text: "第1問")
        OsakaQuizAnimationSlide(symbolType: .daruma)
        WebViewSlide(url: URL(string: "https://umeda.keizai.biz/photoflash/8554/")!)
        CenterTextSlide(text: "第2問")
        OsakaQuizAnimationSlide(symbolType: .bento)
        WebViewSlide(url: URL(string: "https://x.com/totokit4/status/1780083727789686992?s=46")!)
        WrapUpSlide()
        CenterTextSlide(text: "おしまい")
        OneMoreThingSlide()
        CenterTextSlide(text: "このまま終わっては、Kanagawa.swiftと\n同じでつまらん！")
        CenterTextSlide(text: "SymbolKitを進化させよう！")
        WebTitleSlide(title: "SymbolKit2 爆誕！", url: URL(string: "https://github.com/u5-03/SymbolKit/tree/2.0.0")!)
        TextAnimationSampleSlide()
        CenterTextSlide(text: "ということで")
        CenterTextSlide(text: "最終問題")
        OsakaQuizAnimationSlide(symbolType: .usj)
        WebViewSlide(url: URL(string: "https://www.usj.co.jp/web/en/us")!)
        CenterTextSlide(text: "SymbolKit2の仕組みが気になる人は\n懇親会などで聞いてください！")
        CenterTextSlide(text: "ほんとうにおしまい！")
    }
}
