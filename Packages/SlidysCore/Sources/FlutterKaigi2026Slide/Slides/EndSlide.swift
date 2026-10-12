//
//  EndSlide.swift
//  FlutterKaigi2026Slide
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct EndSlide: View {
    /// スピーカーノート(発表者用の原稿。ノートWindowに表示される)
    var script: String {
        "発表の詳細とコードはブログにまとめます。このスライドアプリは Flutter のデモごと TestFlight で配布しているので、手元で触ってみてください。\nご清聴ありがとうございました！"
    }

    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        HeaderSlide(loc: "ご清聴ありがとうございました") {
            VStack(alignment: .leading, spacing: 48) {
                HStack(alignment: .top, spacing: 80) {
                    qrColumn(
                        title: "このスライドアプリ(TestFlight / Flutterデモ入り)",
                        url: SlideConstants.testFlightFlutterPublicLink.absoluteString
                    ) {
                        // SlidesCoreにバンドル済みのTestFlight配布用QR(Flutter版)
                        QrCodeType.flutter.view
                    }
                    VStack(alignment: .leading, spacing: 32) {
                        Text("本日の発表のブログ(詳細・コード)")
                            .font(.system(size: 40, weight: .bold))
                        // TODO: 公開後にブログURLとQRに差し替える
                        Text("https://ulog.sugiy.com/ (公開後に更新)")
                            .font(.system(size: 30, weight: .regular))
                            .foregroundStyle(.gray)
                        Text("実装リポジトリ")
                            .font(.system(size: 40, weight: .bold))
                            .padding(.top, 24)
                        Text("https://github.com/u5-03/Slidys")
                            .font(.system(size: 30, weight: .regular))
                            .foregroundStyle(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                }
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }

    private func qrColumn(
        title: String,
        url: String,
        @ViewBuilder qrImage: () -> some View
    ) -> some View {
        VStack(spacing: 24) {
            Text(title)
                .font(.system(size: 40, weight: .bold))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            qrImage()
                .frame(width: 440, height: 440)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            Text(url)
                .font(.system(size: 26, weight: .regular))
                .foregroundStyle(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    SlidePreview {
        EndSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}
