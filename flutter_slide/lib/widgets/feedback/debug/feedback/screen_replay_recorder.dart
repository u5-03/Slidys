import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// 画面リプレイ (直近 N 秒のリングバッファ録画) の Dart 側 recorder。
///
/// iOS 版 `SnapshotRingBufferRecorder.swift` の移植。ただし **キャプチャ手段が違う**:
/// iOS は UIKit の `drawHierarchy` で scene を撮っていたが、Flutter のUIはメタルで
/// 描画されるためネイティブ screenshot では黒くなる。そこで Flutter 側で
/// `RepaintBoundary` + `RenderRepaintBoundary.toImageSync()` によりシーンを撮る。
///
/// 溜めた PNG 連番は、書き出し時に iOS ネイティブの `SnapshotVideoEncoder`
/// (AVAssetWriter / H.264) を MethodChannel 経由で叩いて mp4 化する。
enum ReplayState { idle, buffering, unavailable }

/// 書き出し結果
class ExportedClip {
  ExportedClip({
    required this.path,
    required this.frameCount,
    required this.duration,
  });

  /// 出力された mp4 のパス
  final String path;

  /// エンコードしたフレーム数
  final int frameCount;

  /// 実際に書き出された長さ (秒)
  final double duration;
}

class ScreenReplayRecorder {
  ScreenReplayRecorder._();

  static final ScreenReplayRecorder instance = ScreenReplayRecorder._();

  /// ネイティブ (iOS) のエンコーダを叩く MethodChannel。
  static const MethodChannel _channel =
      MethodChannel('flutter_slide/screen_replay');

  /// アプリ本体を包む [RepaintBoundary] の key。`ScreenReplayBoundary` から使う。
  final GlobalKey boundaryKey =
      GlobalKey(debugLabel: 'screen_replay_boundary');

  // ---- 設定 (buffering 中は変更しない想定) ----

  /// キャプチャ fps (iOS 版デフォルトと揃えて 8fps)
  double frameRate = 8.0;

  /// 出力解像度の倍率。1.0 = 論理解像度 (3x 端末なら実ピクセルの 1/9)。負荷とサイズの主因。
  double capturePixelRatio = 1.0;

  /// リングバッファ保持秒数
  Duration retain = const Duration(seconds: 60);

  // ---- 状態 ----

  final ValueNotifier<ReplayState> state = ValueNotifier(ReplayState.idle);

  /// 現在バッファに溜まっているフレーム数 (UI 表示用)
  final ValueNotifier<int> bufferedFrames = ValueNotifier(0);

  Timer? _timer;
  Directory? _bufferDir;
  bool _capturing = false;

  Directory get _dir {
    final dir = _bufferDir;
    if (dir != null) return dir;
    final created = Directory('${Directory.systemTemp.path}/screen_replay_buffer');
    created.createSync(recursive: true);
    _bufferDir = created;
    return created;
  }

  // ---- 公開 API ----

  /// バッファリング開始。既に buffering なら何もしない。
  void startBuffering() {
    if (state.value == ReplayState.buffering) return;
    _cleanupAll();
    final interval = Duration(milliseconds: (1000 / frameRate).round());
    _timer = Timer.periodic(interval, (_) => _captureFrame());
    state.value = ReplayState.buffering;
  }

  /// バッファリング停止。
  void stopBuffering() {
    _timer?.cancel();
    _timer = null;
    state.value = ReplayState.idle;
  }

  /// 直近 [duration] (省略時は [retain]) 秒分のフレームを mp4 にして返す。
  ///
  /// ネイティブ未実装のプラットフォーム (Android など) では [MissingPluginException]
  /// が飛ぶので、呼び出し側でハンドリングする。
  Future<ExportedClip> exportClip({Duration? duration}) async {
    final window = duration ?? retain;
    final cutoff = DateTime.now().millisecondsSinceEpoch - window.inMilliseconds;
    final frames = _framesSince(cutoff);
    if (frames.isEmpty) {
      throw StateError('バッファに書き出せるフレームがありません');
    }

    final outputPath =
        '${Directory.systemTemp.path}/clip-${DateTime.now().millisecondsSinceEpoch}.mp4';

    final result = await _channel.invokeMethod<String>('encodeClip', {
      'frames': frames.map((f) => f.file.path).toList(),
      'fps': frameRate,
      'outputPath': outputPath,
    });
    if (result == null) {
      throw StateError('エンコードに失敗しました (戻り値が null)');
    }

    final first = frames.first.ts;
    final last = frames.last.ts;
    final actual = ((last - first) / 1000).clamp(1.0 / frameRate, double.infinity);
    return ExportedClip(
      path: result,
      frameCount: frames.length,
      duration: actual.toDouble(),
    );
  }

