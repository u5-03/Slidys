//
//  DualDisplayCaptureKeeper.swift
//  SlidesCore
//
//  iPhone Duo で内側・外側の両ディスプレイに同時に表示するための補助。
//  iPhone Duo は AVCaptureSession の実行中だけ両方のディスプレイを点けるため、
//  映像は使わないダミーのカメラセッション(前面カメラ・フレームは即破棄)を裏で動かし続ける。
//
//  外側ディスプレイに出す内容は iOS 27.1 の CameraCaptureAccessory(SwiftUI の sceneAccessory)で登録する
//  (SlideBaseView の CameraCaptureDeckAccessory)。登録が無いと外側には OS の「<アプリ名>でカメラを表示」が出るだけ。
//  外部ディスプレイ(HDMI / AirPlay)の Scene とは別物で、role は windowCameraCaptureAccessory になる。
//  実機でどの Scene / Screen が来たかは、Logger(subsystem: "Slidys", category: "DualDisplay")に出す。
//

#if os(iOS)
@preconcurrency import AVFoundation
import OSLog
import SwiftUI
import UIKit

private let dualDisplayLog = Logger(subsystem: "Slidys", category: "DualDisplay")

/// 検証用ログの共通 prefix。Xcode のコンソールで「[DuoDual]」と入れて絞り込む
let dualDisplayLogPrefix = "[DuoDual]"

/// iPhone Duo 2画面表示の検証用ログ。Xcode のコンソールと Console.app(subsystem: Slidys / category: DualDisplay)の両方に出る
func dualDisplayDebugLog(_ message: String, isError: Bool = false) {
    if isError {
        dualDisplayLog.error("\(dualDisplayLogPrefix, privacy: .public) \(message, privacy: .public)")
    } else {
        dualDisplayLog.info("\(dualDisplayLogPrefix, privacy: .public) \(message, privacy: .public)")
    }
}

@MainActor
public final class DualDisplayCaptureKeeper: ObservableObject {
    public static let shared = DualDisplayCaptureKeeper()

    /// ダミーのカメラセッションを動かしているか
    @Published public private(set) var isRunning = false
    /// 権限なし・カメラなしなどで開始できなかったときの理由
    @Published public private(set) var lastError: String?
    /// 外側ディスプレイ(縦長)のスライドを横向きにするための回転方向。
    /// 端末の持ち方で上下が逆になるので、発表者メニューから反転できる
    @Published public var rotatesOuterClockwise = true

    /// アプリが許可する画面の向き(SlidysAppDelegate が返す)。
    /// 2画面表示中は内側ディスプレイを縦持ち前提にするため縦に固定する
    public private(set) var supportedInterfaceOrientations: UIInterfaceOrientationMask = .all

    private let session = AVCaptureSession()
    /// AVCaptureSession の startRunning / stopRunning はブロックするので専用キューで呼ぶ
    private let sessionQueue = DispatchQueue(label: "Slidys.DualDisplayCaptureKeeper")
    private let sampleBufferDelegate = DiscardingSampleBufferDelegate()
    private var isConfigured = false
    private var observers: [NSObjectProtocol] = []

    private init() {}

    public func toggle() {
        dualDisplayDebugLog("toggle isRunning=\(isRunning) iOS=\(UIDevice.current.systemVersion) model=\(UIDevice.current.model)")
        if isRunning { stop() } else { start() }
    }

    public func start() {
        guard !isRunning else { return }
        lastError = nil
        Task {
            let granted = await requestCameraAccess()
            dualDisplayDebugLog("camera access granted=\(granted) status=\(AVCaptureDevice.authorizationStatus(for: .video).rawValue)")
            guard granted else {
                lastError = "カメラへのアクセスが許可されていません"
                return
            }
            guard configureIfNeeded() else {
                dualDisplayDebugLog("configure failed: \(lastError ?? "-")", isError: true)
                return
            }
            observeSessionAndScenes()
            let session = session
            sessionQueue.async {
                session.startRunning()
                dualDisplayDebugLog("startRunning finished session.isRunning=\(session.isRunning)")
            }
            isRunning = true
            lockInnerDisplayOrientation(.portrait)
            dualDisplayDebugLog("capture session start requested")
            logScenes(reason: "start")
        }
    }

