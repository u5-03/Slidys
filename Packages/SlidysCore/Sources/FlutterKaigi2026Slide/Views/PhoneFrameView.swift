//
//  PhoneFrameView.swift
//  FlutterKaigi2026Slide
//
//  埋め込んだ Flutter のデモ画面を「スマホの画面」として見せるための枠。
//  角丸の端末風ベゼルで囲み、縦長(9:16)のアスペクト比に収める(高さいっぱいに広げるので、比率を寝かせるほど大きく見える)。
//

import SlideKit
import SlidesCore
import SwiftUI

struct PhoneFrameView<Content: View>: View {
    let content: Content
    /// 画面の縦横比(幅/高さ)。既定はスマホ縦(9:16)。
    let aspectRatio: CGFloat
    private let cornerRadius: CGFloat = 56
    private let bezel: CGFloat = 14

    init(aspectRatio: CGFloat = DemoPhoneLayout.defaultAspectRatio, @ViewBuilder content: () -> Content) {
        self.aspectRatio = aspectRatio
        self.content = content()
    }

    var body: some View {
        // 中身(FlutterViewController)が自分のサイズを持たなくても、端末枠として
        // 提案サイズいっぱいに広がるよう ZStack に Color を敷いてから aspectRatio で縦長に収める
        ZStack {
            Color.black
            content
        }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius - bezel, style: .continuous))
            .padding(bezel)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color.black)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.25), lineWidth: 3)
            )
            .aspectRatio(aspectRatio, contentMode: .fit)
            .shadow(color: .black.opacity(0.4), radius: 30, y: 16)
            // 中の Flutter 画面を操作できるよう、スライド送りのタップ領域からくり抜く
            .excludesFromSlideTapNavigation()
    }
}

/// デモ画面(PhoneFrameView)をスライドの右端に高さいっぱいで置くためのレイアウト定数と修飾子。
/// HeaderSlide の本文領域(上に見出し、周囲に余白)の中に置くと小さくなってしまうので、
/// HeaderSlide 自体を左に詰め(見出しもスマホ枠と重ならないように)、空いた右側にスライド全体の高さで重ねる
enum DemoPhoneLayout {
    static let defaultAspectRatio: CGFloat = 9.0 / 16.0
    /// スライド上下の余白
    static let verticalInset: CGFloat = 36
    /// スライド右端の余白
    static let trailingInset: CGFloat = 60
    /// 本文とスマホ枠の間隔
    static let gap: CGFloat = 48
    /// HeaderSlide(CustomHeaderSlideStyle)が内側に持つ余白。この分は間隔として数える
    static let headerSlideInnerPadding: CGFloat = 60

    static func phoneWidth(aspectRatio: CGFloat = defaultAspectRatio) -> CGFloat {
        (SlideSize.standard16_9.height - verticalInset * 2) * aspectRatio
    }

    /// HeaderSlide 全体に付ける右パディング(見出し・本文ともスマホ枠と重ならない幅)
    static func slideTrailingPadding(aspectRatio: CGFloat = defaultAspectRatio) -> CGFloat {
        phoneWidth(aspectRatio: aspectRatio) + trailingInset + gap - headerSlideInnerPadding
    }
}

extension View {
    /// スライド(HeaderSlide)の右端に、高さいっぱいのスマホ枠でデモ画面を重ねる。
    /// HeaderSlide はスマホ枠の幅だけ左に詰められる(見出しの折り返し・縮小はそのまま効く)
    func demoPhoneOverlay<Content: View>(
        aspectRatio: CGFloat = DemoPhoneLayout.defaultAspectRatio,
        @ViewBuilder content: () -> Content
    ) -> some View {
        padding(.trailing, DemoPhoneLayout.slideTrailingPadding(aspectRatio: aspectRatio))
            // 詰めた分の右側も同じ背景色で埋める
            .background(Color.slideBackgroundColor)
            .overlay(alignment: .trailing) {
                PhoneFrameView(aspectRatio: aspectRatio, content: content)
                    .padding(.vertical, DemoPhoneLayout.verticalInset)
                    .padding(.trailing, DemoPhoneLayout.trailingInset)
            }
    }
}

#Preview {
    PhoneFrameView {
        Color.teal
    }
    .padding(60)
    .background(Color.slideBackgroundColor)
}
