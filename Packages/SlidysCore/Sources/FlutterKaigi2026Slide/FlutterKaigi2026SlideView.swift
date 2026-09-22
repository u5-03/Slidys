//
//  FlutterKaigi2026SlideView.swift
//  FlutterKaigi2026Slide
//
//  FlutterKaigi 2026 LT のデッキ。Flutter のデモ画面はホストアプリ(SlidysFlutter)が
//  RouterProtocol 経由で FlutterViewController を供給する(FlutterKaigiSlide と同じ構成)。
//

import SwiftUI
import SlideKit
import SlidesCore

extension ListTextStyle {
    /// FlutterKaigi2026用: LT向けに本文を大きめ・行間広めで見せる(iOSDC2026 と同じ寸法)。
    static let flutterKaigi2026 = ListTextStyle(
        contentFontSize: 68,
        contentSpacing: 64,
        contentLineSpacing: 14,
        headerFontSize: 84,
        headerHeight: 120
    )
}

public struct FlutterKaigi2026SlideView: SlideViewProtocol {
    let configuration = SlideConfiguration()
    let router: RouterProtocol

    public init(router: RouterProtocol) {
        self.router = router
    }

    public var body: some View {
        SlideBaseView(
            slideConfiguration: configuration,
            timerDuration: Duration.seconds(60 * 10), // LT: 10分
            listTextStyle: .flutterKaigi2026
        )
        .environment(\.router, router)
    }
}

public extension FlutterKaigi2026SlideView {
    /// スクリーンショット書き出しなどの自動化ツール向けに、デッキの SlideIndexController を生成して返す。
    @MainActor static func makeSlideIndexController() -> SlideIndexController {
        SlideConfiguration().slideIndexController
    }

    /// このデッキで使っているリスト文字サイズ(自動化ツールが同じ見た目で描画するために公開)。
    static let listTextStyle: ListTextStyle = .flutterKaigi2026
}

#Preview("発表モード") {
    FlutterKaigi2026SlideView(router: DefaultRouter())
}

#Preview("スライド一覧(グリッド)", traits: .fixedLayout(width: 1400, height: 1080)) {
    ScrollView([.vertical, .horizontal]) {
        SlideGridView(
            slideIndexController: FlutterKaigi2026SlideView.makeSlideIndexController(),
            listTextStyle: FlutterKaigi2026SlideView.listTextStyle,
            columns: 3,
            tileWidth: 456
        )
    }
}
