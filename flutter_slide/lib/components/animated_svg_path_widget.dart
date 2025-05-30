import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_slide/utils/font_path_converter.dart';
import 'package:flutter_slide/utils/svg_path_converter.dart';
import 'package:flutter_slide/utils/svg_path_painter.dart';

export 'package:flutter_slide/utils/svg_path_painter.dart'
    show PathAnimationType;

sealed class PathSourceType {
  const PathSourceType();

  factory PathSourceType.path(Path path) = PathSource;
  factory PathSourceType.assetPath(String assetPath) = AssetPathSource;
  factory PathSourceType.text(
    String text,
    double fontSize,
  ) = TextSource;
}

final class PathSource extends PathSourceType {
  final Path path;
  const PathSource(this.path);
}

final class AssetPathSource extends PathSourceType {
  final String assetPath;
  const AssetPathSource(this.assetPath);
}

final class TextSource extends PathSourceType {
  final String text;
  final double fontSize;
  const TextSource(this.text, this.fontSize);
}

final class AnimatedSvgPathWidget extends HookWidget {
  final PathSourceType pathSource;
  final PathAnimationType animationType;
  final Duration duration; // アニメーションの実行時間
  final bool loop; // アニメーションをループするかどうか
  final bool shouldAnimate;
  final double? defaultProgress; // アニメーションの進捗率
  final AnimationController? externalController; // 外部から渡されるAnimationController
  final double strokeWidth; // 線の幅
  final Color strokeColor; // 線の色

  const AnimatedSvgPathWidget({
    super.key,
    required this.pathSource,
    required this.animationType,
    this.duration = const Duration(seconds: 10), // デフォルト10秒
    this.loop = false, // デフォルトでループしない
    this.shouldAnimate = true, // アニメーションを実行するかどうか
    this.defaultProgress, // 外部から進捗率を指定する場合
    this.externalController, // デフォルトはnull
    this.strokeWidth = 2.0, // デフォルトの線の幅
    this.strokeColor = Colors.white, // デフォルトの線の色
  });

  @override
  Widget build(BuildContext context) {
    // AnimationControllerを外部から受け取るか、このウィジェット内で生成する
    final controller = externalController ??
        useAnimationController(
            duration: shouldAnimate ? duration : Duration.zero);

    // アニメーションの進捗率を取得
    final progress = useAnimation(controller);

    useEffect(() {
      if (externalController == null) {
        // 外部からコントローラーが渡されていない場合のみ、ローカルで制御
        () async {
          if (!loop || !shouldAnimate) {
            await controller.forward();
          } else {
            await controller.repeat();
          }
        }();
      }
      return null;
    }, [controller, loop]);

    return FutureBuilder<Path>(
      future: _resolvePath(pathSource),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: CustomPaint(
              painter: SvgPathPainter(
                snapshot.data!,
                progress: defaultProgress ?? progress,
                animationType: animationType,
                strokeWidth: strokeWidth, // 線の幅を指定
                strokeColor: strokeColor, // 線の色を指定
              ),
              // 外側でサイズ指定できるようにchildは空のContainerとする
              child: Container(),
            ),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error loading path: ${snapshot.error}'));
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Future<Path> _resolvePath(PathSourceType sourceType) async {
    switch (sourceType) {
      case AssetPathSource assetPathSource:
        return convertSvgPathFromAsset(assetPathSource.assetPath);
      case PathSource pathSource:
        return pathSource.path;
      case TextSource(:final text, :final fontSize):
        return TextPathConverter.generatePath(
          text,
          'lib/assets/fonts/HeftyRewardSingleLine-JRqWx.ttf', // 固定フォント
          fontSize, // フォントサイズ
          const Size(300, 300), // サイズを固定
          randomizeGlyphOrder: true,
        );
    }
  }
}
