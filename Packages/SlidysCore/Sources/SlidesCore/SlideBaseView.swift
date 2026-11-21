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
    /// このデッキが対応している表示言語。2 つ以上あるデッキだけ、発表者メニューに言語の切り替えが出る
    var supportedLanguages: [SlideLanguage] { get }
}

public extension SlideConfigurationProtocol {
    var size: CGSize {
        return SlideSize.standard16_9
    }

    /// 既定は多言語対応なし
    var supportedLanguages: [SlideLanguage] { [] }
}

public struct SlideBaseView: View {
    @FocusState private var isFocused: Bool
    @AppStorage("speakerNotesControlsOnRight") private var speakerNotesControlsOnRight = false
    @State private var timeRemaining: TimeInterval
    @State private var isTimerRunning = false
    @State private var timer: Timer?
    
    private let timerDuration: Duration

    // NOTE: コントローラの参照は必ず @StateObject の slideIndexController を使うこと。
    // slideConfiguration はデッキ側(computed な `var view` 等)の再評価で
    // 新しいインスタンスに差し替わることがあり、slideConfiguration.slideIndexController を
    // 直接使うと「スライド送りとスピーカーノートが別のコントローラを見る」事故が起きる。
    var presentationContentView: some View {
        SlideRouterView(slideIndexController: slideIndexController)
            .slideTheme(slideTheme)
            .foregroundColor(.black)
            .background(.white)
            // 文言は描画時に引くので、表示言語が変わったら作り直して引き直させる
            .id(languageStore.language)
            .environment(\.locale, languageStore.language.locale)
    }

    /// 表示言語(多言語対応デッキで、発表中にメニューから切り替える)
    @ObservedObject private var languageStore = SlideLanguageStore.shared
    private let listTextStyle: ListTextStyle

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
        self.listTextStyle = listTextStyle
        self.slideTheme = CustomSlideTheme(
            showSlideIndex: showSlideIndex,
            showsTotalSlideCount: showsTotalSlideCount,
            listTextStyle: listTextStyle
        )
    }

#if os(iOS)
    /// iPad/iPhoneでの原稿確認用: スライド+スピーカーノートの2分割表示にするか。
    /// 既定はスライドのみ。スライド中央上部の不可視領域を2秒長押し、
    /// またはハードウェアキーボードの「P」で切り替える。
    @State private var showsSpeakerNotesPanel = false
    /// 発表者メニューの「ページを選ぶ」で出す一覧
    @State private var showsPagePicker = false
    @Environment(\.supportsMultipleWindows) private var supportsMultipleWindows
    /// ヒンジが閉じているか(iOS 27.1+ の onHingeChange から取得。非折りたたみ端末や未取得時は nil)
    @State private var isHingeClosed: Bool?
    @State private var isHingePartiallyOpen = false
    /// 外部ディスプレイ(HDMI / AirPlay)の接続状態とモード
    @ObservedObject private var externalDisplay = ExternalDisplayCoordinator.shared
    @ObservedObject private var slideCapture = PresenterSlideCapture.shared
    /// iPhone Duo で内側・外側の両ディスプレイを点けるためのダミーのカメラセッション
    @ObservedObject private var dualDisplayCapture = DualDisplayCaptureKeeper.shared
    /// 呼び出し側から渡される「スライドを閉じる」操作(発表者メニューに出す)
    @Environment(\.slideCloseAction) private var slideCloseAction
    /// 外部ディスプレイ用のスライドに環境値(Flutter の Router など)を付け直す処理(デッキが登録する)
    @Environment(\.externalDisplaySlideDecorator) private var externalDisplaySlideDecorator

    private var displayRouting: PresenterDisplayRouting {
        PresenterDisplayRouting(
            externalConnected: externalDisplay.isConnected,
            externalPresentation: externalDisplay.effectiveMode == .presentation,
            duoEnabled: dualDisplayCapture.isRunning,
            duoMode: dualDisplayCapture.displayMode,
            capturesOutput: slideCapture.output.usesCapturedSlides
        )
    }

    private var showsPresenterNotesForExternalDisplay: Bool { displayRouting.mainShowsPresenterNotes }

    private func toggleSpeakerNotes() {
        if externalDisplay.effectiveMode == .systemMirroring {
            showsSpeakerNotesPanel = false
            externalDisplay.finishSystemMirroringDemo()
            return
        }
        if showsPresenterNotesForExternalDisplay {
            externalDisplay.preferredMode = .mirroring
            if dualDisplayCapture.isRunning { dualDisplayCapture.displayMode = .mirroredSlides }
            showsSpeakerNotesPanel = false
        } else if dualDisplayCapture.isRunning && dualDisplayCapture.displayMode == .innerSlides {
            dualDisplayCapture.displayMode = .outerSlides
        } else {
            // Notes requested here always stay in this view; never open another scene.
            showsSpeakerNotesPanel.toggle()
        }
    }

