import 'dart:math' as math;

import 'package:flutter/material.dart';

/// CustomPainterで、統合したPathを元のアスペクト比を保持しながら
/// 指定領域内に収め、さらに extractPath を使って進捗率 (progress: 0～1) に基づき
/// 全体のPathを1つの連続したPathとして描画する例
final class SvgPathPainter extends CustomPainter {
  final Path path;
  final double progress; // 0.0～1.0 の進捗率。デフォルトは1.0（全体描画）

  SvgPathPainter(this.path, {this.progress = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // 統合Pathのバウンディングボックスを取得
    final bounds = path.getBounds();
    if (bounds.isEmpty) return;

    // 指定領域 (size) 内に収めるためのスケール（アスペクト比を保持）
    final scaleX = size.width / bounds.width;
    final scaleY = size.height / bounds.height;
    final scale = math.min(scaleX, scaleY);

    // 中央に配置するためのオフセット計算
    final offsetX =
        (size.width - bounds.width * scale) / 2 - bounds.left * scale;
    final offsetY =
        (size.height - bounds.height * scale) / 2 - bounds.top * scale;

    canvas.save();
    canvas.translate(offsetX, offsetY);
    canvas.scale(scale, scale);

    // 全体のPathの累積長に対して、progress に応じた長さを求める
    final metrics = path.computeMetrics().toList();
    final totalLength = metrics.fold(0.0, (sum, metric) => sum + metric.length);
    final targetLength = totalLength * progress;
    double currentLength = 0.0;
    final trimmedPath = Path();

    // 各 Metric を累積的に抽出し、1つの連続した Path として生成
    for (final metric in metrics) {
      if (currentLength + metric.length < targetLength) {
        trimmedPath.addPath(metric.extractPath(0, metric.length), Offset.zero);
        currentLength += metric.length;
      } else {
        final remaining = targetLength - currentLength;
        if (remaining > 0) {
          trimmedPath.addPath(metric.extractPath(0, remaining), Offset.zero);
        }
        break;
      }
    }

    canvas.drawPath(trimmedPath, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant SvgPathPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.path != path;
  }
}
