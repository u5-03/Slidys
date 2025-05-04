import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_kaigi_slide/utils/font_path_converter.dart';
import 'package:flutter_kaigi_slide/utils/svg_path_painter.dart';

class TextPathWidget extends HookWidget {
  final String text;
  final String fontFamily;
  final PathAnimationType animationType;

  const TextPathWidget({
    super.key,
    required this.text,
    required this.fontFamily,
    required this.animationType,
  });

  @override
  Widget build(BuildContext context) {
    // アニメーションコントローラーを生成
    final controller =
        useAnimationController(duration: const Duration(seconds: 10));
    // 進捗率を取得
    final progress = useAnimation(controller);
    useEffect(() {
      () async {
        await controller.repeat();
      }();
      return null;
    }, const []);

    return FutureBuilder<Path>(
      future: TextPathConverter.generatePath(
        text,
        'lib/assets/fonts/HeftyRewardSingleLine-JRqWx.ttf', // 固定フォント
        32.0, // フォントサイズ
        const Size(300, 300), // サイズを固定
      ),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return CustomPaint(
            painter: SvgPathPainter(
              snapshot.data!,
              progress: progress,
              animationType: animationType,
            ),
            child: Container(),
          );
        } else if (snapshot.hasError) {
          return Center(
              child: Text('Error generating path: ${snapshot.error}'));
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