#endif

    public var body: some View {
#if os(iOS)
        GeometryReader { proxy in
            if displayRouting.mainMirrorsOuter {
                PresenterSlideMirrorView()
            } else if let division = tabletopDivision(in: proxy) {
                DuoTabletopLayout(division: division) {
                    presentationBody
                } controls: {
                    if showsSpeakerNotesPanel || showsPresenterNotesForExternalDisplay {
                        SpeakerNotesPanel(slideIndexController: slideIndexController)
                    } else {
                        SlideNavigationBar(slideIndexController: slideIndexController)
                            .padding(24)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(.black)
                    }
                }
            } else if showsPresenterNotesForExternalDisplay {
                externalDisplayPresenterBody
                    // 埋め込みカメラなどで隠れる領域(reserved region の occlusion)にノートが重ならないよう避ける
                    .padding(occlusionInsets(in: proxy))
                    .background(Color.black.ignoresSafeArea())
            } else if showsSpeakerNotesPanel {
                if proxy.size.width < proxy.size.height {
                    // 縦長(iPhone Duo の外側ディスプレイなど): 上にスライド、下にスピーカーノート
                    VStack(spacing: 0) {
                        presentationBody
                        SpeakerNotesPanel(slideIndexController: slideIndexController)
                            .frame(height: proxy.size.height * 0.45)
                    }
                } else {
                    // YouTube(iPad)風: 左にスライド、右にスピーカーノート
                    HStack(spacing: 0) {
                        presentationBody
                        SpeakerNotesPanel(slideIndexController: slideIndexController)
                            .frame(width: proxy.size.width * 0.34)
                    }
                }
            } else {
                presentationBody
            }
        }
        .modifier(HingeClosedObserver(isHingeClosed: $isHingeClosed, isPartiallyOpen: $isHingePartiallyOpen))
        .background {
#if !targetEnvironment(macCatalyst)
            if #available(iOS 27.0, *) {
                ExternalDisplayAccessoryView()
            }
#endif
        }
        // 画面上端のシステムジェスチャー(通知センター等)を1段遅らせて、
        // 上部の長押し領域へのタッチ配送が保留されないようにする
        .defersSystemGestures(on: .top)
        // 外部ディスプレイ側(ExternalDisplayRootView)と別Windowのノート画面に、発表中のデッキを共有する。
        // (スライド本体の View はノート表示中に消えるので、ここで登録・解除する)
        .onAppear {
            // スライドを開いたときの言語は、アプリに適用されている言語にする
            languageStore.resetToAppDefault()
            SpeakerNotesSession.shared.attach(
                slideIndexController,
                slideTheme: slideTheme,
                externalDisplaySlideDecorator: externalDisplaySlideDecorator
            )
        }
        .modifier(CameraCaptureDeckAccessory(dualDisplayCapture: dualDisplayCapture))
        .onDisappear {
            SpeakerNotesSession.shared.detach(slideIndexController)
            // スライドを閉じたらカメラも止める(使わないカメラを動かし続けない)
            dualDisplayCapture.stop()
        }
        // 発表者メニュー。スライド表示中は右上(旧・閉じるボタンの位置)、
        // 外部ディスプレイ出力中(手元はノート)は左上に置く
        .toolbar {
            if showsPresenterNotesForExternalDisplay {
                ToolbarItem(placement: .topBarLeading) { presenterMenu }
            } else {
                ToolbarItem(placement: .topBarTrailing) { presenterMenu }
            }
        }
        // ハードウェアキーボード / クリッカー: 「P」でノートパネル切り替え、矢印/Page Up/Downで送り。
        // スライド本体とノート画面はモード切り替えで入れ替わる(消える)ので、常に存在するこの外側の View が
        // フォーカスを持つ。切り替え直後にフォーカスが外れることがあるので、モードが変わったら取り直す
        // キー操作は受けるが、テキスト編集用フォーカスは要求しない。
        // メニューへフォーカスが移った際にソフトウェアキーボードが出るのを避ける。
        .focusable(interactions: .activate)
        .focused($isFocused)
        .focusEffectDisabled()
        .onKeyPress(KeyEquivalent("p")) {
            toggleSpeakerNotes()
            return .handled
        }
        .onKeyPress(keys: [.leftArrow, .pageUp]) { _ in
            Task { slideIndexController.back() }
            return .handled
        }
        .onKeyPress(keys: [.rightArrow, .pageDown]) { _ in
            Task { slideIndexController.forward() }
            return .handled
        }
        .onAppear { isFocused = true }
        .sheet(isPresented: $showsPagePicker, onDismiss: refocusForKeyboardNavigation) {
            SlidePagePickerView(slideIndexController: slideIndexController, listTextStyle: listTextStyle)
                // iPad では既定のシートが小さいので、ページ大のシートにしてサムネイルを多く見せる
                .presentationSizing(.page)
        }
        .onChange(of: showsPresenterNotesForExternalDisplay) { _, showsNotes in
            refocusForKeyboardNavigation()
        }
        .onChange(of: showsSpeakerNotesPanel) { _, _ in
            refocusForKeyboardNavigation()
        }
