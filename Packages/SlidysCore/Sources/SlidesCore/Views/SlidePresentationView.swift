//
//  SlidePresentationView.swift
//  SlidesCore
//
//  iOS 用のスライド表示コンテナ。SlideKit の PresentationView は全体に ignoresSafeArea() を
//  掛けるため、iPhone Duo の内側ディスプレイ(横向き)のようにステータスバーやカメラ領域が
//  画面端に張り付く端末ではスライドの角がそれらと重なってしまう。
//  ここでは背景色だけを画面いっぱいに敷き、スライド本体は safe area の内側に
//  アスペクト比を保って収める(safe area はシステムが端末ごとに計算するので、機種別の分岐は不要)。
//

#if os(iOS)
import SlideKit
import SwiftUI

struct SlidePresentationView<Content: View>: View {
    let slideSize: CGSize
    @ViewBuilder let content: () -> Content
    @ObservedObject private var capture = PresenterSlideCapture.shared
    @ObservedObject private var duo = DualDisplayCaptureKeeper.shared
    private var needsCapture: Bool {
        capture.output.usesCapturedSlides || (duo.isRunning && duo.displayMode == .mirroredSlides)
    }

    var body: some View {
        ZStack(alignment: .center) {
            Color.slideDefaultBackground
                .ignoresSafeArea()
            SlideScreen(slideSize: slideSize) {
                Group {
                    if needsCapture {
                        PresenterSlideCaptureSurface { content() }
                    } else {
                        content()
                    }
                }
            }
            .clipped()
            .aspectRatio(slideSize, contentMode: .fit)

        }
    }
}
#endif

#if os(iOS)
#Preview("取得範囲：横長の手元画面", traits: .fixedLayout(width: 951, height: 669)) {
    SlidePresentationView(slideSize: CGSize(width: 1600, height: 900)) {
        Color.blue.overlay { Text("16:9 SLIDE").font(.largeTitle).foregroundStyle(.white) }
    }
}
#Preview("取得範囲：縦長の手元画面", traits: .fixedLayout(width: 669, height: 951)) {
    SlidePresentationView(slideSize: CGSize(width: 1600, height: 900)) {
        Color.blue.overlay { Text("16:9 SLIDE").font(.largeTitle).foregroundStyle(.white) }
    }
}
#endif
