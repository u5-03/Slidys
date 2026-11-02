import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_log_buffer.dart';

/// アプリ内で出力された実行時ログ (print / debugPrint / エラー) を確認する画面。
class LogViewerScreen extends StatefulWidget {
  const LogViewerScreen({super.key});

  static Future<void> show(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const LogViewerScreen(),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  State<LogViewerScreen> createState() => _LogViewerScreenState();
}

class _LogViewerScreenState extends State<LogViewerScreen> {
  final AppLogBuffer _buffer = AppLogBuffer.instance;
  final ScrollController _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.jumpTo(_scroll.position.maxScrollExtent);
      }
    });
  }

  Future<void> _copyAll() async {
    await Clipboard.setData(ClipboardData(text: _buffer.dumpText()));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('ログをコピーしました')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('実行ログビューア'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            tooltip: 'コピー',
            icon: const Icon(Icons.copy_all),
            onPressed: _copyAll,
          ),
          IconButton(
            tooltip: '一番下へ',
            icon: const Icon(Icons.vertical_align_bottom),
            onPressed: _scrollToBottom,
          ),
          IconButton(
            tooltip: 'クリア',
            icon: const Icon(Icons.delete_outline),
            onPressed: _buffer.clear,
          ),
        ],
      ),
      body: ValueListenableBuilder<int>(
        valueListenable: _buffer.revision,
        builder: (context, _, __) {
          final entries = _buffer.entries;
          if (entries.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'ログはまだありません。\n'
                  'ホーム画面の「カウント」ボタンをタップすると、ここにログが出ます。',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          // 新しいログが増えたら自動で一番下までスクロール。
          _scrollToBottom();
          return Column(
            children: [
              Container(
                width: double.infinity,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Text(
                  '${entries.length} 件 (最大 ${AppLogBuffer.maxEntries} 件を保持)',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.all(12),
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final e = entries[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: SelectableText.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '${AppLogBuffer.formatTimePublic(e.timestamp)}  ',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontFamily: 'monospace',
                                fontSize: 12,
                              ),
                            ),
                            TextSpan(
                              text: e.message,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
