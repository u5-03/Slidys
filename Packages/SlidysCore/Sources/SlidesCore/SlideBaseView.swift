//
//  SlideBaseView.swift
//
//
//  Created by Yugo Sugiyama on 2024/11/10.
//

import SwiftUI
import SlideKit
import Foundation

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
    public let slideTheme = CustomSlideTheme()

    public init(slideConfiguration: SlideConfigurationProtocol, timerDuration: Duration = .seconds(60 * 20)) {
        self.slideConfiguration = slideConfiguration
        _slideIndexController = .init(wrappedValue: slideConfiguration.slideIndexController)
        let duration = min(timerDuration, Duration.seconds(60 * 60))
        timeRemaining = .init(duration.components.seconds)
        self.timerDuration = timerDuration

    }

    public var body: some View {
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
        .onKeyPress(.leftArrow) {
            isFocused = true
            Task {
                slideConfiguration.slideIndexController.back()
            }
            return .handled
        }
        .onKeyPress(.rightArrow) {
            isFocused = true
            Task {
                slideConfiguration.slideIndexController.forward()
            }
            return .handled
        }
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
