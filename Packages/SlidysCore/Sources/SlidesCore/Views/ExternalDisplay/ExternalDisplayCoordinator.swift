//
//  ExternalDisplayCoordinator.swift
//  SlidesCore
//
//  iPad を外部ディスプレイ(HDMI / AirPlay)につないで発表するための仕組み。
//  SlideKit の ExternalDisplayManager / SlideWindowSceneDelegate と同じ考え方で、
//  外部ディスプレイ用の UIWindowScene(role = externalDisplay)に自前の UIWindow を作り、
//  そこに発表中のデッキ(SpeakerNotesSession に登録されたもの)を表示する。
//  手元の iPad 側は SlideBaseView がスピーカーノート画面に切り替わる。
//
//  モード(手元の iPad をどう使うか):
//   - mirroring   : 手元にもスライドを出す(既定)。外部ディスプレイは自前 Window で同じデッキを描画する。
//                   Flutter のデモなど発表者がタップ操作するスライド(ExternalDisplayMirroringPreferred)では、
//                   別インスタンスを描いても操作が反映されないので、手元の画面をスナップショットで映す(ScreenMirrorView)
//   - presentation: 外部ディスプレイにスライド、手元にスピーカーノート
//  切り替えはナビゲーションバーの発表者メニューから手動で行う(デモ操作のときは「手元にもスライドを表示」、
//  終わったら「スピーカーノートに戻す」)
//  注意: Info.plist で外部ディスプレイの Scene を宣言すると OS のミラーリングは効かなくなる
//  (Window を外すと真っ黒になる)ので、外部ディスプレイの Window は常に持ち続ける。
//
//  アプリ側の配線:
//   - Info.plist の UIApplicationSceneManifest > UISceneConfigurations に
//     UIWindowSceneSessionRoleExternalDisplayNonInteractive として SlidysExternalDisplaySceneDelegate を登録する
//     (これが無いと UIKit は外部ディスプレイ用の Scene を作らず、OS のミラーリングになる)
//   - UIApplicationDelegate の application(_:configurationForConnecting:options:) で
//     `ExternalDisplayCoordinator.sceneConfiguration(for:)` を返す(Slidys は SlidysAppDelegate、
//     SlidysFlutter は FlutterAppDelegate に実装済み)
//

import SwiftUI
import SlideKit

/// 発表者がタップして操作するデモを含むスライド。手元にスライドを出しているとき、外部ディスプレイには
/// 別インスタンスではなく手元の画面のスナップショットを映す(操作が反映されるように)。
public protocol ExternalDisplayMirroringPreferred {}

public enum ExternalDisplayMode {
    case presentation
    case mirroring
}

#if os(iOS)
import Combine
import OSLog
import UIKit

private let externalDisplayLog = Logger(subsystem: "Slidys", category: "ExternalDisplay")

@MainActor
public final class ExternalDisplayCoordinator: ObservableObject {
    public static let shared = ExternalDisplayCoordinator()

    /// 外部ディスプレイが接続されているか
    @Published public private(set) var isConnected = false
    /// 発表者が選んだモード(既定はミラーリング。発表者メニューで「外部ディスプレイに出力」を選ぶと presentation)
    @Published public var preferredMode: ExternalDisplayMode = .mirroring

    /// 実際に適用されるモード(いまは preferredMode と同じ。将来の自動切り替え用に分けている)
    public var effectiveMode: ExternalDisplayMode { preferredMode }

    private let delegates = NSHashTable<ExternalDisplaySceneDelegate>.weakObjects()
    private var cancellables = Set<AnyCancellable>()

    private init() {
        $preferredMode
            .dropFirst()
            .sink { [weak self] _ in self?.applyMode() }
            .store(in: &cancellables)
    }

    public func togglePreferredMode() {
        preferredMode = preferredMode == .presentation ? .mirroring : .presentation
    }

    /// 外部ディスプレイ用の UISceneConfiguration。それ以外の役割なら nil。
    /// UIApplicationDelegate の configurationForConnecting から呼ぶ。
    public static func sceneConfiguration(for session: UISceneSession) -> UISceneConfiguration? {
        guard session.role == .externalDisplay else { return nil }
        let configuration = UISceneConfiguration(name: "External Display", sessionRole: session.role)
        configuration.delegateClass = ExternalDisplaySceneDelegate.self
        return configuration
    }

    fileprivate func register(_ delegate: ExternalDisplaySceneDelegate) {
        delegates.add(delegate)
        updateConnection()
    }

    fileprivate func unregister(_ delegate: ExternalDisplaySceneDelegate) {
        delegates.remove(delegate)
        updateConnection()
    }

    /// 検証用(ExternalDisplayPreviewOverlay): シミュレーターには外部ディスプレイの Scene が来ないので、
    /// 接続済みとして扱い、発表者メニューの「外部ディスプレイに出力」を試せるようにする
    private var simulatesConnection = false

