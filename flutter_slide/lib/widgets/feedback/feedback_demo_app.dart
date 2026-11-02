import 'package:flutter/material.dart';

import 'slide_language.dart';

import 'debug/debug_floating_button.dart';
import 'debug/debug_navigator_key.dart';
import 'debug/feedback/app_log_buffer.dart';
import 'debug/feedback/element_picker.dart';
import 'debug/feedback/screen_replay_recorder.dart';
import 'debug/feedback/screen_replay_screen.dart';
import 'debug/feedback/widget_tree_dumper.dart';
import 'feedback_demo_home.dart';
import 'log_slide_demo_page.dart';

/// スライドに埋め込む Flutter デモの種類。Swift 側 `FlutterKaigi2026ViewType` と 1:1。
enum FeedbackDemoMode {
  /// フローティングボタン → Debug Menu → Issue 起票までの一連の流れ
  feedbackDemo,

  /// 「要素を選ぶ」から選択モードに入り、タップした Widget を枠で囲んで identifier を表示する
  elementPicker,

  /// 画面リプレイ(静止画リングバッファ → デバイスで動画化)の操作画面へ直行
  screenReplay,

  /// Widget 階層をテキスト化して表示する
  widgetTree,

  /// 「最大の差分: ログは自分で溜める」のページを Flutter で描き、誤字をその場で起票する
  logSlide,
}

/// FlutterKaigi2026 デモ本体。
///
/// スライド側の各ページは flutter_slide の root MaterialApp の route として表示されるため、
/// ここでネストした [MaterialApp] を作り、参考実装(flutter_sample)と同じく
/// `builder` に DebugFloatingButton → ScreenReplayBoundary を仕込む。
/// (フローティングボタン自体は録画に含めない)
class FeedbackDemoApp extends StatefulWidget {
  const FeedbackDemoApp({super.key, required this.mode});

  final FeedbackDemoMode mode;

  @override
  State<FeedbackDemoApp> createState() => _FeedbackDemoAppState();
}

class _FeedbackDemoAppState extends State<FeedbackDemoApp> {
  @override
  void initState() {
    super.initState();
    // 参考実装では main() で debugPrint を差し替えているが、flutter_slide の main は
    // 触らず、デモ画面が立ち上がったタイミングでログの捕捉を始める。
    AppLogCapture.install();
    AppLogBuffer.instance.add('[demo] FeedbackDemoApp(${widget.mode.name}) 起動');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: debugRootNavigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      builder: (context, child) => DebugFloatingButton(
        enabled: widget.mode == FeedbackDemoMode.feedbackDemo,
        child: ScreenReplayBoundary(
          child: child ?? const SizedBox.shrink(),
        ),
      ),
      home: widget.mode == FeedbackDemoMode.logSlide
          ? const LogSlideDemoPage()
          : _DemoHomeForMode(mode: widget.mode),
    );
  }
}

/// デモ種別ごとに、ホーム画面の FAB(導線)を差し替える。
class _DemoHomeForMode extends StatefulWidget {
  const _DemoHomeForMode({required this.mode});

  final FeedbackDemoMode mode;

  @override
  State<_DemoHomeForMode> createState() => _DemoHomeForModeState();
}

class _DemoHomeForModeState extends State<_DemoHomeForMode> {
  String? _selectedIdentifier;

  @override
  Widget build(BuildContext context) {
    return FeedbackDemoHome(
      title: switch (widget.mode) {
        FeedbackDemoMode.feedbackDemo => tr('アプリ内バグ起票', 'In-app bug filing'),
        FeedbackDemoMode.elementPicker => tr('要素ピッカー', 'Element picker'),
        FeedbackDemoMode.screenReplay => tr('画面リプレイ', 'Screen replay'),
        FeedbackDemoMode.widgetTree => tr('Widget 階層', 'Widget tree'),
        FeedbackDemoMode.logSlide => tr('ログ', 'Logs'),
      },
      floatingActionButton: switch (widget.mode) {
        FeedbackDemoMode.feedbackDemo => null,
        FeedbackDemoMode.elementPicker => _pickerFab(context),
        FeedbackDemoMode.screenReplay => FloatingActionButton.extended(
            onPressed: () => ScreenReplayScreen.show(context),
            icon: const Icon(Icons.videocam),
            label: Text(tr('動画にする', 'Make a video')),
          ),
        FeedbackDemoMode.widgetTree => FloatingActionButton.extended(
            onPressed: () => WidgetTreeScreen.show(context),
            icon: const Icon(Icons.account_tree),
            label: Text(tr('階層を見る', 'Show the tree')),
          ),
        FeedbackDemoMode.logSlide => null,
      },
    );
  }

  Widget _pickerFab(BuildContext context) {
    final selected = _selectedIdentifier;
    return FloatingActionButton.extended(
      onPressed: () async {
        final overlay = Overlay.of(context, rootOverlay: true);
        final identifier = await ElementPicker.pick(
          overlay,
          // タップのたびに FAB のラベルにも反映する(選択中の要素が一目でわかるように)
          onSelectionChanged: (id) {
            if (mounted) setState(() => _selectedIdentifier = id);
          },
        );
        if (!mounted) return;
        setState(() => _selectedIdentifier = identifier);
        if (identifier != null) {
          debugPrint('[picker] 確定された要素: $identifier');
        }
      },
      icon: const Icon(Icons.center_focus_strong),
      label: Text(selected == null
          ? tr('要素を選ぶ', 'Pick element')
          : tr('選択中: $selected', 'Selected: $selected')),
    );
  }
}

/// アプリの Dart ログを [AppLogBuffer] に流し込むフックをまとめたもの。
///
/// 参考実装では `main()` の `runZonedGuarded` で仕込んでいる(Zone の print フックも含む)が、
/// スライドのデモではデモ画面の初期化時に後付けする。多重登録はしない。
class AppLogCapture {
  const AppLogCapture._();

  static bool _installed = false;

  static void install() {
    if (_installed) return;
    _installed = true;

    final originalDebugPrint = debugPrint;
    debugPrint = (String? message, {int? wrapWidth}) {
      if (message != null) AppLogBuffer.instance.add(message);
      originalDebugPrint(message, wrapWidth: wrapWidth);
    };

    final originalOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      AppLogBuffer.instance.add('FlutterError: ${details.exceptionAsString()}');
      if (originalOnError != null) {
        originalOnError(details);
      } else {
        FlutterError.presentError(details);
      }
    };
  }
}
