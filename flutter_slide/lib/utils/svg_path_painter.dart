import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Pathアニメーションの種類を定義するsealed class
sealed class PathAnimationType {
  const PathAnimationType();

  factory PathAnimationType.fixedRatioMove(double strokeLengthRatio) =>
      FixedRatioMove(strokeLengthRatio);
  factory PathAnimationType.progressiveDraw() => const ProgressiveDraw();
}

/// Pathが進捗率に応じてどんどん伸びるアニメーション
final class ProgressiveDraw extends PathAnimationType {
  const ProgressiveDraw();
}

/// Pathが一定の幅を維持しながら移動するアニメーション
final class FixedRatioMove extends PathAnimationType {
  final double strokeLengthRatio; // Path全体の長さに対する比率 (0.0～1.0)
  const FixedRatioMove(this.strokeLengthRatio);
}

/// CustomPainterで、統合したPathを元のアスペクト比を保持しながら
/// 指定領域内に収め、さらに extractPath を使って進捗率 (progress: 0～1) に基づき
/// 全体のPathを1つの連続したPathとして描画する例
final class SvgPathPainter extends CustomPainter {
  final Path path;
  final double progress; // 0.0～1.0 の進捗率。デフォルトは1.0（全体描画）
  final PathAnimationType animationType;
  final double strokeWidth; // 線の幅
  final Color strokeColor; // 線の色

  SvgPathPainter(this.path,
      {this.progress = 1.0,
      this.animationType = const ProgressiveDraw(),
      this.strokeWidth = 2.0,
      this.strokeColor = Colors.white})
      : assert(progress >= 0.0 && progress <= 1.0,
            'Progress must be between 0.0 and 1.0');

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = strokeColor // 外部から渡された色を使用
      ..strokeWidth = strokeWidth // 外部から渡された幅を使用
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

    // Pathの描画処理
    switch (animationType) {
      case ProgressiveDraw():
        _drawProgressive(canvas, paint);
        break;
      case FixedRatioMove(:final strokeLengthRatio):
        _drawFixedRatioMove(canvas, paint, strokeLengthRatio);
        break;
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant SvgPathPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.path != path ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.strokeColor != strokeColor;
  }
}

extension on SvgPathPainter {
  /// ProgressiveDraw: Pathが進捗率に応じてどんどん伸びる
  void _drawProgressive(Canvas canvas, Paint paint) {
    final metrics = path.computeMetrics().toList();
    final totalLength = metrics.fold(0.0, (sum, metric) => sum + metric.length);
    final targetLength = totalLength * progress;
    double currentLength = 0.0;
    final trimmedPath = Path();

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
  }

  /// FixedRatioMove: Pathが一定の幅を維持しながら移動
  void _drawFixedRatioMove(
      Canvas canvas, Paint paint, double strokeLengthRatio) {
    final metrics = path.computeMetrics().toList();
    final totalLength = metrics.fold(0.0, (sum, metric) => sum + metric.length);
    final strokeLength = totalLength * strokeLengthRatio;
    final startLength = totalLength * progress;
    final endLength = startLength + strokeLength;
    double currentLength = 0.0;
    final trimmedPath = Path();

    for (final metric in metrics) {
      if (currentLength + metric.length < startLength) {
        currentLength += metric.length;
        continue;
      }

      final localStart = math.max(0.0, startLength - currentLength);
      final localEnd = math.min(metric.length, endLength - currentLength);

      if (localStart < localEnd) {
        trimmedPath.addPath(
            metric.extractPath(localStart, localEnd), Offset.zero);
      }

      currentLength += metric.length;
      if (currentLength >= endLength) break;
    }

    canvas.drawPath(trimmedPath, paint);
  }
}
