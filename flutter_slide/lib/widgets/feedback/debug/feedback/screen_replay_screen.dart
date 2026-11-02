import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screen_replay_recorder.dart';

/// 画面リプレイ (直近 60 秒のリングバッファ録画) の操作画面。
///
/// アプリ起動時から裏で常にバッファリングしている想定で、この画面では
///  - 現在のバッファ状況 (state / フレーム数)
///  - バッファリングの開始 / 停止
///  - 「直近 60 秒を動画にする」書き出し
/// を提供する。書き出しは iOS ネイティブの AVAssetWriter エンコーダを叩く。
class ScreenReplayScreen extends StatefulWidget {
  const ScreenReplayScreen({super.key});

  static Future<void> show(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const ScreenReplayScreen(),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  State<ScreenReplayScreen> createState() => _ScreenReplayScreenState();
}

class _ScreenReplayScreenState extends State<ScreenReplayScreen> {
  final ScreenReplayRecorder _recorder = ScreenReplayRecorder.instance;

  bool _exporting = false;
  ExportedClip? _lastClip;
  String? _error;

  Future<void> _export() async {
    setState(() {
      _exporting = true;
      _error = null;
      _lastClip = null;
    });
    try {
      final clip = await _recorder.exportClip();
      if (!mounted) return;
      setState(() => _lastClip = clip);
      // 生成できたら、そのまま OS の共有シートを表示する。
      await _share(clip.path);
    } on MissingPluginException {
      if (!mounted) return;
      setState(() => _error =
          'このプラットフォームではエンコーダ未実装です (現在は iOS のみ対応)');
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _share(String path) async {
    try {
      await _recorder.shareClip(path);
    } on MissingPluginException {
      _showSnack('共有はこのプラットフォームでは未対応です (現在は iOS のみ)');
    } catch (error) {
      _showSnack('共有に失敗しました: $error');
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('画面リプレイ'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _statusCard(),
          _controlCard(),
          _exportCard(),
          if (_lastClip != null) _resultCard(_lastClip!),
          if (_error != null) _errorCard(_error!),
        ],
      ),
    );
  }

  Widget _card({required String title, required List<Widget> children}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _statusCard() {
    return _card(
      title: 'バッファ状況',
      children: [
        ValueListenableBuilder<ReplayState>(
          valueListenable: _recorder.state,
          builder: (_, state, __) {
            final (label, color, icon) = switch (state) {
              ReplayState.buffering => ('録画中 (バッファリング)', Colors.green, Icons.fiber_manual_record),
              ReplayState.idle => ('停止中', Colors.grey, Icons.stop_circle),
              ReplayState.unavailable => ('利用不可', Colors.orange, Icons.error_outline),
            };
            return Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(label),
              ],
            );
          },
        ),
        const SizedBox(height: 8),
        ValueListenableBuilder<int>(
          valueListenable: _recorder.bufferedFrames,
          builder: (_, count, __) => Text(
            'バッファ内フレーム数: $count 枚 '
            '(約 ${(count / _recorder.frameRate).toStringAsFixed(1)} 秒 / '
            '${_recorder.frameRate.toStringAsFixed(0)}fps)',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }

  Widget _controlCard() {
    return _card(
      title: '録画コントロール',
      children: [
        ValueListenableBuilder<ReplayState>(
          valueListenable: _recorder.state,
          builder: (_, state, __) {
            final buffering = state == ReplayState.buffering;
            return Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('開始'),
                    onPressed: buffering ? null : _recorder.startBuffering,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.stop),
                    label: const Text('停止'),
                    onPressed: buffering ? _recorder.stopBuffering : null,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _exportCard() {
    return _card(
      title: '動画に書き出す',
      children: [
        const Text('直近 60 秒分のフレームを mp4 にエンコードします。'),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            icon: _exporting
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.movie_creation),
            label: Text(_exporting ? 'エンコード中…' : '直近 60 秒を動画にする'),
            onPressed: _exporting ? null : _export,
          ),
        ),
      ],
    );
  }

  Widget _resultCard(ExportedClip clip) {
    final sizeKb = () {
      try {
        return (File(clip.path).lengthSync() / 1024).toStringAsFixed(0);
      } catch (_) {
        return '?';
      }
    }();
    return _card(
      title: '書き出し完了',
      children: [
        Text('フレーム数: ${clip.frameCount} 枚'),
        Text('長さ: ${clip.duration.toStringAsFixed(1)} 秒'),
        Text('サイズ: $sizeKb KB'),
        const SizedBox(height: 4),
        SelectableText(
          clip.path,
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.ios_share),
            label: const Text('共有シートを開く'),
            onPressed: () => _share(clip.path),
          ),
        ),
      ],
    );
  }

  Widget _errorCard(String error) {
    return _card(
      title: '書き出し失敗',
      children: [
        Text(error, style: const TextStyle(color: Colors.redAccent)),
      ],
    );
  }
}
