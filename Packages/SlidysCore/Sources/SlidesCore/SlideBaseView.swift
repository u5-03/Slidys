//
//  SlideBaseView.swift
//
//
//  Created by Yugo Sugiyama on 2024/11/10.
//

import SwiftUI
import SlideKit
import Foundation
#if os(iOS)
import UIKit
#endif

public protocol SlideConfigurationProtocol {
    var size: CGSize { get }
    var slideIndexController: SlideIndexController { get }
}

public extension SlideConfigurationProtocol {
    var size: CGSize {
        return SlideSize.standard16_9
    }
}

public struct SlideBaseView: View {
    @FocusState private var isFocused: Bool
    @State private var timeRemaining: TimeInterval
    @State private var isTimerRunning = false
    @State private var timer: Timer?
    
    private let timerDuration: Duration

    var presentationContentView: some View {
        SlideRouterView(slideIndexController: slideConfiguration.slideIndexController)
            .slideTheme(slideTheme)
            .foregroundColor(.black)
            .background(.white)
    }

    public let slideConfiguration: SlideConfigurationProtocol
    @StateObject private var slideIndexController: SlideIndexController
    public let slideTheme: CustomSlideTheme

    /// - Parameter listTextStyle: HeaderSlide 内のリスト本文の文字サイズ。
    ///   既定は `.standard`(従来どおり)。文字少なめのデッキでは `.large` を指定する。
    public init(
        slideConfiguration: SlideConfigurationProtocol,
        timerDuration: Duration = .seconds(60 * 20),
        showSlideIndex: Bool = true,
        showsTotalSlideCount: Bool = true,
        listTextStyle: ListTextStyle = .standard
    ) {
        self.slideConfiguration = slideConfiguration
        _slideIndexController = .init(wrappedValue: slideConfiguration.slideIndexController)
        let duration = min(timerDuration, Duration.seconds(60 * 60))
        timeRemaining = .init(duration.components.seconds)
        self.timerDuration = timerDuration
        self.slideTheme = CustomSlideTheme(
            showSlideIndex: showSlideIndex,
            showsTotalSlideCount: showsTotalSlideCount,
            listTextStyle: listTextStyle
        )
    }

#if os(iOS)
    /// iPad/iPhoneでの原稿確認用: スライド+スピーカーノートの2分割表示にするか。
    /// 既定はスライドのみ。スライド中央上部の不可視領域を5秒長押し、
    /// またはハードウェアキーボードの「P」で切り替える。
    @State private var showsSpeakerNotesPanel = false
#endif

    public var body: some View {
#if os(iOS)
        GeometryReader { proxy in
            if showsSpeakerNotesPanel {
                // YouTube(iPad)風: 左にスライド、右にスピーカーノート
                HStack(spacing: 0) {
                    presentationBody
                    SpeakerNotesPanel(slideIndexController: slideConfiguration.slideIndexController)
                        .frame(width: proxy.size.width * 0.34)
                }
            } else {
                presentationBody
            }
        }
        // 画面上端のシステムジェスチャー(通知センター等)を1段遅らせて、
        // 上部の長押し領域へのタッチ配送が保留されないようにする
        .defersSystemGestures(on: .top)
#else
        presentationBody
#endif
    }

