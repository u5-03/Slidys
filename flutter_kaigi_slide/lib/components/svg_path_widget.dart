import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_kaigi_slide/utils/svg_path_converter.dart';
import 'package:flutter_kaigi_slide/utils/svg_path_painter.dart';

class AnimatedSvgPathWidget extends HookWidget {
  final String assetPath;

  const AnimatedSvgPathWidget({super.key, required this.assetPath});

  @override
  Widget build(BuildContext context) {
    // 10秒間のアニメーションコントローラーを生成
    final controller =
        useAnimationController(duration: const Duration(seconds: 10));
    // 0.0～1.0の進捗率を取得
    final progress = useAnimation(controller);
    useEffect(() {
      () async {
        // await controller.forward();
        // controller.reverse();
        await controller.repeat();
      }();
      return null;
    }, const []);

    return FutureBuilder<Path>(
      future: convertSvgPathFromAsset(assetPath),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return CustomPaint(
            painter: SvgPathPainter(snapshot.data!, progress: progress),
            // 外側でサイズ指定できるようにchildは空のContainerとする
            child: Container(),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error loading SVG: ${snapshot.error}'));
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