    public func stop() {
        guard isRunning else { return }
        let session = session
        sessionQueue.async {
            session.stopRunning()
            dualDisplayDebugLog("stopRunning finished session.isRunning=\(session.isRunning)")
        }
        isRunning = false
        lockInnerDisplayOrientation(.all)
        observers.forEach(NotificationCenter.default.removeObserver)
        observers.removeAll()
        dualDisplayDebugLog("capture session stop requested")
    }

    /// 内側ディスプレイ(アプリ本体の Scene)の向きを固定 / 解除する
    private func lockInnerDisplayOrientation(_ mask: UIInterfaceOrientationMask) {
        supportedInterfaceOrientations = mask
        let scenes = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter { $0.session.role == .windowApplication }
        for scene in scenes {
            scene.keyWindow?.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
            scene.requestGeometryUpdate(.iOS(interfaceOrientations: mask)) { error in
                dualDisplayDebugLog("requestGeometryUpdate failed: \(error.localizedDescription)", isError: true)
            }
        }
        dualDisplayDebugLog("inner orientation lock -> \(mask == .portrait ? "portrait" : "all")")
    }

    private func requestCameraAccess() async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            return true
        case .notDetermined:
            return await AVCaptureDevice.requestAccess(for: .video)
        default:
            return false
        }
    }

    /// 前面カメラ入力 + フレームを捨てるだけの出力。解像度は最低限にして負荷を抑える
    private func configureIfNeeded() -> Bool {
        guard !isConfigured else { return true }
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
                ?? AVCaptureDevice.default(for: .video) else {
            lastError = "カメラが見つかりません"
            return false
        }
        do {
            let input = try AVCaptureDeviceInput(device: device)
            let output = AVCaptureVideoDataOutput()
            output.alwaysDiscardsLateVideoFrames = true
            output.setSampleBufferDelegate(sampleBufferDelegate, queue: sessionQueue)

            session.beginConfiguration()
            defer { session.commitConfiguration() }
            if session.canSetSessionPreset(.low) {
                session.sessionPreset = .low
            }
            guard session.canAddInput(input), session.canAddOutput(output) else {
                lastError = "カメラセッションを構成できません"
                return false
            }
            session.addInput(input)
            session.addOutput(output)
            dualDisplayDebugLog("configured device=\(device.localizedName) position=\(device.position.rawValue) preset=\(session.sessionPreset.rawValue)")
            isConfigured = true
            return true
        } catch {
            lastError = "カメラ入力を作成できません: \(error.localizedDescription)"
            return false
        }
    }

    /// 実機検証用: セッションの中断や Scene / Screen の接続をログに出す。
    /// 他アプリにカメラを取られたなどで中断したら isRunning に反映する
    private func observeSessionAndScenes() {
        guard observers.isEmpty else { return }
        let center = NotificationCenter.default
        observers.append(center.addObserver(forName: AVCaptureSession.wasInterruptedNotification, object: session, queue: .main) { notification in
            let reason = (notification.userInfo?[AVCaptureSessionInterruptionReasonKey] as? Int) ?? -1
            dualDisplayDebugLog("capture session interrupted reason=\(reason)", isError: true)
        })
        observers.append(center.addObserver(forName: AVCaptureSession.interruptionEndedNotification, object: session, queue: .main) { _ in
            dualDisplayDebugLog("capture session interruption ended")
        })
        observers.append(center.addObserver(forName: AVCaptureSession.runtimeErrorNotification, object: session, queue: .main) { notification in
            let error = notification.userInfo?[AVCaptureSessionErrorKey] as? Error
            dualDisplayDebugLog("capture session runtime error \(error?.localizedDescription ?? "-")", isError: true)
        })
        for name in [UIScene.willConnectNotification, UIScene.didDisconnectNotification] {
            observers.append(center.addObserver(forName: name, object: nil, queue: .main) { [weak self] notification in
                let reason = notification.name.rawValue
                MainActor.assumeIsolated { self?.logScenes(reason: reason) }
            })
        }
    }

    private func logScenes(reason: String) {
        for scene in UIApplication.shared.connectedScenes {
            let windowScene = scene as? UIWindowScene
            dualDisplayDebugLog("[\(reason)] scene role=\(scene.session.role.rawValue) state=\(scene.activationState.rawValue) screen=\(windowScene?.screen.bounds.debugDescription ?? "-")")
        }
    }
}

/// 映像は使わないので、届いたフレームは何もせず捨てる
private final class DiscardingSampleBufferDelegate: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, @unchecked Sendable {}
#endif