    fileprivate func simulateConnection() {
        simulatesConnection = true
        updateConnection()
    }

    private func updateConnection() {
        isConnected = delegates.count > 0 || simulatesConnection
    }

    private func applyMode() {
        let mode = effectiveMode
        for delegate in delegates.allObjects {
            delegate.apply(mode: mode)
        }
    }
}

/// 外部ディスプレイの UIWindowScene に紐づくデリゲート。presentation モードのときだけ Window を持つ。
/// - Note: 外部ディスプレイ用の Scene は Info.plist の UIApplicationSceneManifest に
///   UIWindowSceneSessionRoleExternalDisplayNonInteractive の設定が無いと UIKit が作らない(OS のミラーリングのまま)。
///   そこで両アプリの Info.plist に、この ObjC 名(SlidysExternalDisplaySceneDelegate)を UISceneDelegateClassName として登録している。
@objc(SlidysExternalDisplaySceneDelegate)
public final class ExternalDisplaySceneDelegate: NSObject, UIWindowSceneDelegate {
    public var window: UIWindow?
    private weak var windowScene: UIWindowScene?

    public func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        externalDisplayLog.info("external scene willConnect role=\(session.role.rawValue, privacy: .public)")
        guard let windowScene = scene as? UIWindowScene else { return }
        self.windowScene = windowScene
        ExternalDisplayCoordinator.shared.register(self)
        apply(mode: ExternalDisplayCoordinator.shared.effectiveMode)
    }

    public func sceneDidDisconnect(_ scene: UIScene) {
        window = nil
        ExternalDisplayCoordinator.shared.unregister(self)
    }

    /// 外部ディスプレイの Window は常に持つ(中身の切り替えは ExternalDisplayRootView が行う)。
    @MainActor
    func apply(mode: ExternalDisplayMode) {
        guard window == nil, let windowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = UIHostingController(rootView: ExternalDisplayRootView())
        window.makeKeyAndVisible()
        self.window = window
        externalDisplayLog.info("external window created screen=\(windowScene.screen.bounds.debugDescription, privacy: .public)")
    }
}

/// 外部ディスプレイに出す内容。
///  - デッキ未登録: 手元の画面をそのまま映す(スナップショットによるミラーリング)
///  - タップ操作するデモのスライド(ExternalDisplayMirroringPreferred)で手元にもスライドを出しているとき: 同上
///  - それ以外: 登録されたデッキを外部ディスプレイ側で独立に描画する(手元はノートでもスライドでもよい)
struct ExternalDisplayRootView: View {
    @ObservedObject private var session = SpeakerNotesSession.shared
    @ObservedObject private var coordinator = ExternalDisplayCoordinator.shared

    var body: some View {
        Group {
            if let presentation = session.presentation {
                ExternalDisplayDeckView(
                    slideIndexController: presentation.slideIndexController,
                    slideTheme: presentation.slideTheme,
                    decorator: presentation.externalDisplaySlideDecorator,
                    mirrorsInteractiveSlides: coordinator.effectiveMode == .mirroring
                )
            } else {
                ScreenMirrorView()
            }
        }
        .background(Color.black)
        .ignoresSafeArea()
        .statusBarHidden(true)
    }
}

/// 登録されたデッキを外部ディスプレイに描画する。現在のスライドがタップ操作するデモで、手元にもスライドを
/// 出している(mirroring)ときだけ、手元の画面をスナップショットで映す。
private struct ExternalDisplayDeckView: View {
    @ObservedObject var slideIndexController: SlideIndexController
    let slideTheme: CustomSlideTheme
    /// デッキが登録した環境値の注入(Flutter の Router など)。これが無いと埋め込み View が空になる
    let decorator: ExternalDisplaySlideDecorator?
    let mirrorsInteractiveSlides: Bool

    private var shouldMirrorScreen: Bool {
        mirrorsInteractiveSlides && slideIndexController.currentSlide is ExternalDisplayMirroringPreferred
    }

    var body: some View {
        if shouldMirrorScreen {
            ScreenMirrorView()
        } else {
            PresentationView(slideSize: SlideSize.standard16_9) {
                decorated(
                    SlideRouterView(slideIndexController: slideIndexController)
                        .slideTheme(slideTheme)
                        .foregroundColor(.black)
                        .background(.white)
                        // 外部ディスプレイ側も、表示言語の切り替えに追従させる
                        .followsSlideLanguage()
                )
            }
        }
    }

    private func decorated(_ view: some View) -> AnyView {
        let base = AnyView(view)
        return decorator?(base) ?? base
    }
}

