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
    static func register(messenger: FlutterBinaryMessenger) {
        let channel = FlutterMethodChannel(name: name, binaryMessenger: messenger)
        channel.setMethodCallHandler { call, result in
            switch call.method {
            case "encodeClip":
                handleEncodeClip(call, result)
            case "shareClip":
                handleShareClip(call, result)
            default:
                result(FlutterMethodNotImplemented)
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
        let outputURL = URL(fileURLWithPath: outputPath)
        // 既存ファイルがあると AVAssetWriter が失敗するので消しておく。
        try? FileManager.default.removeItem(at: outputURL)

        Task {
            do {
                try await SnapshotVideoEncoder.encode(snapshots: urls, fps: fps, to: outputURL)
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
    static func encode(snapshots: [URL], fps: Double, to outputURL: URL) async throws {
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

        try await Task.detached(priority: .userInitiated) {
            try Self.encodeFrames(
                snapshotPaths: snapshotPaths,
                width: width,
                height: height,
                frameIntervalSeconds: frameIntervalSeconds,
                input: inputBox.value,
                adaptor: adaptorBox.value
            )
        }.value

        await writer.finishWriting()
        if writer.status != .completed {
            throw SnapshotVideoEncoderError.writerFinishFailed(writer.error ?? SnapshotVideoEncoderError.noSnapshots)
        }
    }

    nonisolated private static func encodeFrames(
        snapshotPaths: [String],
        width: Int,
        height: Int,
        frameIntervalSeconds: Double,
        input: AVAssetWriterInput,
        adaptor: AVAssetWriterInputPixelBufferAdaptor
    ) throws {
        let frameInterval = CMTime(seconds: frameIntervalSeconds, preferredTimescale: 600)
        var pts = CMTime.zero

        for path in snapshotPaths {
            while input.isReadyForMoreMediaData == false {
                Thread.sleep(forTimeInterval: 0.005)
            }
            autoreleasepool {
                guard let image = UIImage(contentsOfFile: path),
                      let cgImage = image.cgImage else { return }
                guard let buffer = Self.createPixelBuffer(from: cgImage, width: width, height: height) else { return }
                adaptor.append(buffer, withPresentationTime: pts)
            }
            pts = CMTimeAdd(pts, frameInterval)
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
