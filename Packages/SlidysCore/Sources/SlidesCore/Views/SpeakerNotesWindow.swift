//
//  SpeakerNotesWindow.swift
//  SlidesCore
//
//  発表者用のスピーカーノート画面。
//  macOS では NSWindow(SpeakerNotesWindowPresenter)で、iPhone Duo(内側ディスプレイ)/iPad では
//  SwiftUI の別Scene(SpeakerNotesScene)で開く。
//  メインのスライドと同じ SlideIndexController を購読するため、
//  スライド送り(フェーズ送り含む)に合わせてノートも自動で切り替わる。
//
//  上部に「現在の断面」と「次の断面」の2つのプレビューを表示する。
//  「次」はページ単位ではなくステップ単位: 現在のスライドに未表示のフェーズが
//  残っていれば「次のフェーズが出た状態」、最後のフェーズなら「次ページの先頭」。
//
//  注意: @Phase(PhaseWrapper)はストア参照を内部クラスにキャッシュし、それが
//  スライド構造体のコピー間で共有されるため、同じスライドを別のフェーズ段階で
//  同時に描画することができない。プレビューは environment の previewPhaseStep で
//  表示段階を直接指定する方式にしている(フェーズ付きスライド側が対応済み)。
//

#if os(macOS)
import AppKit
#endif
import SlideKit
import SwiftUI

extension Slide {
    /// 現在のフェーズ段階(rawValue)と最終段階を返す(読み取りのみ)。
    @MainActor
    func phaseStep(on controller: SlideIndexController) -> (current: Int, last: Int) {
        let store: PhasedStateStore<SlidePhasedState> = controller.phaseStateStore()
        let last = SlidePhasedState.allCases.last?.rawValue ?? 0
        return (store.current.rawValue, last)
    }
}

extension SlideIndexController {
    /// 戻れる先がない(最初のページの最初のフェーズ)か。
    @MainActor
    var isAtFirstStep: Bool {
        currentIndex == 0 && currentSlide.phaseStep(on: self).current == 0
    }

    /// 進める先がない(最後のページで、まだ出していないフェーズもない)か。
    /// ページ番号だけで判定すると、最後のページの段階表示が進められなくなる。
    @MainActor
    var isAtLastStep: Bool {
        guard currentIndex >= slides.count - 1 else { return false }
        let phase = currentSlide.phaseStep(on: self)
        return phase.current >= phase.last
    }
}

#if os(macOS)
/// スピーカーノートWindowの表示管理(macOS)。
@MainActor
public enum SpeakerNotesWindowPresenter {
    private static var window: NSWindow?

    /// ノートWindowを開閉する(トグル)。
    /// - Note: `orderFront` で表示するだけでキーウィンドウは奪わないので、
    ///   スライド側のキー操作(矢印/Page Up/Down)はそのまま効く。
    public static func toggle(
        slideIndexController: SlideIndexController,
        slideTheme: CustomSlideTheme
    ) {
        if let window, window.isVisible {
            window.close()
            Self.window = nil
            return
        }
        let view = SpeakerNotesView(
            slideIndexController: slideIndexController,
            slideTheme: slideTheme
        )
        let hosting = NSHostingController(rootView: view)
        let win = NSWindow(contentViewController: hosting)
        win.title = "Speaker Notes"
        win.styleMask = [.titled, .closable, .resizable, .miniaturizable]
        win.setContentSize(NSSize(width: 900, height: 820))
        win.isReleasedWhenClosed = false
        win.orderFront(nil)
        Self.window = win
    }
}
#endif

