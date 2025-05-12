import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'path_content_move_animation_widget.dart';

final class FlightRouteAnimationWidget extends HookWidget {
  const FlightRouteAnimationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(
      duration: const Duration(seconds: 2),
    )..repeat();

    return LayoutBuilder(
      builder: (context, constraints) {
        // 画像の描画サイズ
        final double imageWidth;
        final double imageHeight;
        final Offset baseOffset;
        if (constraints.maxWidth > constraints.maxHeight / 284 * 648) {
          imageWidth = constraints.maxHeight / 284 * 648;
          imageHeight = constraints.maxHeight; // 高さを基準にする
          baseOffset = Offset(
            (constraints.maxWidth - imageWidth) / 2,
            0,
          );
        } else {
          imageWidth = constraints.maxWidth;
          imageHeight = constraints.maxWidth / 648 * 284; // 幅を基準にする
          baseOffset = Offset(
            0,
            (constraints.maxHeight - imageHeight) / 2,
          );
        }
        // 基準サイズ (w: 648, h: 284) に基づく相対座標
        final tokyo = Offset(baseOffset.dx + imageWidth / 20 * 4,
            baseOffset.dy + imageHeight / 10 * 6);
        // const tokyo = Offset(300, 100);
        final california = Offset(baseOffset.dx + imageWidth / 100 * 68,
            baseOffset.dy + imageHeight / 100 * 55);
        final controlPoint = Offset(
          (tokyo.dx + california.dx) / 2,
          (tokyo.dy + california.dy) / 2 - 100,
        );
        final path = Path()
          ..moveTo(tokyo.dx, tokyo.dy)
          ..quadraticBezierTo(
            controlPoint.dx,
            controlPoint.dy,
            california.dx,
            california.dy,
          );

        final pathMetrics = path.computeMetrics().toList(); // 遅延評価を防ぐためにリストに変換
        if (pathMetrics.isEmpty) {
          return const Center(
            child: Text('Error: Path is empty'),
          );
        }

        return Stack(
          children: [
            // 背景の世界地図
            Positioned.fill(
              child: Image.asset(
                'assets/images/map.png',
                fit: BoxFit.contain,
                package: 'flutter_slide',
              ),
            ),
            // Pathアニメーション
            AnimatedBuilder(
                animation: controller,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _FlightRoutePainter(
                      progress: controller.value,
                      path: path,
                    ),
                    child: Container(),
                  );
                }),
            // Path上をIcons.flightが動くアニメーション
            SizedBox(
              child: PathContentMoveAnimationWidget(
                path: path,
                content: Transform.rotate(
                  angle: pi / 2, // 右側に向くように90度回転
                  child: const Icon(
                    Icons.flight,
                    size: 100,
                    color: Colors.red,
                  ),
                ),
                duration: controller.duration ?? const Duration(seconds: 2),
                loop: true,
                offsetX: -12,
                offsetY: -24,
                externalController: controller,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FlightRoutePainter extends CustomPainter {
  final double progress;
  final Path path;

  _FlightRoutePainter({required this.progress, required this.path});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Pathの進捗に応じて部分的に描画
    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;

    final partialPath =
        metrics.first.extractPath(0, metrics.first.length * progress);

    canvas.drawPath(partialPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