#else
        presentationBody
            .onAppear { languageStore.resetToAppDefault() }
#endif
    }

#if os(iOS)
    /// 画面構成が入れ替わった直後はフォーカスが消えることがあるので、少し待ってから取り直す
    private func tabletopDivision(in proxy: GeometryProxy) -> CGRect? {
#if canImport(UIKit, _version: 9127.0.85)
        if #available(iOS 27.1, *), isHingePartiallyOpen,
           UIDevice.current.userInterfaceIdiom == .phone {
            return proxy.reservedRegions(kind: .division)
                .filter { $0.isActive }
                .map(\.frame)
                .first { $0.width > proxy.size.width * 0.5 && $0.height < proxy.size.height * 0.3 && $0.minY > 0 && $0.maxY < proxy.size.height }
        }
#endif
        return nil
    }

    private func refocusForKeyboardNavigation() {
        isFocused = false
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(300))
            isFocused = true
        }
    }

    /// 画面内で他の要素(iPhone Duo の内側ディスプレイの埋め込みカメラなど)に隠れる領域を、
    /// いちばん近い辺からの余白に変換する。iOS 27.1 未満 / SDK 27.1 未満では余白なし
    private func occlusionInsets(in proxy: GeometryProxy) -> EdgeInsets {
        var insets = EdgeInsets()
#if canImport(UIKit, _version: 9127.0.85)
        guard #available(iOS 27.1, *) else { return insets }
        let size = proxy.size
        for region in proxy.reservedRegions(kind: .occlusion) where region.isActive {
            let frame = region.frame.intersection(CGRect(origin: .zero, size: size))
            guard !frame.isNull, !frame.isEmpty else { continue }
            // 各辺までの距離が最小の辺に寄っているとみなし、その辺から領域の奥までを空ける
            let distances: [(Edge, CGFloat)] = [
                (.top, frame.minY),
                (.bottom, size.height - frame.maxY),
                (.leading, frame.minX),
                (.trailing, size.width - frame.maxX),
            ]
            guard let nearest = distances.min(by: { $0.1 < $1.1 })?.0 else { continue }
            switch nearest {
            case .top: insets.top = max(insets.top, frame.maxY)
            case .bottom: insets.bottom = max(insets.bottom, size.height - frame.minY)
            case .leading: insets.leading = max(insets.leading, frame.maxX)
            case .trailing: insets.trailing = max(insets.trailing, size.width - frame.minX)
            }
        }
#endif
        return insets
    }

    /// 外部ディスプレイ接続中(手元はノート)の画面。ページ送りはノート画面内のバーで行う。
    /// 手元にスライドを出す切り替えは左上の発表者メニューから
    private var externalDisplayPresenterBody: some View {
        SpeakerNotesView(
            slideIndexController: slideIndexController,
            slideTheme: slideTheme,
            // キー入力(クリッカー)は外側の body で一括して受ける
            handlesKeyboardNavigation: false,
            // iPhone Duo の2画面表示中は内側を縦持ちで使う(外側にスライドが出ていて手元からは見えない)
            usesPortraitPresenterLayout: dualDisplayCapture.isRunning,
            interactiveCurrentSlide: displayRouting.interactiveMainPreview
        )
            .background(Color.black)
            .preferredColorScheme(.dark)
    }

    @ViewBuilder
    fileprivate var externalDisplayMenuItems: some View {
                    Button {
                        showsSpeakerNotesPanel = false
                        externalDisplay.beginPresenterCaptureDemo()
                    } label: {
                        Label("操作デモ（Duo維持・試験）", systemImage: "play.rectangle")
                    }
                    Button {
                        showsSpeakerNotesPanel = false
                        externalDisplay.finishSystemMirroringDemo()
                    } label: {
                        Label("外部にスライド・手元にノート（通常）", systemImage: "note.text")
                    }
                    Menu("その他・緊急用") {
                        Button {
                            showsSpeakerNotesPanel = false
                            externalDisplay.beginSystemMirroringDemo()
                        } label: {
                            Label("HDMIのみでデモ（Duo停止）", systemImage: "tv")
                        }
                        Button {
                            showsSpeakerNotesPanel = false
                            externalDisplay.preferredMode = .mirroring
                            if dualDisplayCapture.isRunning { dualDisplayCapture.displayMode = .mirroredSlides }
                        } label: {
                            Label(dualDisplayCapture.isRunning ? "手元にもスライドを表示（画像転送）" : "手元にもスライドを表示（OSミラーリング）", systemImage: "rectangle.on.rectangle")
                        }
                    }
    }

    /// 発表者メニュー(ナビゲーションバー)。スピーカーノート・外部ディスプレイ・閉じる、をここに集約する
    private var presenterMenu: some View {
        Menu { presenterMenuItems } label: { Image(systemName: "ellipsis.circle") }
    }

    @ViewBuilder fileprivate var presenterMenuItems: some View {
            Button {
                toggleSpeakerNotes()
            } label: {
                Label(
                    (showsSpeakerNotesPanel || showsPresenterNotesForExternalDisplay)
                        ? "スピーカーノートを閉じる" : "スピーカーノートを表示",
                    systemImage: "note.text"
                )
            }

            Menu {
                Button {
                    slideIndexController.backToFirst()
                } label: {
                    Label("最初のスライドへ", systemImage: "arrowshape.turn.up.backward.2")
                }
                Button {
                    showsPagePicker = true
                } label: {
                    Label("ページを選ぶ", systemImage: "square.grid.3x3")
                }
            } label: {
                Label("ページ移動", systemImage: "square.grid.3x3")
            }

            if externalDisplay.isConnected || externalDisplay.effectiveMode == .systemMirroring {
                Menu {
                    externalDisplayMenuItems
                } label: {
                    Label("外部ディスプレイ", systemImage: "tv")
                }
            }

            if UIDevice.current.userInterfaceIdiom == .phone && supportsMultipleWindows {
                DuoDisplayModeMenu()
            }

            if (externalDisplay.isConnected || dualDisplayCapture.isRunning) && externalDisplay.effectiveMode != .systemMirroring {
                Picker("スライドの出力方式", selection: $slideCapture.output) {
                    ForEach(PresenterSlideOutput.allCases) { output in
                        Text(output.title).tag(output)
                    }
                }
                .pickerStyle(.menu)
            }

            if slideCapture.output == .systemCapture {
                Button("画面共有を選び直す", systemImage: "rectangle.on.rectangle") {
                    slideCapture.restartSystemCapture()
                }
            }

            Menu {
                // 多言語対応しているデッキだけ、表示言語を切り替えられる
                if slideConfiguration.supportedLanguages.count > 1 {
                    Picker(selection: $languageStore.language) {
                        ForEach(slideConfiguration.supportedLanguages) { language in
                            Text(language.displayName).tag(language)
                        }
                    } label: {
                        Label("言語 / Language", systemImage: "globe")
                    }
                    .pickerStyle(.menu)
                }

                Picker(selection: $speakerNotesControlsOnRight) {
                    Text("左寄せ").tag(false)
                    Text("右寄せ").tag(true)
                } label: {
                    Label("ノートの操作ボタン配置", systemImage: "hand.point.up.left")
                }
                .pickerStyle(.menu)
            } label: {
                Label("表示設定", systemImage: "slider.horizontal.3")
            }

            if let slideCloseAction {
                Divider()
                Button(role: .destructive) {
                    slideCloseAction()
                } label: {
                    Label("スライドを閉じる", systemImage: "xmark.circle")
                }
            }
    }

