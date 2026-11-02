import 'package:flutter/material.dart';

/// 実行時の Element ツリーを歩いて、Widget 階層をインデント付きテキストにする。
///
/// iOS 版 `DiagnosticCollector.collectViewHierarchy()`(view-hierarchy.txt)の Flutter 版。
/// ElementPicker と同じ走査で、各 Element の
///  - Widget のクラス名
///  - RenderBox のサイズ(持っていれば)
///  - `Semantics(identifier:)` / `ValueKey<String>` の identifier(持っていれば)
/// を 1 行ずつ出力する。レイアウト崩れの一次資料として Issue に添付する用途。
class WidgetTreeDumper {
  const WidgetTreeDumper._();

  /// ノイズになりやすい内部 Widget を省くかどうか。
  /// true のとき、名前が `_` で始まる private な Widget は行を出さずに子だけ辿る。
  static String dump({bool skipPrivateWidgets = true}) {
    final buffer = StringBuffer();

    void visit(Element el, int depth) {
      final widget = el.widget;
      final typeName = widget.runtimeType.toString();
      final isPrivate = typeName.startsWith('_');
      var nextDepth = depth;

      if (!(skipPrivateWidgets && isPrivate)) {
        final renderObject = el.findRenderObject();
        final size = (renderObject is RenderBox && renderObject.hasSize)
            ? renderObject.size
            : null;
        final identifier = identifierOf(widget);

        buffer
          ..write('  ' * depth)
          ..write(typeName);
        if (size != null) {
          buffer.write(' ${size.width.round()}x${size.height.round()}');
        }
        if (identifier != null) {
          buffer.write(' #$identifier');
        }
        buffer.writeln();
        nextDepth = depth + 1;
      }
      el.visitChildren((child) => visit(child, nextDepth));
    }

    WidgetsBinding.instance.rootElement?.visitChildren((e) => visit(e, 0));
    return buffer.toString();
  }

  /// ElementPicker と同じ規則で「目印」を取り出す。
  static String? identifierOf(Widget widget) {
    if (widget is Semantics) {
      final id = widget.properties.identifier;
      if (id != null && id.isNotEmpty) return id;
    }
    final key = widget.key;
    if (key is ValueKey<String>) return key.value;
    return null;
  }
}

/// Widget 階層ダンプを表示する画面。
class WidgetTreeScreen extends StatefulWidget {
  const WidgetTreeScreen({super.key});

  static Future<void> show(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const WidgetTreeScreen(),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  State<WidgetTreeScreen> createState() => _WidgetTreeScreenState();
}

class _WidgetTreeScreenState extends State<WidgetTreeScreen> {
  // この画面自身が push される前(= アプリ本体が表示されている瞬間)の階層を残すため、
  // 遷移アニメーション前の initState でダンプする。
  late final String _dump = WidgetTreeDumper.dump();

  @override
  Widget build(BuildContext context) {
    final lineCount = '\n'.allMatches(_dump).length;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Widget 階層'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              '$lineCount 行 (クラス名 / サイズ / #identifier)',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Expanded(
            child: Scrollbar(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SelectableText(
                    _dump,
                    style: const TextStyle(
                      fontFamily: 'Menlo',
                      fontFamilyFallback: ['monospace'],
                      fontSize: 11,
                      height: 1.35,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