  /// 指定した mp4 を OS の共有シート (iOS: UIActivityViewController) で共有する。
  ///
  /// ネイティブ未実装のプラットフォームでは [MissingPluginException] が飛ぶ。
  Future<void> shareClip(String path) async {
    await _channel.invokeMethod<void>('shareClip', {'path': path});
  }

  // ---- 内部処理 ----

  Future<void> _captureFrame() async {
    // 前フレームの toByteData がまだ終わっていなければスキップ (取りこぼしより安定優先)。
    if (_capturing) return;
    final context = boundaryKey.currentContext;
    if (context == null) return;
    final renderObject = context.findRenderObject();
    if (renderObject is! RenderRepaintBoundary) return;

    _capturing = true;
    try {
      // まだ paint されていない (初回フレーム等) と toImageSync が投げるが、
      // その場合は下の catch で握って次の tick に回す。
      // ※ debugNeedsPaint は assert 内で値を設定する debug 専用 API で、
      //   Release/Profile では LateInitializationError になるため使わない。
      final image = renderObject.toImageSync(pixelRatio: capturePixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      if (byteData == null) return;

      final ts = DateTime.now().millisecondsSinceEpoch;
      final file = File('${_dir.path}/$ts.png');
      await file.writeAsBytes(byteData.buffer.asUint8List(), flush: false);

      _evict();
      bufferedFrames.value = _framesSince(0).length;
    } catch (error, stack) {
      debugPrint('[ScreenReplay] capture 失敗: $error\n$stack');
    } finally {
      _capturing = false;
    }
  }

  /// [cutoffMs] (epoch ms) 以降のフレームを timestamp 昇順で返す。
  List<_Frame> _framesSince(int cutoffMs) {
    final List<FileSystemEntity> entries;
    try {
      entries = _dir.listSync();
    } catch (_) {
      return const [];
    }
    final frames = <_Frame>[];
    for (final entry in entries) {
      if (entry is! File) continue;
      final name = entry.uri.pathSegments.last;
      final stem = name.split('.').first;
      final ts = int.tryParse(stem);
      if (ts == null) continue;
      if (ts >= cutoffMs) frames.add(_Frame(entry, ts));
    }
    frames.sort((a, b) => a.ts.compareTo(b.ts));
    return frames;
  }

  /// 保持秒数より古いフレームを削除する。
  void _evict() {
    final cutoff =
        DateTime.now().millisecondsSinceEpoch - retain.inMilliseconds - 1000;
    final List<FileSystemEntity> entries;
    try {
      entries = _dir.listSync();
    } catch (_) {
      return;
    }
    for (final entry in entries) {
      if (entry is! File) continue;
      final stem = entry.uri.pathSegments.last.split('.').first;
      final ts = int.tryParse(stem);
      if (ts != null && ts < cutoff) {
        try {
          entry.deleteSync();
        } catch (_) {
          // best-effort
        }
      }
    }
  }

  void _cleanupAll() {
    try {
      for (final entry in _dir.listSync()) {
        try {
          entry.deleteSync(recursive: true);
        } catch (_) {}
      }
    } catch (_) {}
    bufferedFrames.value = 0;
  }
}

class _Frame {
  _Frame(this.file, this.ts);

  final File file;
  final int ts;
}

/// アプリ本体を [RepaintBoundary] で包み、デバッグ時に自動でバッファリングを開始する。
///
/// `MaterialApp.builder` の中で `DebugFloatingButton` の内側に置くことで、
/// フローティングボタン自体はキャプチャに含めない (iOS 版が windowLevel >= .alert を
/// 除外していたのと同じ意図)。
class ScreenReplayBoundary extends StatefulWidget {
  const ScreenReplayBoundary({
    super.key,
    required this.child,
    this.enabled = true,
  });

  final Widget child;
  final bool enabled;

  @override
  State<ScreenReplayBoundary> createState() => _ScreenReplayBoundaryState();
}

class _ScreenReplayBoundaryState extends State<ScreenReplayBoundary> {
  @override
  void initState() {
    super.initState();
    if (widget.enabled) {
      // 最初のフレーム描画後にバッファリングを開始する。
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScreenReplayRecorder.instance.startBuffering();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;
    return RepaintBoundary(
      key: ScreenReplayRecorder.instance.boundaryKey,
      child: widget.child,
    );
  }
}