#endif

    private var presentationBody: some View {
        // iOS は呼び出し側(SlidysCommonView)の NavigationStack に載せて閉じるボタン等を toolbar で出すため、
        // ここでは NavigationStack を作らない(入れ子にすると toolbar の配置が崩れる)。
        navigationContainer {
            presentationContainer {
                GeometryReader { proxy in
                    let circleHeight = proxy.size.height * 1
                    ZStack {
                        presentationContentView
                            .frame(maxHeight: .infinity)
                    }
                    // GeometryReader いっぱいに広げ、overlay の原点を proxy の座標系と一致させる(穴の座標がずれないように)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
#if !os(visionOS)
                    // 左上・右上を中心とする半径=画面高さの透明な円がページ送りのタップ領域。
                    // スライド内で `.excludesFromSlideTapNavigation()` を付けた領域(埋め込みデモなど)は
                    // 円からくり抜き、そこへのタップは中の View に届くようにする。
                    // preference はスライド本体から上がってくるので、その親(この ZStack)に overlayPreferenceValue を付ける
                    // (兄弟の Color.clear などに付けても値は届かず、穴が空かない)
                    .overlayPreferenceValue(SlideTapNavigationExclusionKey.self) { anchors in
                        let holes = anchors.map { proxy[$0] }
                        let radius = circleHeight / 2
                        Circle()
                            .frame(width: circleHeight, height: circleHeight)
                            .foregroundStyle(Color.black.opacity(0.01))
                            // 円のローカル座標系は原点が (-r, -r) なので穴を平行移動する
                            .contentShape(HoledCircleShape(holes: holes.map { $0.offsetBy(dx: radius, dy: radius) }))
                            .onTapGesture {
                                // SymbolQuizのViewなどでFocusが移動した時に、再度Focusを有効にする処理
                                isFocused = true
                                Task {
                                    slideIndexController.back()
                                }
                            }
                            .position(x: 0, y: 0)
                        Circle()
                            .frame(width: circleHeight, height: circleHeight)
                            .foregroundStyle(Color.black.opacity(0.01))
                            // 右上の円のローカル原点は (width - r, -r)
                            .contentShape(HoledCircleShape(holes: holes.map { $0.offsetBy(dx: -(proxy.size.width - radius), dy: radius) }))
                            .onTapGesture {
                                isFocused = true
                                Task {
                                    slideIndexController.forward()
                                }
                            }
                            .position(x: proxy.size.width, y: 0)
                    }
#endif
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
                            .disabled(slideIndexController.isAtFirstStep)

                            Text("\(slideIndexController.currentIndex + 1)/\(slideIndexController.slides.count)")
                                .font(.largeTitle)

                            Button {
                                slideIndexController.forward()
                            } label: {
                                Image(systemName: "chevron.right")
                            }
                            .disabled(slideIndexController.isAtLastStep)
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
                slideIndexController.back()
            }
            return .handled
        }
        .onKeyPress(keys: [.rightArrow, .pageDown]) { _ in
            isFocused = true
            Task {
                slideIndexController.forward()
            }
            return .handled
        }
        // 「P」でスピーカーノートWindowを開閉(ノートは各スライドの script プロパティから表示)
        .onKeyPress(KeyEquivalent("p")) {
            Task { @MainActor in
                SpeakerNotesWindowPresenter.toggle(
                    slideIndexController: slideIndexController,
                    slideTheme: slideTheme
                )
            }
            return .handled
        }
#endif
    }
}

