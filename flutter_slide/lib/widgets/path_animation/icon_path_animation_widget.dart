import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_slide/constants/constants.dart';
import 'package:flutter_slide/utils/svg_path_converter.dart';
import 'package:flutter_slide/utils/svg_path_painter.dart';
import 'package:flutter_slide/widgets/path_animation/path_content_move_animation_widget.dart';

final class IconPathAnimationWidget extends HookWidget {
  const IconPathAnimationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(
      duration: const Duration(seconds: 20),
    )..repeat();

    return LayoutBuilder(builder: (context, constraints) {
      return FutureBuilder(
        future: convertSvgPathFromAsset(
          'assets/images/icon.svg',
        ),
        builder: (context, snapshot) {
          final path = snapshot.data;
          if (path == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final pathMetrics =
              path.computeMetrics().toList(); // 遅延評価を防ぐためにリストに変換
          if (pathMetrics.isEmpty) {
            return const Center(
              child: Text('Error: Path is empty'),
            );
          }

          return Stack(
            fit: StackFit.expand,
            children: [
              // Pathアニメーション
              AnimatedBuilder(
                animation: controller,
                builder: (context, child) {
                  return CustomPaint(
                    painter: SvgPathPainter(
                      path,
                      progress: controller.value,
                      animationType: PathAnimationType.progressiveDraw(),
                      strokeWidth: 2.0,
                      strokeColor: Colors.blue,
                    ),
                    size: Size(
                      constraints.maxWidth,
                      constraints.maxHeight,
                    ),
                  );
                },
              ),
              SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                child: ColoredBox(
                  color: Colors.transparent,
                  child: PathContentMoveAnimationWidget(
                    path: path,
                    duration: const Duration(seconds: 20),
                    content: SizedBox(
                      width: 100,
                      child: Image.asset(
                        'assets/images/icon.png',
                        fit: BoxFit.contain,
                        package: packageName,
                      ),
                    ),
                    loop: true,
                    externalController: controller,
                    offsetX: -12,
                    offsetY: -40,
                  ),
                ),
              ),
            ],
          );
        },
      );
    });
  }
}
