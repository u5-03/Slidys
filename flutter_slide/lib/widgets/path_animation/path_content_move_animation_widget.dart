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
  final AnimationController externalController;

  const PathContentMoveAnimationWidget({
    super.key,
    required this.path,
    required this.content,
    this.duration = const Duration(seconds: 5),
    this.loop = false,
    this.offsetX = 0,
    this.offsetY = 0,
    this.rotateAngle,
    required this.externalController,
  });

  @override
  Widget build(BuildContext context) {
    final controller = externalController;
    final pathMetrics = path.computeMetrics().toList();
    final pathMetric = pathMetrics.isNotEmpty ? pathMetrics.first : null;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        if (pathMetric == null) {
          return const SizedBox.shrink();
        }
        final progress = controller.value;
        final tangent =
            pathMetric.getTangentForOffset(pathMetric.length * progress);
        if (tangent == null) {
          return const SizedBox.shrink();
        }
        final position = tangent.position;
        return Stack(
          children: [
            Positioned(
              left: position.dx + offsetX,
              top: position.dy + offsetY,
              child: content,
            ),
          ],
        );
      },
    );
  }
}