#if os(iOS)
/// iPhone Duo の2画面表示: カメラセッション実行中に外側ディスプレイへ発表中のデッキを出す(iOS 27.1+)。
/// 外側に出すのは外部ディスプレイ出力と同じ ExternalDisplayDeckView(SpeakerNotesSession に登録されたデッキ)。
/// - Note: `CameraCaptureAccessory` は iOS 27.1 SDK(Xcode 27.1 以降)にしか無いので、HingeClosedObserver と同じく
///   UIKit のモジュールバージョンで SDK を見分ける。
private struct CameraCaptureDeckAccessory: ViewModifier {
    @ObservedObject var dualDisplayCapture: DualDisplayCaptureKeeper

    func body(content: Content) -> some View {
#if canImport(UIKit, _version: 9127.0.85)
        if #available(iOS 27.1, *) {
            content
                .sceneAccessory {
                    CameraCaptureAccessory(isEnabled: .constant(dualDisplayCapture.isRunning)) {
                        CameraCaptureDeckView()
                    }
                }
        } else {
            content
                .onAppear { dualDisplayError("CameraCaptureAccessory unavailable: iOS < 27.1") }
        }
#else
        content
            .onAppear { dualDisplayError("CameraCaptureAccessory unavailable: built with SDK < 27.1") }
#endif
    }
}