/// 手元(メインの UIWindowScene の画面)をスナップショットで映すミラーリング View。
/// OS のミラーリングは外部ディスプレイ Scene を宣言したアプリでは使えないため、自前で行う。
/// CADisplayLink で毎フレーム UIScreen.snapshotView を取り直し、アスペクト比を保って中央に収める。
struct ScreenMirrorView: UIViewRepresentable {
    func makeUIView(context: Context) -> ScreenMirrorUIView {
        ScreenMirrorUIView()
    }

    func updateUIView(_ uiView: ScreenMirrorUIView, context: Context) {}

    static func dismantleUIView(_ uiView: ScreenMirrorUIView, coordinator: ()) {
        uiView.stop()
    }
}

final class ScreenMirrorUIView: UIView {
    private var displayLink: CADisplayLink?
    private var snapshot: UIView?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil { start() } else { stop() }
    }

    private func start() {
        guard displayLink == nil else { return }
        let link = CADisplayLink(target: self, selector: #selector(tick))
        link.preferredFrameRateRange = CAFrameRateRange(minimum: 15, maximum: 30, preferred: 24)
        link.add(to: .main, forMode: .common)
        displayLink = link
    }

    func stop() {
        displayLink?.invalidate()
        displayLink = nil
        snapshot?.removeFromSuperview()
        snapshot = nil
    }

    /// 手元(アプリ本体)の画面
    private var sourceScreen: UIScreen? {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        return scenes.first { $0.session.role == .windowApplication && $0.activationState == .foregroundActive }?.screen
            ?? scenes.first { $0.session.role == .windowApplication }?.screen
    }

    private var tickCount = 0

    @objc private func tick() {
        guard let screen = sourceScreen else {
            if tickCount == 0 { externalDisplayLog.error("mirror: source screen not found") }
            tickCount += 1
            return
        }
        if tickCount == 0 { externalDisplayLog.info("mirror: start screen=\(screen.bounds.debugDescription, privacy: .public) bounds=\(self.bounds.debugDescription, privacy: .public)") }
        tickCount += 1
        let newSnapshot = screen.snapshotView(afterScreenUpdates: false)
        snapshot?.removeFromSuperview()
        let source = screen.bounds.size
        guard source.width > 0, source.height > 0, bounds.width > 0, bounds.height > 0 else { return }
        // アスペクト比を保って中央に収める(iPad は 4:3、外部ディスプレイは 16:9 が多い)
        let scale = min(bounds.width / source.width, bounds.height / source.height)
        let size = CGSize(width: source.width * scale, height: source.height * scale)
        newSnapshot.frame = CGRect(
            x: (bounds.width - size.width) / 2,
            y: (bounds.height - size.height) / 2,
            width: size.width,
            height: size.height
        )
        addSubview(newSnapshot)
        snapshot = newSnapshot
    }
}

/// Slidys(ネイティブ)アプリ用の UIApplicationDelegate。外部ディスプレイの Scene 設定だけを担当する。
public final class SlidysAppDelegate: NSObject, UIApplicationDelegate {
    public func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        externalDisplayLog.info("configurationForConnecting role=\(connectingSceneSession.role.rawValue, privacy: .public)")
        return ExternalDisplayCoordinator.sceneConfiguration(for: connectingSceneSession)
            ?? UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
    }

    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        ExternalDisplayPreviewOverlay.installIfRequested()
        // クリッカー(矢印 / Page Up/Down)をアプリ全体で受ける
        SlideClickerKeyInterceptor.install()
        return true
    }
}

/// 検証用: 起動引数 `-SlidysExternalDisplayPreview` を付けると、外部ディスプレイに出す内容
/// (ExternalDisplayRootView)を手元画面の左上に小窓で重ねる。シミュレーターには外部ディスプレイの
/// Scene が渡らないため、描画内容だけをこれで確認する。操作は透過する。
@MainActor
public enum ExternalDisplayPreviewOverlay {
    private static var window: UIWindow?

    public static func installIfRequested() {
        guard ProcessInfo.processInfo.arguments.contains("-SlidysExternalDisplayPreview") else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            guard window == nil,
                  let scene = UIApplication.shared.connectedScenes
                    .compactMap({ $0 as? UIWindowScene })
                    .first(where: { $0.session.role == .windowApplication }) else { return }
            ExternalDisplayCoordinator.shared.simulateConnection()
            let overlay = UIWindow(windowScene: scene)
            overlay.frame = CGRect(x: 16, y: 60, width: 480, height: 270)
            overlay.windowLevel = .statusBar - 1
            overlay.isUserInteractionEnabled = false
            overlay.layer.borderColor = UIColor.orange.cgColor
            overlay.layer.borderWidth = 3
            overlay.rootViewController = UIHostingController(rootView: ExternalDisplayRootView())
            overlay.isHidden = false
            window = overlay
            externalDisplayLog.info("preview overlay installed")
        }
    }
}
#endif
