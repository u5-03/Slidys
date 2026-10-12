import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'debug/feedback/feedback_composer_screen.dart';
import 'debug/feedback/feedback_draft.dart';
import 'debug/feedback/feedback_session.dart';
import 'slide_language.dart';

/// FlutterKaigi2026 の「最大の差分: ログは自分で溜める」ページを丸ごと Flutter で描いたもの。
///
/// 2 項目目にわざと `mein()` という誤字を入れてあり、左下の Debug ボタンから起票画面を開いて
/// その場で起票するデモに使う。見た目は Swift 側の HeaderSlide(1920x1080 基準)と揃え、
/// FittedBox で実際の表示サイズに合わせて拡縮する。
///
/// 要素ピッカーで選べるよう、見出しと各項目(行単位)に `Semantics(identifier:)` を付けている。
/// 誤字の `mein()` をタップすると、その行(`logSlide.item2`)が選ばれる。
class LogSlideDemoPage extends StatelessWidget {
  const LogSlideDemoPage({super.key});

  // Swift 側 Theme.swift と同じ色
  static const background = Color(0xFF383944);
  static const foreground = Color(0xFFDDDDDD);
  static const themeBlue = Color(0xFF2388F4);
  static const strokeOrange = Color(0xFFF48F23);

  // Swift 側 ListTextStyle.flutterKaigi2026 と同じ寸法
  static const headerFontSize = 84.0;
  static const contentFontSize = 68.0;
  static const contentSpacing = 64.0;

  static const slideSize = Size(1920, 1080);

  /// ホストアプリ(Swift)にページ送りを頼むチャネル。
  /// このページは全面が Flutter なので、スライドの「左上/右上をタップして送る」を Flutter 側で受けて転送する
  static const _navigationChannel =
      MethodChannel('flutter_slide/slide_navigation');

