import SwiftUI
import SlideKit
import SlidysCore

public struct KanagawaSwiftSlideView: View {
    let configuration = SlideConfiguration()

    public init() {}

    public var body: some View {
        SlideBaseView(slideConfiguration: configuration)
    }
}

struct SlideConfiguration: SlideConfigurationProtocol {
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
        CenterImageSlide(imageResource: .train)
        CenterTextSlide(text: "第2問")
        KanagawaQuizAnimationSlide(symbolType: .kamaboko)
        CenterImageSlide(imageResource: .kamaboko)
        CenterTextSlide(text: "第3問")
        KanagawaQuizAnimationSlide(symbolType: .car)
        CenterImageSlide(imageResource: .car)
        CenterTextSlide(text: "第4問")
        KanagawaQuizAnimationSlide(symbolType: .kirara)
        WebViewSlide(url: URL(string: "https://www.baystars.co.jp/community/mascot/")!)
        CenterTextSlide(text: "最終問題")
        KanagawaQuizAnimationSlide(symbolType: .enoshima)
        CenterImageSlide(imageResource: .enoshima)

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