/// 外側ディスプレイに出すデッキ。デッキ未登録(スライドを閉じた直後など)は黒画面にする
/// 外側ディスプレイは縦長(466x678)で渡されるときと、端末の向きに合わせて OS が横長(678x466)で渡すときがある。
/// 聴衆には常に横向きで見せるので、縦長で渡されたときだけスライドを 90° 回して画面いっぱいに収める
private struct CameraCaptureDeckView: View {
    @ObservedObject private var session = SpeakerNotesSession.shared
    @ObservedObject private var dualDisplayCapture = DualDisplayCaptureKeeper.shared
    @ObservedObject private var slideCapture = PresenterSlideCapture.shared

    var body: some View {
        GeometryReader { proxy in
            let showsNotes = dualDisplayCapture.displayMode == .innerSlides
            let needsRotation = !showsNotes && proxy.size.height > proxy.size.width
            Group {
                if let presentation = session.presentation {
                    if showsNotes {
                        NavigationStack {
                            SpeakerNotesView(
                                slideIndexController: presentation.slideIndexController,
                                slideTheme: presentation.slideTheme,
                                usesPortraitPresenterLayout: true,
                                interactiveCurrentSlide: slideCapture.output.usesCapturedSlides
                            )
                            .toolbar {
                                ToolbarItem(placement: .topBarTrailing) { DuoDisplayModeMenu() }
                            }
                        }
                        .modifier(DuoNotesCaseMargin())
                        .preferredColorScheme(.dark)
                    } else if dualDisplayCapture.displayMode == .mirroredSlides || slideCapture.output.usesCapturedSlides {
                        PresenterSlideMirrorView()
                    } else {
                        ExternalDisplayDeckView(
                            slideIndexController: presentation.slideIndexController,
                            slideTheme: presentation.slideTheme,
                            decorator: presentation.externalDisplaySlideDecorator
                        )
                    }
                } else {
                    Color.black
                }
            }
            .frame(
                width: needsRotation ? proxy.size.height : proxy.size.width,
                height: needsRotation ? proxy.size.width : proxy.size.height
            )
            .rotationEffect(.degrees(needsRotation ? (dualDisplayCapture.rotatesOuterClockwise ? 90 : -90) : 0))
            .position(x: proxy.size.width / 2, y: proxy.size.height / 2)
        }
        .background(Color.black)
        .ignoresSafeArea()
        .statusBarHidden(true)
    }
}

/// Shared by the inner menu and the presenter's outer-display notes.
private struct DuoDisplayModeMenu: View {
    @ObservedObject private var keeper = DualDisplayCaptureKeeper.shared
    @ObservedObject private var capture = PresenterSlideCapture.shared

    var body: some View {
        Menu {
            ForEach(DuoDisplayMode.allCases) { mode in
                Button {
                    keeper.start(mode: mode)
                } label: {
                    if keeper.isRunning && keeper.displayMode == mode {
                        Label(mode.title, systemImage: "checkmark")
                    } else {
                        Text(mode.title)
                    }
                }
            }
            if keeper.isRunning {
                Divider()
                if keeper.displayMode == .innerSlides {
                    DuoNotesCaseMarginMenu()
                }
                if keeper.displayMode != .mirroredSlides {
                    Picker("スライドの出力方式", selection: $capture.output) {
                        ForEach(PresenterSlideOutput.allCases) { output in
                            Text(output.title).tag(output)
                        }
                    }
                    .pickerStyle(.menu)
                }
                if keeper.displayMode != .innerSlides {
                    Button("外側のスライドの上下を反転", systemImage: "arrow.trianglehead.2.clockwise.rotate.90") {
                        keeper.rotatesOuterClockwise.toggle()
                    }
                }
                Button("2画面表示を終了", systemImage: "video.slash") { keeper.stop() }
            }
            if let error = keeper.lastError { Text(error) }
        } label: {
            Label("iPhone Duo", systemImage: "rectangle.split.2x1")
        }
    }
}

