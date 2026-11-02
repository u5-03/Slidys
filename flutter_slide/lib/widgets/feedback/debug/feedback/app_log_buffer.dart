import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

/// 実行時ログの 1 行。
class AppLogEntry {
  AppLogEntry(this.timestamp, this.message);

  final DateTime timestamp;
  final String message;
}

/// アプリ内のログ用リングバッファ。
///
/// iOS の `OSLogStore` に相当する OS API が Flutter には無いため、
/// `main()` で `Zone` の `print` フック + `debugPrint` の差し替え + エラーハンドラを仕込み、
/// アプリの Dart コードが出力したログをこのバッファに溜める。直近 [maxEntries] 行だけ保持する。
///
/// 溜めたログは DebugMenu の「実行ログビューア」で確認でき、将来的には
/// バグ報告 (Issue) にテキストとして添付する用途にも使える。
class AppLogBuffer {
  AppLogBuffer._();

  static final AppLogBuffer instance = AppLogBuffer._();

  /// 保持する最大行数
  static const int maxEntries = 1000;

  final List<AppLogEntry> _entries = <AppLogEntry>[];

  /// 変更通知用。UI 側は revision を購読して再描画する。
  final ValueNotifier<int> revision = ValueNotifier<int>(0);

  List<AppLogEntry> get entries => List.unmodifiable(_entries);

  int get length => _entries.length;

  /// ログを 1 件追加する。改行を含む複数行メッセージもそのまま 1 エントリとして保持。
  void add(String message) {
    _entries.add(AppLogEntry(DateTime.now(), message));
    if (_entries.length > maxEntries) {
      _entries.removeRange(0, _entries.length - maxEntries);
    }
    _notify();
  }

  void clear() {
    _entries.clear();
    _notify();
  }

  /// バッファ全体をテキスト化 (ファイル書き出し / クリップボード / Issue 添付用)。
  String dumpText() {
    return _entries
        .map((e) => '${formatTimePublic(e.timestamp)}  ${e.message}')
        .join('\n');
  }

  /// `HH:mm:ss.SSS` 形式の時刻文字列。ビューアからも使う。
  static String formatTimePublic(DateTime t) {
    String two(int v) => v.toString().padLeft(2, '0');
    String three(int v) => v.toString().padLeft(3, '0');
    return '${two(t.hour)}:${two(t.minute)}:${two(t.second)}.${three(t.millisecond)}';
  }

  /// build / layout / paint の最中に通知すると「setState during build」で落ちるため、
  /// その場合はフレーム後に遅延させて安全に通知する。
  void _notify() {
    final SchedulerPhase phase;
    try {
      phase = SchedulerBinding.instance.schedulerPhase;
    } catch (_) {
      // runApp 前 (バインディング未初期化) の起動ログ等。リスナは未登録なので直接通知で安全。
      revision.value++;
      return;
    }
    if (phase == SchedulerPhase.idle ||
        phase == SchedulerPhase.postFrameCallbacks) {
      revision.value++;
    } else {
      SchedulerBinding.instance.addPostFrameCallback((_) => revision.value++);
    }
  }
}
