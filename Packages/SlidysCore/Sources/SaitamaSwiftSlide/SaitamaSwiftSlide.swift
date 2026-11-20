import SlideKit
import SlidesCore
import SwiftUI

/// Saitama.swift #1: six minutes of Taiyaki Focus, nine minutes of quiz and closing.
public struct SaitamaSwiftSlideView: SlideViewProtocol {
    private let configuration = SaitamaSlideConfiguration()
    public init() {}

    public var body: some View {
        SlideBaseView(slideConfiguration: configuration, timerDuration: .seconds(15 * 60), showSlideIndex: false, listTextStyle: .large)
    }

    public var pdfExportSource: SlidePDFExportSource? {
        SlidePDFExportSource(
            slides: configuration.slideIndexController.slides,
            slideTheme: CustomSlideTheme(showSlideIndex: false, listTextStyle: .large),
            slideSize: configuration.size, fileName: "Saitama_swift_1_Sugiy"
        )
    }

    @MainActor public static func makeSlideIndexController() -> SlideIndexController {
        SaitamaSlideConfiguration().slideIndexController
    }
}

struct SaitamaSlideConfiguration: SlideConfigurationProtocol {
    @MainActor let slideIndexController = SlideIndexController {
        CenterTextSlide(text: "Saitama.swift", script: "Saitama.swift、初めて参加します！")
        CenterTextSlide(text: "埼玉に住んでる or 出身だよー\nという人？🙋‍♂️🙋‍♀️", script: "自分は埼玉に縁もゆかりもないのですが、会場で埼玉に住んでいる、または出身だよという方はいますか？手を上げてもらって、次の画面で撮影します。")
        SaitamaAudienceCameraSlide()
        CenterTextSlide(text: "ところで", script: "ところで。")
        CenterTextSlide(text: "私はiOSDC2026で\nこんな発表をしてました", script: "私は9月11日のiOSDC Japan 2026で、こんな発表をしていました。")
        SaitamaIOSDCTitleSlide()
        SaitamaOpeningPhotoSlide()
        SaitamaAppleStoreVideoSlide()
        SaitamaAppleStoreDetailSlide()
        SaitamaTaiyakiDemoSlide()
        CenterTextSlide(text: "今回はこれらの話のもう少し詳しくお話しします！", script: "今回は、これらの話をもう少し詳しくお話しします！")
        SaitamaTitleSlide()
        SaitamaTitleMeaningSlide()
        SaitamaReadmeSlide()
        SaitamaProceduralFocusSlide()
        SaitamaTechnicalSlides.mesh
        SaitamaTechnicalSlides.texture
        SaitamaTechnicalSlides.anchors
        SaitamaTechnicalSlides.buttons
        SaitamaTechnicalSlides.focus
        SaitamaTechnicalSlides.cautions
        SaitamaTechnicalSlides.summary
        CenterTextSlide(text: "終わり", script: "ここまでが、たい焼きフォーカスの仕組みと活用方法のお話でした。ありがとうございました。")
        OneMoreThingSlide(script: "……One more thing。もう少しだけ、お付き合いください。")
        CenterTextSlide(text: "3Dモデルの見せ方は\nこれくらいしかないのでしょうか？", script: "でも、3Dモデルの見せ方はこれくらいしかないのでしょうか？")
        CenterTextSlide(text: "3Dモデルの見せ方を\n本当に知っているんでしょうか？", script: "私たちは3Dモデルの見せ方を、本当に知っているんでしょうか？")
        CenterTextSlide(text: "もう少し色々な活用方法を模索しましょう", script: "もう少し色々な活用方法を模索しましょう。")
        CenterTextSlide(text: "ということで", script: "ということで。")
        SaitamaQuizTitleSlide()
        SaitamaPastSymbolQuizzesSlide()
        SaitamaQuizRulesSlide()
        SaitamaAudiencePhotoSlide()
        SaitamaSymbolQuizSlide()
        CenterTextSlide(text: "クイズの実装の詳細などは懇親会で！", script: "クイズの実装の詳細などは懇親会でお話ししましょう！")
        CenterTextSlide(text: "ということで", script: "【14:45–14:47 / 2秒】ということで。")
        CenterTextSlide(text: "埼玉のおすすめスポット", script: "【14:47–14:49 / 2秒】埼玉のおすすめスポット。")
        CenterTextSlide(text: "見つけましたね！", script: "【14:49–14:51 / 2秒】見つけましたね！")
        CenterTextSlide(text: "いや", script: "【14:51–14:52 / 1秒】いや。")
        CenterTextSlide(text: "みーつけた！", script: "【14:52–14:55 / 3秒】みーつけた！")
        SaitamaEndSlide()
    }
}

@Slide
struct SaitamaTitleSlide: View {
    /// スピーカーノート(発表者用の原稿。ノートWindowに表示される)
    var script: String {
        "今日は『あの日観た3Dモデルの見せ方を僕達はまだ知らない。』というタイトルで発表します。"
    }

    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    private let title = "あの日観た3Dモデルの見せ方を\n僕達はまだ知らない。"
    private let dateString = "2026/11" // TODO: 発表日確定後に更新
    private let eventName = "Saitama.swift #1"
    private let authorName = "Sugiy/すぎー"