/// ノート本体のView。現在/次のプレビュー・ページ番号・経過時間・原稿を表示する。
struct SpeakerNotesView: View {
    @ObservedObject var slideIndexController: SlideIndexController
    let slideTheme: CustomSlideTheme
    /// 矢印 / Page Up/Down(クリッカー)でのページ送りをこの View 自身で受けるか。
    /// 別 Window(macOS / iPhone Duo)では true。SlideBaseView に埋め込むときは false にして
    /// 親(SlideBaseView)側の 1 か所でフォーカスとキー入力を持つ(表示の切り替えでフォーカスが迷子にならないように)
    var handlesKeyboardNavigation = true
    /// iPhone Duo の2画面表示(内側を縦持ち)用。スライドは外側に出ていて手元から見えないので、
    /// 幅が狭くても「現在」のプレビューを省かず、「現在」「次」を横に並べて上部に小さく出し、原稿の領域を広く取る
    var usesPortraitPresenterLayout = false
    /// 経過時間の起点(ノート画面を出し直しても保たれるよう SpeakerNotesSession が持つ)
    @ObservedObject private var session = SpeakerNotesSession.shared
    @FocusState private var isFocused: Bool
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    /// 幅が狭いWindow(iPhone Duo の内側ディスプレイを2分割した状態など)では、
    /// 隣のWindowにスライド本体が見えているので「現在」のプレビューを省いて原稿の領域を確保する。
    private var showsCurrentPreview: Bool {
#if os(iOS)
        usesPortraitPresenterLayout || horizontalSizeClass != .compact
#else
        true
#endif
    }

    private var currentIndex: Int { slideIndexController.currentIndex }

    /// ノートは各スライドの `script` プロパティ(Slideプロトコル)から取得する
    private var currentNote: String {
        let script = slideIndexController.currentSlide.script
        return script.isEmpty ? "(このスライドのノートはありません)" : script
    }

    private var currentSlideName: String {
        String(describing: type(of: slideIndexController.currentSlide))
    }

    /// 現在スライドのフェーズ段階
    private var currentPhase: (current: Int, last: Int) {
        slideIndexController.slides[currentIndex].phaseStep(on: slideIndexController)
    }

    /// 次のステップ(フェーズ or ページ)のスライドと、そのフェーズ段階。
    private var nextStep: (slide: any Slide, index: Int, phaseStep: Int)? {
        let slides = slideIndexController.slides
        let info = currentPhase
        if info.current < info.last {
            return (slides[currentIndex], currentIndex, info.current + 1)
        }
        let next = currentIndex + 1
        guard next < slides.count else { return nil }
        return (slides[next], next, 0)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 16) {
                if showsCurrentPreview {
                    previewPane(title: "現在") {
                        AnyView(slideIndexController.currentSlide)
                            .environment(\.previewPhaseStep, currentPhase.current)
                            .followsSlideLanguage()
                    }
                }
                previewPane(title: nextPaneTitle) {
                    if let nextStep {
                        AnyView(nextStep.slide)
                            .environment(\.previewPhaseStep, nextStep.phaseStep)
                            .followsSlideLanguage()
                    } else {
                        Text("最後のスライドです")
                            .font(.system(size: 40))
                            .foregroundStyle(.secondary)
                            .frame(width: SlideSize.standard16_9.width,
                                   height: SlideSize.standard16_9.height)
                    }
                }
            }

            HStack(alignment: .firstTextBaseline, spacing: 14) {
                Text("\(currentIndex + 1) / \(slideIndexController.slides.count)")
                    .font(.system(size: counterFontSize, weight: .heavy, design: .monospaced))
                    .fixedSize()
                Text(currentSlideName)
                    .font(.system(size: 16))
                    .foregroundStyle(.secondary)
                Spacer()
                Button {
                    session.timerStartDate = Date()
                } label: {
                    Image(systemName: "arrow.counterclockwise.circle.fill")
                        .font(.system(size: 22))
                }
                .buttonStyle(.plain)
                Text(session.timerStartDate, style: .timer)
                    .font(.system(size: 32, weight: .bold, design: .monospaced))
            }

