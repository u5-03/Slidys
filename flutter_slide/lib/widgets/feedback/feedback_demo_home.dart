import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

/// FlutterKaigi2026 デモ用のホーム画面。
///
/// 各カード・ボタンに `Semantics(identifier:)` を付けているので、ElementPicker の
/// Bounding Box 選択デモではそのまま選択候補として枠が出る。常時動くアニメーションと
/// ストップウォッチは、画面リプレイのデモで「時間の経過と画面の動き」が動画に写るようにするため。
class FeedbackDemoHome extends StatefulWidget {
  const FeedbackDemoHome({
    super.key,
    this.title = 'Flutter Demo',
    this.floatingActionButton,
  });

  final String title;

  /// デモの種類ごとに差し替えるアクション(要素を選ぶ / 動画にする など)。
  final Widget? floatingActionButton;

  @override
  State<FeedbackDemoHome> createState() => _FeedbackDemoHomeState();
}

class _FeedbackDemoHomeState extends State<FeedbackDemoHome>
    with SingleTickerProviderStateMixin {
  int _counter = 0;
  int _selectedTabIndex = 0;

  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat();
  Timer? _stopwatch;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _stopwatch = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!mounted) return;
      setState(() => _elapsed += const Duration(milliseconds: 100));
    });
  }

  @override
  void dispose() {
    _anim.dispose();
    _stopwatch?.cancel();
    super.dispose();
  }

  void _incrementCounter() {
    setState(() => _counter++);
    // ここで出力したログが AppLogBuffer に捕捉され、Debug Menu の実行ログビューアで確認できる。
    debugPrint('[counter] カウントボタンがタップされました → count=$_counter');
    if (_counter % 5 == 0) {
      // ignore: avoid_print  ← print も捕捉できることを示すデモ
      print('[counter] 5 の倍数に到達: count=$_counter');
    }
  }

  void _onTabTapped(int index) {
    setState(() => _selectedTabIndex = index);
    debugPrint('[tab] タブ切り替え → index=$index');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      backgroundColor: Colors.teal.shade50,
      floatingActionButton: widget.floatingActionButton,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _stopwatchCard(),
          _counterCard(),
          _spinnerCard(),
          _ballCard(),
          _progressCard(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: SizedBox(
          height: 72,
          child: Material(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Row(
              children: [
                _tabButton(0, Icons.home, 'ホーム', 'home.tab.home'),
                _tabButton(1, Icons.search, '検索', 'home.tab.search'),
                _tabButton(2, Icons.qr_code, 'コード', 'home.tab.qrCode'),
                _tabButton(3, Icons.notifications, '通知', 'home.tab.notifications'),
                _tabButton(4, Icons.settings, '設定', 'home.tab.settings'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _demoCard({
    required String id,
    required String title,
    required Widget child,
  }) {
    return Semantics(
      identifier: id,
      child: Card(
        margin: const EdgeInsets.only(bottom: 14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 12),
              child,
            ],
          ),
        ),
      ),
    );
  }

  Widget _stopwatchCard() {
    final seconds = _elapsed.inMilliseconds / 1000.0;
    return _demoCard(
      id: 'home.stopwatch',
      title: '⏱ 経過時間',
      child: Text(
        '${seconds.toStringAsFixed(1)} 秒',
        style: Theme.of(context)
            .textTheme
            .displaySmall
            ?.copyWith(fontWeight: FontWeight.bold, color: Colors.teal.shade700),
      ),
    );
  }

  Widget _counterCard() {
    return _demoCard(
      id: 'home.counter',
      title: '＋ カウンター',
      child: Row(
        children: [
          Semantics(
            identifier: 'home.counter.text',
            child: Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          const Spacer(),
          Semantics(
            identifier: 'home.counter.button',
            child: FilledButton.icon(
              onPressed: _incrementCounter,
              icon: const Icon(Icons.add),
              label: const Text('カウント'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _spinnerCard() {
    return _demoCard(
      id: 'home.spinner',
      title: '🌀 回転アニメーション',
      child: Center(
        child: AnimatedBuilder(
          animation: _anim,
          builder: (_, __) => Transform.rotate(
            angle: _anim.value * 2 * pi,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: const SweepGradient(
                  colors: [Colors.purple, Colors.blue, Colors.cyan, Colors.purple],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.settings, color: Colors.white, size: 36),
            ),
          ),
        ),
      ),
    );
  }

  Widget _ballCard() {
    return _demoCard(
      id: 'home.ball',
      title: '⚫ 往復するボール',
      child: SizedBox(
        height: 48,
        child: AnimatedBuilder(
          animation: _anim,
          builder: (_, __) {
            final x = sin(_anim.value * 2 * pi);
            final color = HSVColor.fromAHSV(1, (_anim.value * 360) % 360, 0.7, 0.95)
                .toColor();
            return Align(
              alignment: Alignment(x, 0),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _progressCard() {
    return _demoCard(
      id: 'home.progress',
      title: '📊 アニメーションするバー',
      child: AnimatedBuilder(
        animation: _anim,
        builder: (_, __) {
          final value = (sin(_anim.value * 2 * pi) + 1) / 2;
          return Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(value: value, minHeight: 12),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text('${(value * 100).toStringAsFixed(0)} %'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _tabButton(int index, IconData icon, String label, String identifier) {
    final isSelected = _selectedTabIndex == index;
    final color = isSelected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);

    return Expanded(
      child: Semantics(
        identifier: identifier,
        child: InkWell(
          onTap: () => _onTabTapped(index),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