  /// 左上/右上を中心とする半径 = 高さの半分の円の中をタップしたら、前/次のページへ(Swift 側と同じ判定)
  static void _handleTap(TapUpDetails details, Size size) {
    final p = details.localPosition;
    final radius = size.height / 2;
    if ((p - Offset.zero).distance <= radius) {
      _navigationChannel.invokeMethod<void>('back');
    } else if ((p - Offset(size.width, 0)).distance <= radius) {
      _navigationChannel.invokeMethod<void>('forward');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) => GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: (details) => _handleTap(details, constraints.biggest),
                child: FittedBox(
                  fit: BoxFit.contain,
                  alignment: Alignment.topLeft,
                  child: SizedBox.fromSize(
                    size: slideSize,
                    child: const Stack(
                      children: [
                        Positioned.fill(child: _SlideContent()),
                        Positioned(
                          right: 60,
                          bottom: 60,
                          child: _RecordingMotion(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 24,
            bottom: 24,
            child: SafeArea(
              child: Semantics(
                identifier: 'logSlide.debugButton',
                child: FilledButton.icon(
                  onPressed: () => _openComposer(context),
                  icon: const Icon(Icons.bug_report),
                  label: const Text('Debug'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 起票画面を開く。発表中に全文を打つ時間はないので、未入力なら内容をあらかじめ入れておく。
  static Future<void> _openComposer(BuildContext context) {
    final draft = FeedbackSession.instance.draft;
    if (draft.title.isEmpty) {
      draft
        ..issueKind = IssueKind.bug
        ..title = tr('ログのスライドで main() が mein() になっている',
            'The log slide says mein() instead of main()')
        ..bugPriority = BugPriority.minor
        ..bugDetails = tr(
            '「最大の差分: ログは自分で溜める」の 2 項目目で、エントリポイント名が main() ではなく mein() と表示されている',
            'In item 2 of "Biggest difference: collect logs yourself", the entry point is shown as mein() instead of main()')
        ..bugReproSteps = tr(
            '1. FlutterKaigi2026 のデッキを開く\n'
                '2. 「最大の差分: ログは自分で溜める」のページまで進む\n'
                '3. 2 項目目を見る',
            '1. Open the FlutterKaigi2026 deck\n'
                '2. Go to the "Biggest difference: collect logs yourself" page\n'
                '3. Look at item 2')
        ..bugExpectation = tr('main() と表示される', 'It should say main()');
    }
    debugPrint('[logSlide] 起票画面を開く');
    // 会場から読めるよう文字を大きく。デモなので動画は直近 10 秒だけ書き出す
    return FeedbackComposerScreen.show(
      context,
      textScale: 1.6,
      recentClipDuration: const Duration(seconds: 10),
    );
  }
}

/// 録画プレビューで時間の経過がわかるよう、本文の下で図形を動かす。
class _RecordingMotion extends StatefulWidget {
  const _RecordingMotion();

  @override
  State<_RecordingMotion> createState() => _RecordingMotionState();
}

class _RecordingMotionState extends State<_RecordingMotion>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ExcludeSemantics(
        child: SizedBox(
          width: 380,
          height: 180,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final angle = _controller.value * 2 * math.pi;
              return Stack(
                children: [
                  Positioned(
                    left: 150 + 130 * math.cos(angle),
                    top: 50 + 40 * math.sin(angle),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: LogSlideDemoPage.themeBlue,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 160 - 130 * math.cos(angle),
                    top: 60 - 40 * math.sin(angle),
                    child: Transform.rotate(
                      angle: angle,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: LogSlideDemoPage.strokeOrange,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SlideContent extends StatelessWidget {
  const _SlideContent();

  @override
  Widget build(BuildContext context) {
    const itemStyle = TextStyle(
      fontSize: LogSlideDemoPage.contentFontSize,
      fontWeight: FontWeight.w600,
      color: LogSlideDemoPage.foreground,
      height: 1.25,
    );
    const keyword = TextStyle(color: LogSlideDemoPage.strokeOrange);

    return Padding(
      padding: const EdgeInsets.all(60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 120,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Semantics(
                identifier: 'logSlide.title',
                child: Text(
                  tr('最大の差分: ログは自分で溜める',
                      'Biggest difference: collect logs yourself'),
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: LogSlideDemoPage.headerFontSize,
                    fontWeight: FontWeight.bold,
                    color: LogSlideDemoPage.themeBlue,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          _item(
            id: 'logSlide.item1',
            number: 1,
            style: itemStyle,
            spans: SlideLanguage.isEnglish
                ? const [
                    TextSpan(text: 'Flutter has '),
                    TextSpan(
                        text: "no API like iOS's OSLogStore", style: keyword),
                  ]
                : const [
                    TextSpan(text: 'Flutter には iOS の '),
                    TextSpan(text: 'OSLogStore 相当の API がない', style: keyword),
                  ],
          ),
          const SizedBox(height: LogSlideDemoPage.contentSpacing),
          _item(
            id: 'logSlide.item2',
            number: 2,
            style: itemStyle,
            // 誤字を含む行ごと選ばれる(行全体が 1 つの Widget = logSlide.item2)
            spans: SlideLanguage.isEnglish
                ? const [
                    TextSpan(text: 'In mein(),', style: keyword),
                    TextSpan(
                        text:
                            ' hook debugPrint / print / onError and feed them in'),
                  ]
                : const [
                    TextSpan(text: 'mein() で', style: keyword),
                    TextSpan(text: ' debugPrint / print / onError をフックして流し込む'),
                  ],
          ),
          const SizedBox(height: LogSlideDemoPage.contentSpacing),
          _item(
            id: 'logSlide.item3',
            number: 3,
            style: itemStyle,
            spans: SlideLanguage.isEnglish
                ? const [
                    TextSpan(text: 'From launch,', style: keyword),
                    TextSpan(
                        text:
                            ' keep the latest 1000 lines in an in-app ring buffer and attach on filing'),
                  ]
                : const [
                    TextSpan(text: '起動時から', style: keyword),
                    TextSpan(text: 'アプリ内リングバッファに直近 1000 行を保持し、起票時に添付'),
                  ],
          ),
        ],
      ),
    );
  }

  Widget _item({
    required String id,
    required int number,
    required TextStyle style,
    required List<InlineSpan> spans,
  }) {
    return Semantics(
      identifier: id,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text('$number. ', style: style),
          Expanded(child: Text.rich(TextSpan(style: style, children: spans))),
        ],
      ),
    );
  }
}
