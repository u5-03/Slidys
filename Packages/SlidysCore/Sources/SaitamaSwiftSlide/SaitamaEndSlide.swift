import CoreImage
import CoreImage.CIFilterBuiltins
import SlideKit
import SlidesCore
import SwiftUI

@Slide struct SaitamaEndSlide: View {
    var script: String { "Slidys本体は左のTestFlightから試せます。実装の詳細は右のブログに掲載しています。1年後の11月、また(埼玉で)出会えるのを信じて。ありがとうございました！" }
    var transition: AnyTransition { SlideTransition.defaultTransition }
    private let blogURL = URL(string: "https://ulog.sugiy.com/taiyaki-focus-3d-showcase-ios/")!

    var body: some View {
        VStack(spacing: 32) {
            Text("1年後の11月 また(埼玉で)出会えるのを信じて")
                .font(.system(size: 78, weight: .heavy))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .foregroundStyle(.themeColor)
                .frame(maxWidth: .infinity, alignment: .leading)
            HStack(alignment: .top, spacing: 80) {
                qrColumn(title: "Slidysを試す", subtitle: "TestFlight / スライド本体", url: SlideConstants.testFlightPublicLink)
                qrColumn(title: "実装の詳細・ブログ", subtitle: "", url: blogURL)
            }
        }
        .padding(70)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.slideBackgroundColor)
        .foregroundStyle(.defaultForegroundColor)
    }

    private func qrColumn(title: String, subtitle: String, url: URL) -> some View {
        VStack(spacing: 18) {
            Text(title).font(.system(size: 44, weight: .bold))
            Text(subtitle).font(.system(size: 30)).foregroundStyle(.secondary)
                .frame(height: 36)
            Link(destination: url) {
                if let qr = Self.qrImage(url) {
                    Image(decorative: qr, scale: 1)
                        .resizable().interpolation(.none).scaledToFit()
                        .padding(24).background(.white)
                        .frame(width: 390, height: 390)
                }
            }
            .accessibilityLabel(title)
            Text(url.absoluteString)
                .font(.system(size: 24)).foregroundStyle(.secondary)
                .lineLimit(1).minimumScaleFactor(0.6)
        }
        .frame(maxWidth: .infinity)
    }

    private static func qrImage(_ url: URL) -> CGImage? {
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(url.absoluteString.utf8)
        filter.correctionLevel = "M"
        guard let output = filter.outputImage else { return nil }
        return CIContext().createCGImage(output, from: output.extent)
    }
}

#Preview("Saitama 最後のスライド") {
    SlidePreview { SaitamaEndSlide() }.slideTheme(CustomSlideTheme(showSlideIndex: false, listTextStyle: .large))
}

#Preview("懇親会への案内") {
    SlidePreview {
        CenterTextSlide(text: "クイズの実装の詳細などは懇親会で！", script: "")
    }.slideTheme(CustomSlideTheme(showSlideIndex: false, listTextStyle: .large))
}
