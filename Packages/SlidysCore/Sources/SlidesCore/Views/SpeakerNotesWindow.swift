//
//  SpeakerNotesWindow.swift
//  SlidesCore
//
//  発表者用のスピーカーノートWindow(macOS専用)。
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

/// スピーカーノートWindowの表示管理。
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

/// ノート本体のView。現在/次のプレビュー・ページ番号・経過時間・原稿を表示する。
struct SpeakerNotesView: View {
    @ObservedObject var slideIndexController: SlideIndexController
    let slideTheme: CustomSlideTheme
    @State private var startDate = Date()
    @FocusState private var isFocused: Bool

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
                previewPane(title: "現在") {
                    AnyView(slideIndexController.currentSlide)
                        .environment(\.previewPhaseStep, currentPhase.current)
                }
                previewPane(title: nextPaneTitle) {
                    if let nextStep {
                        AnyView(nextStep.slide)
                            .environment(\.previewPhaseStep, nextStep.phaseStep)
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
                    .font(.system(size: 28, weight: .heavy, design: .monospaced))
                Text(currentSlideName)
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
                Spacer()
                Button {
                    startDate = Date()
                } label: {
                    Image(systemName: "arrow.counterclockwise.circle.fill")
                        .font(.system(size: 18))
                }
                .buttonStyle(.plain)
                Text(startDate, style: .timer)
                    .font(.system(size: 26, weight: .bold, design: .monospaced))
            }

            ScrollView {
                Text(currentNote)
                    .font(.system(size: 23, weight: .medium))
                    .lineSpacing(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)
            }
            .id(currentIndex) // ページが変わったらスクロール位置を先頭へ戻す
        }
        .padding(20)
        .frame(minWidth: 640, minHeight: 480)
        // ページ送り時のクロスフェード等を無効化(controller側のwithAnimationを打ち消す)
        .transaction { transaction in
            transaction.animation = nil
            transaction.disablesAnimations = true
        }
        .preferredColorScheme(.dark)
        // ノートWindowをクリックしてフォーカスが移っても、スライド送りできるようにしておく
        .focusable()
        .focused($isFocused)
        .focusEffectDisabled()
        .onKeyPress(keys: [.leftArrow, .pageUp]) { _ in
            Task { slideIndexController.back() }
            return .handled
        }
        .onKeyPress(keys: [.rightArrow, .pageDown]) { _ in
            Task { slideIndexController.forward() }
            return .handled
        }
        .onAppear { isFocused = true }
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
#endif
