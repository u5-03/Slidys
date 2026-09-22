//
//  SpeakerNotesScene.swift
//  SlidesCore
//
//  iPhone Duo(内側ディスプレイ)/iPad 向け: スピーカーノートを別Windowとして開くための Scene。
//  アプリの `App.body` に `SpeakerNotesScene()` を追加し、`openWindow(id: SpeakerNotesScene.windowID)` で開く。
//  表示内容は SpeakerNotesSession.shared に登録された発表中デッキを購読する。
//
//  iPhone では通常マルチウィンドウ非対応(supportsMultipleWindows == false)のため、
//  呼び出し側(SlideBaseView)は supportsMultipleWindows を見てから openWindow すること。
//  iPhone Duo でも外側ディスプレイでは新規Windowを作れない(内側ディスプレイ限定)。
//

#if os(iOS)
import SlideKit
import SwiftUI

public struct SpeakerNotesScene: Scene {
    public static let windowID = "speakerNotes"

    public init() {}

    public var body: some Scene {
        WindowGroup("Speaker Notes", id: Self.windowID) {
            SpeakerNotesSceneRootView()
        }
    }
}

/// ノートWindowのルート。デッキ未登録時はプレースホルダーを出し、少し待っても
/// デッキが来なければ自分のSceneを閉じる(アプリ再起動でノートWindowだけが復元されたときや、
/// スライドを閉じたときにノートWindowが取り残されないようにする)。
struct SpeakerNotesSceneRootView: View {
    @ObservedObject private var session = SpeakerNotesSession.shared
    @State private var windowScene: UIWindowScene?

    private var hasPresentation: Bool { session.presentation != nil }

    var body: some View {
        Group {
            if let presentation = session.presentation {
                SpeakerNotesView(
                    slideIndexController: presentation.slideIndexController,
                    slideTheme: presentation.slideTheme
                )
            } else {
                ContentUnavailableView(
                    "スライドが開かれていません",
                    systemImage: "rectangle.on.rectangle.slash",
                    description: Text("スライドを開くと、ここにスピーカーノートが表示されます。")
                )
                .preferredColorScheme(.dark)
            }
        }
        .background(Color.black)
        .background(WindowSceneReader(windowScene: $windowScene))
        .task(id: hasPresentation) {
            guard !hasPresentation else { return }
            // openWindow 直後は attach が僅かに遅れることがあるので、少しだけ待ってから閉じる
            try? await Task.sleep(for: .seconds(1))
            guard !hasPresentation, let windowScene else { return }
            UIApplication.shared.requestSceneSessionDestruction(windowScene.session, options: nil)
        }
    }
}

/// 自分が属する UIWindowScene を取り出すための空View。
private struct WindowSceneReader: UIViewRepresentable {
    @Binding var windowScene: UIWindowScene?

    func makeUIView(context: Context) -> UIView { UIView(frame: .zero) }

    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            if let scene = uiView.window?.windowScene, scene !== windowScene {
                windowScene = scene
            }
        }
    }
}
#endif
