import SwiftUI
import SlideKit
import SlidesCore

public struct KanagawaSwiftSlideView: SlideViewProtocol {
    let configuration = SlideConfiguration()

    public init() {}

    public var body: some View {
        SlideBaseView(slideConfiguration: configuration)
    }
}

struct SlideConfiguration: SlideConfigurationProtocol {
    @MainActor
    let slideIndexController = SlideIndexController() {
        CenterTextSlide(text: "Kanagawa.swift始まりました")
        ReadmeSlide()
        CenterTextSlide(text: "Chiba.swift")
        QuizTitleSlide(regionKind: .chiba)
        QuizAnimationSlide(title: "千葉シンボルクイズ 第3問", answer: "Uhooi", shape: UhooiShape())
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
        QuizTitleSlide(regionKind: .kanagawa)
        QuizDescriptionSlide()
        CenterTextSlide(text: "第1問")
        KanagawaQuizAnimationSlide(symbolType: .train)
        WebViewSlide(url: URL(string: "https://www.odakyu.jp/romancecar/features/line_up/70000/")!)
        CenterTextSlide(text: "第2問")
        KanagawaQuizAnimationSlide(symbolType: .kamaboko)
        WebViewSlide(url: URL(string: "https://www.maff.go.jp/j/keikaku/syokubunka/k_ryouri/search_menu/menu/35_19_kanagawa.html")!)
        CenterTextSlide(text: "第3問")
        KanagawaQuizAnimationSlide(symbolType: .car)
        WebViewSlide(url: URL(string: "https://www3.nissan.co.jp/vehicles/new/serena.html")!)
        CenterTextSlide(text: "第4問")
        KanagawaQuizAnimationSlide(symbolType: .kirara)
        WebViewSlide(url: URL(string: "https://www.baystars.co.jp/community/mascot/")!)
        CenterTextSlide(text: "最終問題")
        KanagawaQuizAnimationSlide(symbolType: .enoshima)
        WebViewSlide(url: URL(string: "https://www.google.com/maps/place/Enoshima,+Fujisawa,+Kanagawa+251-0036/@35.299748,139.4788592,17.01z/data=!4m6!3m5!1s0x60184ee6a0890aa5:0x4fe5988514a5aec!8m2!3d35.2990992!4d139.4809269!16zL20vMDF0MGNx?entry=ttu&g_ep=EgoyMDI0MTExMy4xIKXMDSoASAFQAw%3D%3D")!)
        WrapUpSlide()
        CenterTextSlide(text: "おしまい")
        OneMoreThingSlide()
        CenterTextSlide(text: "Chiba.swiftの時に誰かが...")
        CenterTextSlide(text: "DobonKitみたいにしないんですか？")
        CenterTextSlide(text: "ということで...")
        WebTitleSlide(title: "SymbolKit 爆誕！", url: URL(string: "https://github.com/u5-03/SymbolKit")!)
        CenterTextSlide(text: "ちょっとSymbolKitの実装の解説")
        CenterTextSlide(text: "ほんとうにおしまい！")
    }
}
