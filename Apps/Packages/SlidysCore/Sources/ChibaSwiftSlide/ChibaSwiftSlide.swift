import SwiftUI
import SlideKit
import SlidesCore

public struct ChibaSwiftSlideView: SlideViewProtocol {
    let configuration = SlideConfiguration()

    public init() {}

    public var body: some View {
        SlideBaseView(slideConfiguration: configuration)
    }
}


struct SlideConfiguration: SlideConfigurationProtocol {

    @MainActor
    let slideIndexController = SlideIndexController(index: 0) {
        CenterTextSlide(text: "iOSDC2024")
        CenterTextSlide(text: "今年はLTをしました")
        PianoIntroductionSlide()
        MusicNoteAnimationSlide()
        CenterTextSlide(text: "今回はこの線を描くアニメーションの\n仕組みを解説します")
        TitleSlide()
        ReadmeSlide()
        ChibaContentSlide()
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
        CenterTextSlide(text: "なるほど")
        CenterTextSlide(text: "これでいい感じにアニメーションできそう")
        CenterTextSlide(text: "ではこれで遊んでみましょう！")
        QuizTitleSlide()
        QuizDescriptionSlide()
        CenterTextSlide(text: "第1問")
        QuizAnimationSlide(title: "千葉シンボルクイズ 第1問", answer: "ピーナッツ", shape: PeanutsShape())
        CenterTextSlide(text: "第2問")
        QuizAnimationSlide(title: "千葉シンボルクイズ 第2問", answer: "チーバくん", shape: ChibaShape())
        CenterTextSlide(text: "第3問")
        CenterTextSlide(text: "最終問題はなんと100ポイント！")
        QuizAnimationSlide(title: "千葉シンボルクイズ 第3問", answer: "uhooi", shape: UhooiShape())
        CenterTextSlide(text: "優勝したHogeさん、\nおめでとうございます！🎉")
        CenterTextSlide(text: "優勝賞品は...")
        WinningPrizeSlide()
        WrapUpSlide()
        CenterTextSlide(text: "おしまい")

    }
}

@MainActor
struct CustomSlideTheme: SlideTheme {
    let headerSlideStyle = CustomHeaderSlideStyle()
    let itemStyle = CustomItemStyle()
    let indexStyle = CustomIndexStyle()
}

struct CustomIndexStyle: IndexStyle {
    func makeBody(configuration: Configuration) -> some View {
        Text("\(configuration.slideIndexController.currentIndex + 1) / \(configuration.slideIndexController.slides.count)")
            .foregroundColor(.gray)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            .font(.system(size: 30))
            .padding()
    }
}
