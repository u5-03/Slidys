//
//  PhoneFrameView.swift
//  FlutterKaigi2026Slide
//
//  埋め込んだ Flutter のデモ画面を「スマホの画面」として見せるための枠。
//  角丸の端末風ベゼルで囲み、縦長(9:19.5)のアスペクト比に収める。
//

import SwiftUI

struct PhoneFrameView<Content: View>: View {
    let content: Content
    private let cornerRadius: CGFloat = 56
    private let bezel: CGFloat = 14

    init(@ViewBuilder content: () -> Content) {
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
            .aspectRatio(9.0 / 19.5, contentMode: .fit)
            .shadow(color: .black.opacity(0.4), radius: 30, y: 16)
    }
}

#Preview {
    PhoneFrameView {
        Color.teal
    }
    .padding(60)
    .background(Color.slideBackgroundColor)
}
