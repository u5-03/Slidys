import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../debug/debug_navigator_key.dart';
import 'feedback/feedback_composer_screen.dart';
import 'feedback/log_viewer_screen.dart';
import 'feedback/screen_replay_screen.dart';
import 'feedback/widget_tree_dumper.dart';

/// Debug Menu の各項目。play-by-sports-app の `DebugMenuKind` パターンを踏襲。
enum DebugMenuKind {
  runtimeFeedback,
  screenReplay,
  widgetTree,
  logViewer,
  debugInfo;

  String get buttonName => switch (this) {
        DebugMenuKind.runtimeFeedback => 'アプリ内フィードバック (Issue 起票)',
        DebugMenuKind.screenReplay => '画面リプレイ (直近 60 秒を動画化)',
        DebugMenuKind.widgetTree => 'Widget 階層 (実行時にテキスト化)',
        DebugMenuKind.logViewer => '実行ログビューア (print/debugPrint)',
        DebugMenuKind.debugInfo => 'デバッグ情報',
      };

  IconData get icon => switch (this) {
        DebugMenuKind.runtimeFeedback => Icons.bug_report,
        DebugMenuKind.screenReplay => Icons.videocam,
        DebugMenuKind.widgetTree => Icons.account_tree,
        DebugMenuKind.logViewer => Icons.terminal,
        DebugMenuKind.debugInfo => Icons.info_outline,
      };

  String get subtitle => switch (this) {
        DebugMenuKind.runtimeFeedback =>
          'バグ / タスクを GitHub Issue として起票する',
        DebugMenuKind.screenReplay =>
          'バックグラウンドで直近 60 秒を録画し mp4 に書き出す',
        DebugMenuKind.widgetTree =>
          'Element ツリーを歩いてクラス名・サイズ・identifier を出力する',
        DebugMenuKind.logViewer =>
          'アプリ内で出力されたログを確認する',
        DebugMenuKind.debugInfo => 'デバイス・バージョン等の情報',
      };
}

/// Debug Menu 本体。iOS 版 DebugMenuWindow のフローティングボタンから開かれる。
class DebugMenuScreen extends StatelessWidget {
  const DebugMenuScreen({super.key});

  static bool _isShowing = false;

  /// モーダルとして Debug Menu を表示する (多重表示ガード付き)。
  ///
  /// フローティングボタン (Navigator より上位の context) から呼ばれても確実に
  /// 遷移できるよう、ルート Navigator の key 経由で push する。
  static Future<void> show() async {
    if (_isShowing) return;
    final navigator = debugRootNavigatorKey.currentState;
    if (navigator == null) return;
    _isShowing = true;
    await navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => const DebugMenuScreen(),
        fullscreenDialog: true,
      ),
    );
    _isShowing = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Menu'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        children: [
          for (final kind in DebugMenuKind.values)
            ListTile(
              leading: Icon(kind.icon),
              title: Text(kind.buttonName),
              subtitle: Text(kind.subtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _runAction(context, kind),
            ),
        ],
      ),
    );
  }

  Future<void> _runAction(BuildContext context, DebugMenuKind kind) async {
    switch (kind) {
      case DebugMenuKind.runtimeFeedback:
        await FeedbackComposerScreen.show(context);
      case DebugMenuKind.screenReplay:
        await ScreenReplayScreen.show(context);
      case DebugMenuKind.widgetTree:
        await WidgetTreeScreen.show(context);
      case DebugMenuKind.logViewer:
        await LogViewerScreen.show(context);
      case DebugMenuKind.debugInfo:
        await _showDebugInfo(context);
    }
  }

  Future<void> _showDebugInfo(BuildContext context) {
    final platform = kIsWeb ? 'Web' : defaultTargetPlatform.name;
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('デバッグ情報'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Platform: $platform'),
            Text('Debug build: $kDebugMode'),
            const Text('App version: 1.0.0 (1)'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
