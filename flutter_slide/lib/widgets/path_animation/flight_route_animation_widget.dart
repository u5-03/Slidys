import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_slide/constants/constants.dart';

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
        // 地図画像の全体サイズ
        final double imageWidth;
        final double imageHeight;
        if (constraints.maxWidth > constraints.maxHeight / 284 * 648) {
          imageWidth = constraints.maxHeight / 284 * 648;
          imageHeight = constraints.maxHeight;
        } else {
          imageWidth = constraints.maxWidth;
          imageHeight = constraints.maxWidth / 648 * 284;
        }

        return Stack(
          children: [
            // 背景の世界地図
            Positioned.fill(
              child: Image.asset(
                'assets/images/map.png',
                fit: BoxFit.contain,
                package: packageName,
              ),
            ),
            Positioned(
              left: constraints.maxWidth * 0.25,
              top: constraints.maxHeight * 0.4,
              child: SizedBox(
                width: imageWidth * 0.5,
                height: imageHeight * 0.2,
                child: PathAreaAnimationWidget(
                  content: Transform.rotate(
                    angle: pi / 2,
                    child: const Icon(
                      Icons.flight,
                      size: 60,
                      color: Colors.red,
                    ),
                  ),
                  controller: controller,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class PathAreaAnimationWidget extends StatelessWidget {
  final Widget content;
  final AnimationController controller;

  const PathAreaAnimationWidget({
    super.key,
    required this.content,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final widgetWidth = constraints.maxWidth;
        final widgetHeight = constraints.maxHeight;
        final start = Offset(0, widgetHeight * 0.9);
        final end = Offset(widgetWidth, widgetHeight * 0.9);
        final control = Offset((start.dx + end.dx) / 2, 0);
        final originalPath = Path()
          ..moveTo(start.dx, start.dy)
          ..quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);

        return Stack(
          children: [
            AnimatedBuilder(
              animation: controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: _FlightRoutePainter(
                    progress: controller.value,
                    path: originalPath,
                  ),
                  child: Container(),
                );
              },
            ),
            PathContentMoveAnimationWidget(
              path: originalPath,
              content: content,
              externalController: controller,
              offsetX: -widgetWidth * 0.03,
              offsetY: -widgetHeight * 0.25,
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