    private var presentationBody: some View {
        NavigationStack {
            PresentationView(slideSize: slideConfiguration.size) {
                GeometryReader { proxy in
                    let circleHeight = proxy.size.height * 1
                    ZStack {
                        presentationContentView
                            .frame(maxHeight: .infinity)
#if !os(visionOS)
                        Circle()
                            .frame(width: circleHeight, height: circleHeight)
                            .foregroundStyle(Color.black.opacity(0.01))
                            .position(x: 0, y: 0)
                            .onTapGesture {
                                // SymbolQuizのViewなどでFocusが移動した時に、再度Focusを有効にする処理
                                isFocused = true
                                Task {
                                    slideConfiguration.slideIndexController.back()
                                }
                            }
                        Circle()
                            .frame(width: circleHeight, height: circleHeight)
                            .foregroundStyle(Color.black.opacity(0.01))
                            .position(x: proxy.size.width, y: 0)
                            .onTapGesture {
                                isFocused = true
                                Task {
                                    slideConfiguration.slideIndexController.forward()
                                }
                            }
#if os(iOS)
                        // 中央上部: スピーカーノートパネルの表示切り替え(不可視の隠し領域を5秒長押し)。
                        // タップは消費しないので、左右上のページ送り領域とスライド操作はそのまま機能する
                        Rectangle()
                            .frame(width: proxy.size.width * 0.4, height: proxy.size.height * 0.18)
                            .foregroundStyle(Color.black.opacity(0.01))
                            .position(x: proxy.size.width / 2, y: proxy.size.height * 0.09)
                            // maximumDistance: 長押し中の指の微動でキャンセルされないよう大きめに取る
                            // (既定10ptはスライド縮小表示だと実画面6pt程度になり、5秒の静止はほぼ不可能)
                            .onLongPressGesture(minimumDuration: 2, maximumDistance: 200) {
                                showsSpeakerNotesPanel.toggle()
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            }
#endif
#endif
                    }
                }
            }
#if os(visionOS)
            .toolbar {
                ToolbarItem(placement: .bottomOrnament) {
                    HStack(alignment: .center, spacing: 20) {
                        HStack {
                            Button {
                                slideIndexController.back()
                            } label: {
                                Image(systemName: "chevron.left")
                            }
                            .disabled(slideIndexController.currentIndex == 0)

                            Text("\(slideIndexController.currentIndex + 1)/\(slideIndexController.slides.count)")
                                .font(.largeTitle)

                            Button {
                                slideIndexController.forward()
                            } label: {
                                Image(systemName: "chevron.right")
                            }
                            .disabled(slideIndexController.currentIndex == slideIndexController.slides.count - 1)
                        }
                        
                        Divider()
                            .frame(height: 30)
                        
                        HStack(spacing: 12) {
                            Button {
                                if isTimerRunning {
                                    stopTimer()
                                } else {
                                    startTimer()
                                }
                            } label: {
                                Image(systemName: isTimerRunning ? "pause.circle.fill" : "play.circle.fill")
                                    .font(.title)
                            }
                            
                            Text(formattedTime(timeRemaining))
                                .font(.system(size: 28, weight: .medium, design: .monospaced))
                                .foregroundColor(timeRemaining <= 60 ? .red : .primary)
                            
                            Button {
                                resetTimer()
                            } label: {
                                Image(systemName: "arrow.clockwise.circle.fill")
                                    .font(.title)
                            }
                        }
                    }
                }
            }
#endif
        }
#if os(macOS)
        .focusable()
        .focused($isFocused)
        .focusEffectDisabled()
        // Page Up/Downはプレゼン用ポインター(HIDキーボードとして
        // 「進む=Page Down / 戻る=Page Up」を送るタイプ)用
        .onKeyPress(keys: [.leftArrow, .pageUp]) { _ in
            isFocused = true
            Task {
                slideConfiguration.slideIndexController.back()
            }
            return .handled
        }
        .onKeyPress(keys: [.rightArrow, .pageDown]) { _ in
            isFocused = true
            Task {
                slideConfiguration.slideIndexController.forward()
            }
            return .handled
        }
        // 「P」でスピーカーノートWindowを開閉(ノートは各スライドの script プロパティから表示)
        .onKeyPress(KeyEquivalent("p")) {
            Task { @MainActor in
                SpeakerNotesWindowPresenter.toggle(
                    slideIndexController: slideConfiguration.slideIndexController,
                    slideTheme: slideTheme
                )
            }
            return .handled
        }
#endif
#if os(iOS)
        .focusable()
        .focused($isFocused)
        // ハードウェアキーボード接続時: 「P」でノートパネル切り替え、矢印/Page Up/Downで送り
        .onKeyPress(KeyEquivalent("p")) {
            showsSpeakerNotesPanel.toggle()
            return .handled
        }
        .onKeyPress(keys: [.leftArrow, .pageUp]) { _ in
            Task { slideConfiguration.slideIndexController.back() }
            return .handled
        }
        .onKeyPress(keys: [.rightArrow, .pageDown]) { _ in
            Task { slideConfiguration.slideIndexController.forward() }
            return .handled
        }
        .onAppear { isFocused = true }
#endif
    }
}

private extension SlideBaseView {
    func startTimer() {
        isTimerRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                stopTimer()
            }
        }
    }

    func stopTimer() {
        isTimerRunning = false
        timer?.invalidate()
        timer = nil
    }

    func resetTimer() {
        stopTimer()
        timeRemaining = TimeInterval(timerDuration.components.seconds)
    }

    func formattedTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
