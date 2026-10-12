import 'dart:async';

import 'package:flutter/material.dart';

import '../../slide_language.dart';

/// 画面上の Widget をタップして選ぶ ElementPicker。
///
/// iOS 版 `ElementPickerViewController` / `ViewFrameCollector` に相当。
/// 選択モードに入ると画面の上に透明なオーバーレイが重なり、ユーザーが Widget をタップすると
/// その位置にある(identifier を持つ)Widget のうち一番小さい = 具体的なものが選ばれ、
/// 選択中の Widget だけが枠で囲まれて identifier が表示される。
/// 「この要素にする」で identifier を確定する。
///
/// iOS では `accessibilityIdentifier` を拾うが、Flutter では等価物として
///  - `Semantics(identifier: ...)` の identifier
///  - `ValueKey<String>` の値
/// を持つ Widget を候補として収集する。
class ElementPicker {
  const ElementPicker._();

  /// ピッカーを起動する。確定された identifier を返す。キャンセル時は null。
  ///
  /// [overlay] には root の [OverlayState] を渡す (Composer を閉じる前に取得しておく)。
  /// [onSelectionChanged] は選択中の要素が変わるたびに呼ばれる(デモ表示用)。
  static Future<String?> pick(
    OverlayState overlay, {
    ValueChanged<String?>? onSelectionChanged,
  }) {
    final completer = Completer<String?>();
    late OverlayEntry entry;

    void finish(String? id) {
      if (entry.mounted) entry.remove();
      if (!completer.isCompleted) completer.complete(id);
    }

    entry = OverlayEntry(
      builder: (_) => _ElementPickerOverlay(
        onFinish: finish,
        onSelectionChanged: onSelectionChanged,
      ),
    );
    overlay.insert(entry);
    return completer.future;
  }

  /// root element ツリーを走査し、identifier を持つ Widget とその画面上の矩形を集める。
  static List<ElementCandidate> collectCandidates() {
    final result = <ElementCandidate>[];

    void visit(Element el) {
      final identifier = _identifierOf(el.widget);
      if (identifier != null && identifier.isNotEmpty) {
        final renderObject = el.findRenderObject();
        if (renderObject is RenderBox &&
            renderObject.attached &&
            renderObject.hasSize &&
            renderObject.size.width > 0 &&
            renderObject.size.height > 0) {
          final topLeft = renderObject.localToGlobal(Offset.zero);
          result.add(
            ElementCandidate(identifier, topLeft & renderObject.size),
          );
        }
      }
      el.visitChildren(visit);
    }

    WidgetsBinding.instance.rootElement?.visitChildren(visit);
    return result;
  }

  /// タップ位置を含む候補のうち、面積が最小 = 一番具体的な要素を返す。
  static ElementCandidate? hitTest(
    List<ElementCandidate> candidates,
    Offset point,
  ) {
    ElementCandidate? best;
    for (final c in candidates) {
      if (!c.rect.contains(point)) continue;
      if (best == null || c.area < best.area) best = c;
    }
    return best;
  }

  static String? _identifierOf(Widget widget) {
    if (widget is Semantics) {
      final id = widget.properties.identifier;
      if (id != null && id.isNotEmpty) return id;
    }
    final key = widget.key;
    if (key is ValueKey<String>) return key.value;
    return null;
  }
}

/// identifier を持つ要素の候補 (identifier + 画面上の矩形)
class ElementCandidate {
  ElementCandidate(this.identifier, this.rect);

  final String identifier;
  final Rect rect;

  double get area => rect.width * rect.height;
}

/// 画面全体を覆い、タップした位置の Widget を選択して枠で囲むオーバーレイ。
class _ElementPickerOverlay extends StatefulWidget {
  const _ElementPickerOverlay({
    required this.onFinish,
    this.onSelectionChanged,
  });

  final ValueChanged<String?> onFinish;
  final ValueChanged<String?>? onSelectionChanged;

  @override
  State<_ElementPickerOverlay> createState() => _ElementPickerOverlayState();
}

class _ElementPickerOverlayState extends State<_ElementPickerOverlay> {
  late List<ElementCandidate> _candidates;
  ElementCandidate? _selected;

  @override
  void initState() {
    super.initState();
    _candidates = ElementPicker.collectCandidates();
  }

  void _onTapDown(TapDownDetails details) {
    // 候補の矩形は起動時のものなので、アニメーション等で動く要素に備えて毎回取り直す。
    _candidates = ElementPicker.collectCandidates();
    final hit = ElementPicker.hitTest(_candidates, details.globalPosition);
    setState(() => _selected = hit);
    widget.onSelectionChanged?.call(hit?.identifier);
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    return Stack(
      children: [
        // 背景を薄く暗くして「選択モード」であることを示す。タップで要素を選ぶ。
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: _onTapDown,
            child: ColoredBox(color: Colors.black.withValues(alpha: 0.12)),
          ),
        ),

        // 選択中の要素だけを枠で囲む
        if (selected != null) _selectionBox(selected),

        // 上部のバナー: 説明 / 選択中の identifier / 決定・キャンセル
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          child: SafeArea(
            child: Material(
              color: Colors.black87,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        selected == null
                            ? tr('報告したい要素をタップしてください',
                                'Tap the element you want to report')
                            : tr('選択中: ${selected.identifier}',
                                'Selected: ${selected.identifier}'),
                        style: const TextStyle(color: Colors.white),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    TextButton(
                      onPressed: () => widget.onFinish(null),
                      child: Text(tr('キャンセル', 'Cancel')),
                    ),
                    FilledButton(
                      onPressed: selected == null
                          ? null
                          : () => widget.onFinish(selected.identifier),
                      child: Text(tr('この要素にする', 'Use this element')),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // 候補が無いときの案内
        if (_candidates.isEmpty)
          Center(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(tr('この画面に選択可能な要素がありません',
                    'No selectable elements on this screen')),
              ),
            ),
          ),
      ],
    );
  }

  Widget _selectionBox(ElementCandidate c) {
    return Positioned.fromRect(
      rect: c.rect,
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blueAccent, width: 2.5),
            color: Colors.blueAccent.withValues(alpha: 0.15),
          ),
          child: Align(
            alignment: Alignment.topLeft,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.topLeft,
              child: Container(
                color: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                child: Text(
                  c.identifier,
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