    var body: some View {
        VStack(spacing: 0) {
            Text(title)
                .font(.system(size: 100, weight: .heavy))
                .minimumScaleFactor(0.1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(.themeColor)
            Spacer()
                .frame(height: 28)
            VStack(alignment: .trailing, spacing: 32) {
                HStack(spacing: 20) {
                    Spacer()
                    Text(dateString)
                        .font(.system(size: 80, weight: .heavy))
                        .frame(alignment: .trailing)
                    Text(eventName)
                        .font(.system(size: 80, weight: .heavy))
                        .frame(alignment: .trailing)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.leading)
                HStack(alignment: .top, spacing: 20) {
                    Spacer()
                    Text(authorName)
                        .font(.system(size: 100, weight: .heavy))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    Image(.iconDynamic)
                        .resizable()
                        .frame(width: 160, height: 160)
                        .aspectRatio(contentMode: .fit)
                        .clipShape(Circle())
                }
            }
        }
        .frame(maxHeight: .infinity)
        .padding(80)
        .background(.slideBackgroundColor)
        .foregroundColor(.defaultForegroundColor)
    }

    var shouldHideIndex: Bool { true }
}


@Slide struct SaitamaPointsSlide: View {
    let title: String
    let points: [String]
    let script: String
    var transition: AnyTransition { SlideTransition.defaultTransition }
    var body: some View {
        HeaderSlide(LocalizedStringKey(title)) {
            ForEach(Array(points.enumerated()), id: \.offset) { index, point in
                Item(LocalizedStringKey(point), accessory: .number(index + 1))
            }
        }
    }
}

@Slide struct SaitamaCodeExplanationSlide: View {
    let title: String
    let points: [String]
    let code: String
    let script: String
    var transition: AnyTransition { SlideTransition.defaultTransition }
    var body: some View {
        HeaderSlide(LocalizedStringKey(title)) {
            HStack(alignment: .top, spacing: 56) {
                VStack(alignment: .leading, spacing: 48) {
                    ForEach(Array(points.enumerated()), id: \.offset) { index, point in
                        Item(LocalizedStringKey(point), accessory: .number(index + 1))
                    }
                }.frame(maxWidth: .infinity, alignment: .leading)
                Text(code).font(.system(size: 40, weight: .medium, design: .monospaced))
                    .lineSpacing(16).foregroundStyle(.white)
                    .padding(36).frame(width: 870, alignment: .leading)
                    .background(.black.opacity(0.25), in: RoundedRectangle(cornerRadius: 24))
            }
        }
    }
}

@Slide struct SaitamaTaiyakiDemoSlide: View {
    var script: String { "【1:10–2:30 / 80秒】まずはデモです。これはiOSDCのカードバトルで使ったものと同じたい焼きのUSDZです。表示すると右に1回転、左に1回転し、そのあと具材が0.5秒ごとに切り替わります。こちらを向いている部位にプラスが出ます。手動操作を始めると自動デモは止まります。目をタップすると、目が見やすい位置へズームして解説が出ます。マイナスで元へ戻せます。具材を変えると見た目も変わります。写真を何枚も並べる代わりに、ひとつのモデルから気になる場所を探ってもらうUIです。" }
    var transition: AnyTransition { SlideTransition.defaultTransition }
    var body: some View {
        HeaderSlide("デモ：たい焼きフォーカス") {
            TaiyakiFocusView(mode: .full, fontScale: 2.1, modelScale: 1.2, automaticDemo: true)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .excludesFromSlideTapNavigation()
        }
    }
}

@Slide struct SaitamaQuizRulesSlide: View {
    var script: String {
        "【30秒】問題は全部で3問です。3枚のカードに、それぞれ埼玉の建物が1つずつ入っています。まず好きなカードを1枚選ぶと、その建物が登場します。モデルを回転・拡大して観察し、どの建物か答えてください。回答と正解の発表は口頭で行います。1問終わったらカードを裏向きに戻し、別のカードへ進みます。"
    }
    var body: some View {
        SaitamaPointsSlide(title: "ルール", points: [
            "問題は全3問。埼玉の建物を当てよう！",
            "好きなカードを1枚選ぶと、建物が登場",
            "回転・拡大して観察し、建物の名前を答えよう"
        ], script: script)
    }
}

#Preview("クイズのルール", traits: .fixedLayout(width: 1280, height: 720)) {
    SlidePreview { SaitamaQuizRulesSlide() }
        .slideTheme(CustomSlideTheme(showSlideIndex: false, listTextStyle: .large))
}

@Slide struct SaitamaSymbolQuizSlide: View {
    var script: String { "好きなカードを会場に選んでもらう。カードを選択して召喚し、ドラッグで回転、ピンチで拡大して観察してもらう。回答は口頭で伝える。『カードを裏向きに戻す』で次のカードへ進む。全体で約6分を目安に進行する。" }
    var transition: AnyTransition { SlideTransition.defaultTransition }
    var body: some View { SaitamaSymbolQuizView() }
}

#Preview("Saitama.swift #1") { SaitamaSwiftSlideView() }
#Preview("Saitama.swift #1 一覧", traits: .fixedLayout(width: 1400, height: 1080)) {
    ScrollView([.vertical, .horizontal]) {
        SlideGridView(slideIndexController: SaitamaSwiftSlideView.makeSlideIndexController(),
                      listTextStyle: .large, columns: 3, tileWidth: 456)
    }
}

/// Overview and interactive slide preview available from the mobile app's list.
public struct SaitamaSwiftSlidePreviewView: View {
    private let onClose: (() -> Void)?
    public init(onClose: (() -> Void)? = nil) { self.onClose = onClose }
    public var body: some View {
        SlideDeckPreviewView(
            title: "Saitama.swift #1",
            slideIndexController: SaitamaSwiftSlideView.makeSlideIndexController(),
            listTextStyle: .large,
            onClose: onClose
        )
    }
}