#endif

#if os(iOS)
/// iPhone Duo のヒンジ状態(閉じているか)を観測する。iOS 27.1 未満や非折りたたみ端末では nil のまま。
/// - Note: `onHingeChange` / `UIHingeInteraction` は iOS 27.1 SDK(Xcode 27.1 以降)にしか無い。
///   `#available` は実行時の判定なので、Xcode 27.0 の SDK ではコンパイル自体が通らない。
///   SDK の有無は UIKit のモジュールバージョン(27.0 = 9127.0.84、27.1 = 9127.0.85)で見分ける。
private struct HingeClosedObserver: ViewModifier {
    @Binding var isHingeClosed: Bool?
    @Binding var isPartiallyOpen: Bool

    func body(content: Content) -> some View {
#if canImport(UIKit, _version: 9127.0.85)
        if #available(iOS 27.1, *) {
            content.onHingeChange { _, context in
                isHingeClosed = context.hinge.map { $0.status == .closed }
                isPartiallyOpen = context.hinge?.status == .partiallyOpen
            }
        } else {
            content
        }
#else
        // Xcode 27.0 以前の SDK: ヒンジ API が無いので観測しない(横幅サイズクラスでの判定にフォールバック)
        content
#endif
    }
}
#endif

private extension SlideBaseView {
    /// macOS/visionOS は toolbar(ornament) を使うので NavigationStack で包む。iOS は包まない。
    @ViewBuilder
    func navigationContainer<Content: View>(@ViewBuilder content: () -> Content) -> some View {
#if os(iOS)
        content()
#else
        NavigationStack {
            content()
        }
#endif
    }

    /// スライドを収めるコンテナ。iOS は safe area を尊重する自前のもの、他は SlideKit の PresentationView。
    @ViewBuilder
    func presentationContainer<Content: View>(@ViewBuilder content: @escaping () -> Content) -> some View {
#if os(iOS)
        SlidePresentationView(slideSize: slideConfiguration.size, content: content)
#else
        PresentationView(slideSize: slideConfiguration.size, content: content)
#endif
    }

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

#if os(iOS)
@MainActor private struct PresenterControlsPreviewConfiguration: SlideConfigurationProtocol {
    let slideIndexController = SlideIndexController {
        CenterTextSlide(text: "操作するスライド", script: "ここに発表者のノートを表示します。スライドを操作しても聴衆にはノートを出しません。")
        CenterTextSlide(text: "次のスライド", script: "次のページのノートです。")
    }
}

#Preview("発表者メニューの項目", traits: .fixedLayout(width: 400, height: 500)) {
    NavigationStack {
        List {
            SlideBaseView(slideConfiguration: PresenterControlsPreviewConfiguration()).presenterMenuItems
        }
        .navigationTitle("発表者メニュー")
    }
    .environment(\.slideCloseAction, {})
}

#Preview("Duo外側のノート", traits: .fixedLayout(width: 678, height: 466)) {
    NavigationStack {
        SpeakerNotesView(
            slideIndexController: PresenterControlsPreviewConfiguration().slideIndexController,
            slideTheme: CustomSlideTheme(showSlideIndex: false, listTextStyle: .large),
            usesPortraitPresenterLayout: true,
            interactiveCurrentSlide: true
        )
        .toolbar { ToolbarItem(placement: .topBarTrailing) { DuoDisplayModeMenu() } }
    }
    .preferredColorScheme(.dark)
}
#Preview("本番構成の外部表示メニュー", traits: .fixedLayout(width: 500, height: 340)) {
    NavigationStack {
        List {
            SlideBaseView(slideConfiguration: PresenterControlsPreviewConfiguration()).externalDisplayMenuItems
        }
        .navigationTitle("外部ディスプレイ")
    }
}
#endif
