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

    var body: some View {
        ZStack(alignment: .center) {
            Color.slideDefaultBackground
                .ignoresSafeArea()
            SlideScreen(slideSize: slideSize) {
                content()
            }
            .clipped()
            .aspectRatio(slideSize, contentMode: .fit)
        }
    }
}
#endif