            ScrollViewReader { scrollProxy in
                ScrollView {
                    // フェーズ持ちのスライドは、セグメントごとに「ここで次を表示」の
                    // 区切りを挟んで描画する(現在のセグメントを白、それ以外を淡色に)
                    if let segments = (slideIndexController.currentSlide as? any PhasedScriptProviding)?.scriptSegments,
                       !segments.isEmpty {
                        let activeIndex = min(currentPhase.current, segments.count - 1)
                        VStack(alignment: .leading, spacing: 14) {
                            ForEach(Array(segments.enumerated()), id: \.offset) { index, segment in
                                if index > 0 {
                                    phaseSeparator(isNext: index == activeIndex + 1)
                                }
                                Text(normalizedNote(segment))
                                    .font(.system(size: noteFontSize, weight: .medium))
                                    .lineSpacing(10)
                                    .foregroundStyle(index == activeIndex ? .white : .white.opacity(0.35))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .textSelection(.enabled)
                                    .id(index)
                            }
                        }
                    } else {
                        Text(normalizedNote(currentNote))
                            .font(.system(size: noteFontSize, weight: .medium))
                            .lineSpacing(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .textSelection(.enabled)
                            .id(0)
                    }
                }
                // ページ/フェーズが進んだら、いま話すセグメントを上端へ自動スクロールする
                .onChange(of: autoScrollKey) { _, _ in
                    scrollProxy.scrollTo(activeSegmentIndex, anchor: .top)
                }
                .onAppear {
                    scrollProxy.scrollTo(activeSegmentIndex, anchor: .top)
                }
            }

            // クリッカー無しでも進められるよう、ノート画面自体に左右のページ送りボタンを置く
            SlideNavigationBar(slideIndexController: slideIndexController)
        }
        .padding(20)
#if os(macOS)
        .frame(minWidth: 640, minHeight: 480)
#else
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.black)
#endif
        // ページ送り時のクロスフェード等を無効化(controller側のwithAnimationを打ち消す)
        .transaction { transaction in
            transaction.animation = nil
            transaction.disablesAnimations = true
        }
        .preferredColorScheme(.dark)
        // ノートWindowをクリックしてフォーカスが移っても、スライド送りできるようにしておく
#if os(iOS)
        // ノートは読み取り専用なので、キーボード入力のために編集フォーカスを要求しない。
        .focusable(handlesKeyboardNavigation, interactions: .activate)
#else
        .focusable(handlesKeyboardNavigation)
