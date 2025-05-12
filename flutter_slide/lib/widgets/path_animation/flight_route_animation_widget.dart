import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

final class FlightRouteAnimationWidget extends HookWidget {
  const FlightRouteAnimationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(
      duration: const Duration(seconds: 2),
    )..repeat();

    useEffect(() {
      // アニメーションの進捗率を取得
      () async {
        try {
          final manifestJson =
              await rootBundle.loadString('AssetManifest.json');
          final Map<String, dynamic> manifest = json.decode(manifestJson);

          for (final path in manifest.keys) {
            print('Asset found: $path');
          }
        } catch (e) {
          print('Failed to load AssetManifest.json: $e');
        }
      }();

      return null;
    }, const []);

    return AspectRatio(
      aspectRatio: 648 / 284,
      child: LayoutBuilder(
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

          // Pathの初期化
          final path = Path()
            ..moveTo(tokyo.dx, tokyo.dy)
            ..quadraticBezierTo(
              controlPoint.dx,
              controlPoint.dy,
              california.dx,
              california.dy,
            );

          final pathMetrics =
              path.computeMetrics().toList(); // 遅延評価を防ぐためにリストに変換
          if (pathMetrics.isEmpty) {
            return const Center(
              child: Text('Error: Path is empty'),
            );
          }

          final pathMetric = pathMetrics.first;

          return Stack(
            children: [
              // 背景の世界地図
              Positioned.fill(
                // Add to Appの場合、packageを指定すると、resourceが見つからない
                child: Image.asset(
                  'assets/images/map.png',
                  fit: BoxFit.contain,
                  width: imageWidth,
                  height: imageHeight,
                  alignment: Alignment.center,
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
                },
              ),
              // アニメーションするFlightアイコン
              AnimatedBuilder(
                animation: controller,
                builder: (context, child) {
                  final progress = controller.value;
                  final position = pathMetrics.isNotEmpty
                      ? pathMetric
                          .getTangentForOffset(
                            pathMetric.length * progress,
                          )
                          ?.position
                      : null;

                  if (position == null) {
                    return const SizedBox.shrink();
                  }

                  return Positioned(
                    left: position.dx - 12, // アイコンの中心を調整
                    top: position.dy - 24, // 少し上にオフセット
                    child: Transform.rotate(
                      angle: pi / 2, // 右側に向くように90度回転
                      child: const Icon(
                        Icons.flight,
                        size: 100,
                        color: Colors.black,
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
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
