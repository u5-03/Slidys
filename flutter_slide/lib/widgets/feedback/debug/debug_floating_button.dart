import 'package:flutter/material.dart';

import 'debug_menu_screen.dart';

/// アプリ全体に重ねるフローティングのデバッグボタン。
///
/// iOS 版 `DebugMenuWindow`(AppEnvironment.isDebugFunctionEnabled のときのみ表示される
/// フローティングボタン) に相当。[enabled] が true のときだけ表示され、ドラッグで移動できる。
/// タップで [DebugMenuScreen] を開く。
class DebugFloatingButton extends StatefulWidget {
  const DebugFloatingButton({
    super.key,
    required this.child,
    this.enabled = true,
  });

  /// アプリ本体。
  final Widget child;

  /// 表示するかどうか (本番ビルドでは false にする想定)。
  final bool enabled;

  @override
  State<DebugFloatingButton> createState() => _DebugFloatingButtonState();
}

class _DebugFloatingButtonState extends State<DebugFloatingButton> {
  // 初期位置は null (初回 build で右下に配置)
  Offset? _position;

  static const double _size = 52;

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return LayoutBuilder(
      builder: (context, constraints) {
        final pos = _position ??
            Offset(
              constraints.maxWidth - _size - 16,
              constraints.maxHeight - _size - 120,
            );
        return Stack(
          children: [
            // アプリ本体 (Navigator) を全面に敷く。Positioned.fill で tight な
            // 全画面制約を与え、各ルートのヒットテスト領域が全面に及ぶようにする。
            Positioned.fill(child: widget.child),
            Positioned(
              left: pos.dx,
              top: pos.dy,
              child: _button(constraints),
            ),
          ],
        );
      },
    );
  }

  Widget _button(BoxConstraints constraints) {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          final current = _position ??
              Offset(
                constraints.maxWidth - _size - 16,
                constraints.maxHeight - _size - 120,
              );
          final next = current + details.delta;
          _position = Offset(
            next.dx.clamp(0, constraints.maxWidth - _size),
            next.dy.clamp(0, constraints.maxHeight - _size),
          );
        });
      },
      onTap: () => DebugMenuScreen.show(),
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: _size,
          height: _size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withValues(alpha: 0.72),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(
            Icons.build,
            color: Colors.white,
            size: 26,
          ),
        ),
      ),
    );
  }
}