#endif
        .focused($isFocused)
        .focusEffectDisabled()
        .onKeyPress(keys: [.leftArrow, .pageUp]) { _ in
            guard handlesKeyboardNavigation else { return .ignored }
            Task { slideIndexController.back() }
            return .handled
        }
        .onKeyPress(keys: [.rightArrow, .pageDown]) { _ in
            guard handlesKeyboardNavigation else { return .ignored }
            Task { slideIndexController.forward() }
            return .handled
        }
        .onAppear {
            if handlesKeyboardNavigation { isFocused = true }
        }
    }

    /// ノート本文の文字サイズ。macOS は Vision Pro を装着したまま読めるよう大きめ、
    /// iOS(iPhone Duo / iPad の別Window)は手元で読む前提で小さめにしている。
    private var noteFontSize: CGFloat {
#if os(macOS)
        45
#else
        horizontalSizeClass == .compact ? 22 : 28
#endif
    }

    /// ページ番号の文字サイズ(狭いWindowでは折り返さないよう小さめに)
    private var counterFontSize: CGFloat {
#if os(macOS)
        34
#else
        horizontalSizeClass == .compact ? 24 : 30
#endif
    }

    /// 「ここで次を表示」区切りの文字サイズ(noteFontSize に合わせて縮める)
    private var separatorFontSize: CGFloat {
#if os(macOS)
        28
#else
        horizontalSizeClass == .compact ? 15 : 18
#endif
    }

    /// 表示用の整形: 連続する改行(空行)を1つにまとめ、前後の余白を落とす
    private func normalizedNote(_ text: String) -> String {
        text.replacingOccurrences(of: "\n{2,}", with: "\n", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// いま話すべきセグメントの位置(自動スクロールの対象)
    private var activeSegmentIndex: Int {
        guard let segments = (slideIndexController.currentSlide as? any PhasedScriptProviding)?.scriptSegments,
              !segments.isEmpty else { return 0 }
        return min(currentPhase.current, segments.count - 1)
    }

    /// ページ移動・フェーズ送りのどちらでも自動スクロールを発火させるためのキー
    private var autoScrollKey: String {
        "\(currentIndex)-\(currentPhase.current)"
    }

    /// 「ここで次を表示」の区切り線。次に進むべき箇所(現在の直後)は強調する。
    private func phaseSeparator(isNext: Bool) -> some View {
        HStack(spacing: 10) {
            Rectangle()
                .frame(height: 3)
                .foregroundStyle(isNext ? Color.orange : Color.white.opacity(0.25))
            Text("▼ ここで次を表示")
                .font(.system(size: separatorFontSize, weight: .bold))
                .foregroundStyle(isNext ? Color.orange : Color.white.opacity(0.35))
                .fixedSize()
            Rectangle()
                .frame(height: 3)
                .foregroundStyle(isNext ? Color.orange : Color.white.opacity(0.25))
        }
    }

    private var nextPaneTitle: String {
        guard let nextStep else { return "次" }
        return nextStep.index == currentIndex ? "次(このページの続き)" : "次のページ"
    }

    /// スライドを原寸で描画して縮小するプレビュー枠。
    private func previewPane(title: String, @ViewBuilder content: () -> some View) -> some View {
        let slideSize = SlideSize.standard16_9
        let slideContent = content()
        return VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.secondary)
            GeometryReader { proxy in
                let scale = proxy.size.width / slideSize.width
                slideContent
                    .environment(\.slideIndexController, slideIndexController)
                    .environment(\.isSlideThumbnail, true) // 動画やRealityViewはプレースホルダーに
                    .slideTheme(slideTheme)
                    .foregroundColor(.black)
                    .background(.white)
                    .frame(width: slideSize.width, height: slideSize.height)
                    .scaleEffect(scale, anchor: .topLeading)
                    .allowsHitTesting(false)
            }
            .aspectRatio(slideSize.width / slideSize.height, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
            }
        }
        .frame(maxWidth: .infinity)
    }
}


/// スピーカーノート画面用のページ送りバー(戻る / ページ番号 / 次へ)。
/// ページ送りはフェーズ送りも含む(SlideIndexController.forward/back と同じ)。
struct SlideNavigationBar: View {
    @ObservedObject var slideIndexController: SlideIndexController
    /// ボタンの高さ。分割パネルなど狭い場所では小さめにする
    var compact = false

    private var isFirst: Bool { slideIndexController.isAtFirstStep }
    private var isLast: Bool { slideIndexController.isAtLastStep }

    @AppStorage("speakerNotesControlsOnRight") private var controlsOnRight = false

    var body: some View {
        HStack(spacing: compact ? 8 : 16) {
            if controlsOnRight {
                pageCounter
                navigationButtons
            } else {
                navigationButtons
                pageCounter
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var pageCounter: some View {
        Text("\(slideIndexController.currentIndex + 1) / \(slideIndexController.slides.count)")
            .font(.system(size: compact ? 18 : 24, weight: .bold, design: .monospaced))
            .fixedSize()
            .frame(maxWidth: .infinity, alignment: controlsOnRight ? .leading : .trailing)
    }

    private var navigationButtons: some View {
        HStack(spacing: compact ? 8 : 16) {
            Button {
                slideIndexController.back()
            } label: {
                Label("戻る", systemImage: "chevron.left")
                    .font(compact ? .body : .title2)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .frame(maxWidth: .infinity, minHeight: compact ? 40 : 56)
            }
            .buttonStyle(.bordered)
            .disabled(isFirst)

            Button {
                slideIndexController.forward()
            } label: {
                Label("次へ", systemImage: "chevron.right")
                    .font(compact ? .body : .title2)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .frame(maxWidth: .infinity, minHeight: compact ? 40 : 56)
            }
            .buttonStyle(.borderedProminent)
            .disabled(isLast)
        }
        .frame(maxWidth: .infinity)
    }
}
