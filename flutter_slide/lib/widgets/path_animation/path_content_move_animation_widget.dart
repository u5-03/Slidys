import 'dart:math';

import 'package:flutter/material.dart';

/// 指定したPath上を任意のWidget（表示コンテンツ）がアニメーションで移動するWidget
class PathContentMoveAnimationWidget extends StatelessWidget {
  final Path path;
  final Widget content;
  final Duration duration;
  final bool loop;
  final double offsetX;
  final double offsetY;
  final double? rotateAngle; // nullの場合は進行方向に自動回転
  final EdgeInsets padding;
  final AnimationController? externalController;

  const PathContentMoveAnimationWidget({
    super.key,
    required this.path,
    required this.content,
    this.duration = const Duration(seconds: 5),
    this.loop = false,
    this.offsetX = 0,
    this.offsetY = 0,
    this.rotateAngle,
    this.padding = const EdgeInsets.all(0),
    this.externalController,
  });

  @override
  Widget build(BuildContext context) {
    final animationController = externalController;
    if (animationController == null) {
      return const SizedBox.shrink();
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final widgetWidth = constraints.maxWidth;
        final widgetHeight = constraints.maxHeight;

        // PathをWidgetサイズにフィットさせる
        final bounds = path.getBounds();

        // paddingを考慮した表示可能領域を計算
        final availableWidth = widgetWidth - padding.left - padding.right;
        final availableHeight = widgetHeight - padding.top - padding.bottom;

        final scaleX = availableWidth / bounds.width;
        final scaleY = availableHeight / bounds.height;
        final scale = min(scaleX, scaleY);

        // paddingを考慮した中央配置のための平行移動量計算
        final dx = -bounds.left * scale +
            padding.left +
            (availableWidth - bounds.width * scale) / 2;
        final dy = -bounds.top * scale +
            padding.top +
            (availableHeight - bounds.height * scale) / 2;

        final matrix = Matrix4.identity()
          ..translate(dx, dy)
          ..scale(scale, scale);
        final fittedPath = path.transform(matrix.storage);
        final pathMetrics = fittedPath.computeMetrics().toList();
        final totalLength =
            pathMetrics.fold<double>(0, (sum, m) => sum + m.length);

        return AnimatedBuilder(
          animation: animationController,
          builder: (context, child) {
            if (pathMetrics.isEmpty) {
              return const SizedBox.shrink();
            }
            final progress = animationController.value;
            double currentLength = 0.0;
            Offset? position;
            for (final metric in pathMetrics) {
              final nextLength = currentLength + metric.length;
              if (totalLength * progress <= nextLength) {
                final localOffset = totalLength * progress - currentLength;
                position = metric.getTangentForOffset(localOffset)?.position;
                break;
              }
              currentLength = nextLength;
            }
            position ??= pathMetrics.last
                .getTangentForOffset(pathMetrics.last.length)
                ?.position;

            if (position == null) {
              return const SizedBox.shrink();
            }
            final angle = rotateAngle ?? 0.0;

            // paddingを考慮した範囲でクランプ
            final minX = padding.left;
            final maxX = widgetWidth - padding.right;
            final minY = padding.top;
            final maxY = widgetHeight - padding.bottom;

            final clampedX = (position.dx + offsetX).clamp(minX, maxX);
            final clampedY = (position.dy + offsetY).clamp(minY, maxY);

            return Stack(
              children: [
                Positioned(
                  left: clampedX,
                  top: clampedY,
                  child: Transform.rotate(
                    angle: angle,
                    child: content,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
