import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct EndSlide: View {
    var script: String {
        "このスライドアプリはFlutterのデモごとTestFlightで配布しています。左のQRコードから触ってみてください。PDFのスライドは右のSpeaker Deckからご覧いただけます。ご清聴ありがとうございました！"
    }

    public var transition: AnyTransition { SlideTransition.defaultTransition }

    var body: some View {
        HeaderSlide(loc: "終わり") {
            HStack(alignment: .top, spacing: 100) {
                qrColumn(
                    title: "SlidysFlutterを試す",
                    subtitle: "TestFlight / Flutterデモ入り",
                    asset: "EndingTestFlightQR",
                    url: SlideConstants.testFlightFlutterPublicLink,
                    linkLabel: "testflight.apple.com/join/tKHf1Uq2"
                )
                qrColumn(
                    title: "PDFスライドを見る",
                    subtitle: "Speaker Deck",
                    asset: "EndingSpeakerDeckQR",
                    url: URL(string: "https://speakerdeck.com/u503/sono-fuguai-dono-widget-desu-ka-nai-de-naoseru-bagu-houkoku-o-tsukuru")!,
                    linkLabel: "speakerdeck.com/u503"
                )
            }
            .padding(.horizontal, 60)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }

    private func qrColumn(title: String, subtitle: String, asset: String,
                          url: URL, linkLabel: String) -> some View {
        VStack(spacing: 24) {
            Text(title.loc)
                .font(.system(size: 48, weight: .bold))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text(subtitle.loc)
                .font(.system(size: 32))
                .foregroundStyle(.gray)
            Link(destination: url) {
                Image(asset, bundle: .module)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(width: 460, height: 460)
            }
            .accessibilityLabel(Text(title.loc))
            Text(linkLabel)
                .font(.system(size: 26))
                .foregroundStyle(.gray)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    SlidePreview { EndSlide() }
        .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
        .itemStyle(CustomItemStyle())
}
