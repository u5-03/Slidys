//
//  ScreenReplayChannel.swift
//  SlidysFlutter
//
//  FlutterKaigi2026 の「画面リプレイ」デモ用。Flutter 側(flutter_slide の ScreenReplayRecorder)が
//  リングバッファに溜めた PNG 連番を受け取り、AVAssetWriter で H.264 の mp4 にエンコードして返す。
//  Dart SDK には動画エンコーダが無いため、「静止画は Flutter、動画化はデバイス」という役割分担にしている。
//

import AVFoundation
import CoreVideo
import Flutter
import UIKit

/// `flutter_slide/screen_replay` チャネルのハンドラ。
enum ScreenReplayChannel {
    static let name = "flutter_slide/screen_replay"

    /// FlutterViewController ごと(= エンジンごと)に登録する。
    /// - Parameter captureView: `captureFrame` で撮る View(FlutterViewController の view)。
    ///   PlatformView(地図・WebView などネイティブの UIView)もこの配下にあるので一緒に写る。
    static func register(messenger: FlutterBinaryMessenger, captureView: UIView) {
        let channel = FlutterMethodChannel(name: name, binaryMessenger: messenger)
        weak var weakCaptureView = captureView
        channel.setMethodCallHandler { call, result in
            switch call.method {
            case "captureFrame":
                handleCaptureFrame(call, result, view: weakCaptureView)
            case "encodeClip":
                handleEncodeClip(call, result)
            case "shareClip":
                handleShareClip(call, result)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    /// 画面を 1 フレーム撮って PNG で保存する。
    /// Flutter の `toImage` は Flutter が描いたレイヤーしか撮れず PlatformView が黒くなるため、
    /// ネイティブ側で View 階層ごと(`drawHierarchy`)撮る。Flutter の描画も PlatformView も 1 枚に合成される。
    private static func handleCaptureFrame(
        _ call: FlutterMethodCall,
        _ result: @escaping FlutterResult,
        view: UIView?
    ) {
        guard let args = call.arguments as? [String: Any],
              let path = args["path"] as? String else {
            result(FlutterError(code: "bad_args", message: "引数が不正です", details: nil))
            return
        }
        guard let view, view.window != nil, view.bounds.width > 0, view.bounds.height > 0 else {
            result(FlutterError(code: "no_view", message: "撮影できる View がありません", details: nil))
            return
        }
        // 1.0 = 論理解像度(ポイント)。負荷とファイルサイズの主因なので小さめに
        let scale = (args["scale"] as? Double).map { CGFloat($0) } ?? 1.0
        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        format.opaque = true
        let image = UIGraphicsImageRenderer(bounds: view.bounds, format: format).image { _ in
            // afterScreenUpdates: false = いま画面に出ている内容をそのまま撮る(再描画を待たないので軽い)
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
        }
        // PNG エンコードと書き込みはメインスレッドを塞がないように別スレッドで
        DispatchQueue.global(qos: .utility).async {
            guard let data = image.pngData() else {
                DispatchQueue.main.async {
                    result(FlutterError(code: "encode_failed", message: "PNG に変換できませんでした", details: nil))
                }
                return
            }
            do {
                try data.write(to: URL(fileURLWithPath: path))
                DispatchQueue.main.async { result(true) }
            } catch {
                DispatchQueue.main.async {
                    result(FlutterError(code: "write_failed", message: error.localizedDescription, details: nil))
                }
            }
        }
    }

    private static func handleEncodeClip(
        _ call: FlutterMethodCall,
        _ result: @escaping FlutterResult
    ) {
        guard let args = call.arguments as? [String: Any],
              let frames = args["frames"] as? [String],
              let fps = args["fps"] as? Double,
              let outputPath = args["outputPath"] as? String else {
            result(FlutterError(code: "bad_args", message: "引数が不正です", details: nil))
            return
        }
        guard frames.isEmpty == false else {
            result(FlutterError(code: "no_frames", message: "フレームがありません", details: nil))
            return
        }

        let urls = frames.map { URL(fileURLWithPath: $0) }
        // 各フレームの表示時刻(ms)。あれば実際に撮った間隔で動画にする(無ければ fps で等間隔)
        let timestampsMs = (args["timestampsMs"] as? [NSNumber])?.map(\.doubleValue)
        let outputURL = URL(fileURLWithPath: outputPath)
        // 既存ファイルがあると AVAssetWriter が失敗するので消しておく。
        try? FileManager.default.removeItem(at: outputURL)

        Task {
            do {
                try await SnapshotVideoEncoder.encode(snapshots: urls, fps: fps, timestampsMs: timestampsMs, to: outputURL)
                await MainActor.run { result(outputURL.path) }
            } catch {
                await MainActor.run {
                    result(FlutterError(code: "encode_failed", message: error.localizedDescription, details: nil))
                }
            }
        }
    }

    /// 生成済み mp4 を OS の共有シート(UIActivityViewController)で共有する。
    private static func handleShareClip(
        _ call: FlutterMethodCall,
        _ result: @escaping FlutterResult
    ) {
        guard let args = call.arguments as? [String: Any],
              let path = args["path"] as? String else {
            result(FlutterError(code: "bad_args", message: "引数が不正です", details: nil))
            return
        }
        guard FileManager.default.fileExists(atPath: path) else {
            result(FlutterError(code: "not_found", message: "ファイルが見つかりません", details: nil))
            return
        }

        DispatchQueue.main.async {
            guard let presenter = topViewController() else {
                result(FlutterError(code: "no_vc", message: "表示元の画面が見つかりません", details: nil))
                return
            }
            let url = URL(fileURLWithPath: path)
            let activity = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            // iPad では popover の anchor が必須(無いと落ちる)。画面中央から出す。
            if let popover = activity.popoverPresentationController {
                popover.sourceView = presenter.view
                popover.sourceRect = CGRect(x: presenter.view.bounds.midX, y: presenter.view.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
            presenter.present(activity, animated: true) { result(nil) }
        }
    }

    /// 現在最前面に表示されている UIViewController を返す。
    private static func topViewController() -> UIViewController? {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first { $0.activationState == .foregroundActive } as? UIWindowScene
            ?? scenes.first as? UIWindowScene
        let keyWindow = windowScene?.windows.first { $0.isKeyWindow } ?? windowScene?.windows.first
        var top = keyWindow?.rootViewController
        while let presented = top?.presentedViewController {
            top = presented
        }
        return top
    }
}

// MARK: - SnapshotVideoEncoder

enum SnapshotVideoEncoderError: LocalizedError {
    case noSnapshots
    case firstImageDecodeFailed
    case writerSetupFailed(any Error)
    case writerStartFailed(any Error)
    case writerFinishFailed(any Error)

    var errorDescription: String? {
        switch self {
        case .noSnapshots: return "保存できる snapshot が 1 枚もありません"
        case .firstImageDecodeFailed: return "snapshot の解像度を取得できませんでした"
        case .writerSetupFailed: return "動画書き出しの初期化に失敗しました"
        case .writerStartFailed: return "動画書き出しの開始に失敗しました"
        case .writerFinishFailed: return "動画書き出しの完了に失敗しました"
        }
    }
}

/// AVFoundation の非 Sendable 型を Task 越えに渡すためのラッパ
private struct UnsafeSendableBox<T>: @unchecked Sendable {
    let value: T
}

/// snapshot 連番(PNG/JPEG いずれも UIImage で読める)を AVAssetWriter で H.264 mp4 にエンコードする。
enum SnapshotVideoEncoder {
    /// - Parameters:
    ///   - snapshots: 入力画像 URL のリスト(timestamp 昇順)
    ///   - fps: 出力 mp4 のフレームレート(capture rate と一致させる)
    ///   - outputURL: 出力 mp4 のパス
    static func encode(snapshots: [URL], fps: Double, timestampsMs: [Double]? = nil, to outputURL: URL) async throws {
        guard let firstURL = snapshots.first else {
            throw SnapshotVideoEncoderError.noSnapshots
        }
        guard let firstImage = UIImage(contentsOfFile: firstURL.path),
              let firstCgImage = firstImage.cgImage else {
            throw SnapshotVideoEncoderError.firstImageDecodeFailed
        }
        // H.264 はサイズが偶数でないと弾かれることがあるので 2 の倍数に丸める。
        let width = firstCgImage.width - (firstCgImage.width % 2)
        let height = firstCgImage.height - (firstCgImage.height % 2)

        let writer: AVAssetWriter
        do {
            writer = try AVAssetWriter(url: outputURL, fileType: .mp4)
        } catch {
            throw SnapshotVideoEncoderError.writerSetupFailed(error)
        }

        let input = AVAssetWriterInput(
            mediaType: .video,
            outputSettings: [
                AVVideoCodecKey: AVVideoCodecType.h264,
                AVVideoWidthKey: width,
                AVVideoHeightKey: height,
                AVVideoCompressionPropertiesKey: [
                    AVVideoAverageBitRateKey: 3_000_000,
                    AVVideoMaxKeyFrameIntervalKey: max(1, Int(fps * 2)),
                    AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel
                ]
            ]
        )
        input.expectsMediaDataInRealTime = false

        let adaptor = AVAssetWriterInputPixelBufferAdaptor(
            assetWriterInput: input,
            sourcePixelBufferAttributes: [
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
                kCVPixelBufferWidthKey as String: width,
                kCVPixelBufferHeightKey as String: height
            ]
        )
        writer.add(input)

        guard writer.startWriting() else {
            throw SnapshotVideoEncoderError.writerStartFailed(writer.error ?? SnapshotVideoEncoderError.noSnapshots)
        }
        writer.startSession(atSourceTime: .zero)

        let inputBox = UnsafeSendableBox(value: input)
        let adaptorBox = UnsafeSendableBox(value: adaptor)
        let snapshotPaths = snapshots.map { $0.path }
        let frameIntervalSeconds = 1.0 / fps
        // 表示時刻が枚数ぶんそろっているときだけ使う(撮影が fps より遅い端末でも、実時間どおりの長さになる)
        let frameTimesSeconds: [Double] = if let timestampsMs, timestampsMs.count == snapshots.count {
            timestampsMs.map { $0 / 1000 }
        } else {
            snapshots.indices.map { Double($0) * frameIntervalSeconds }
        }

        try await Task.detached(priority: .userInitiated) {
            try Self.encodeFrames(
                snapshotPaths: snapshotPaths,
                width: width,
                height: height,
                frameTimesSeconds: frameTimesSeconds,
                input: inputBox.value,
                adaptor: adaptorBox.value
            )
        }.value

        // 最後のフレームも 1 コマぶん表示されるよう、終端の時刻を明示する
        let endSeconds = (frameTimesSeconds.last ?? 0) + frameIntervalSeconds
        writer.endSession(atSourceTime: CMTime(seconds: endSeconds, preferredTimescale: 600))
        await writer.finishWriting()
        if writer.status != .completed {
            throw SnapshotVideoEncoderError.writerFinishFailed(writer.error ?? SnapshotVideoEncoderError.noSnapshots)
        }
    }

    nonisolated private static func encodeFrames(
        snapshotPaths: [String],
        width: Int,
        height: Int,
        frameTimesSeconds: [Double],
        input: AVAssetWriterInput,
        adaptor: AVAssetWriterInputPixelBufferAdaptor
    ) throws {
        for (index, path) in snapshotPaths.enumerated() {
            let pts = CMTime(seconds: frameTimesSeconds[index], preferredTimescale: 600)
            while input.isReadyForMoreMediaData == false {
                Thread.sleep(forTimeInterval: 0.005)
            }
            autoreleasepool {
                guard let image = UIImage(contentsOfFile: path),
                      let cgImage = image.cgImage else { return }
                guard let buffer = Self.createPixelBuffer(from: cgImage, width: width, height: height) else { return }
                adaptor.append(buffer, withPresentationTime: pts)
            }
        }
        input.markAsFinished()
    }

    nonisolated private static func createPixelBuffer(from cgImage: CGImage, width: Int, height: Int) -> CVPixelBuffer? {
        let attrs: [CFString: Any] = [
            kCVPixelBufferCGImageCompatibilityKey: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey: true
        ]
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32BGRA, attrs as CFDictionary, &pixelBuffer)
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else { return nil }

        CVPixelBufferLockBaseAddress(buffer, [])
        defer { CVPixelBufferUnlockBaseAddress(buffer, []) }

        guard let context = CGContext(
            data: CVPixelBufferGetBaseAddress(buffer),
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
        ) else { return nil }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        return buffer
    }
}
