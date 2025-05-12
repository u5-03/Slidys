import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_slide/utils/svg_path_converter.dart';
import 'package:flutter_slide/utils/svg_path_painter.dart';

export 'package:flutter_slide/utils/svg_path_painter.dart'
    show PathAnimationType;

sealed class PathSourceType {
  const PathSourceType();

  factory PathSourceType.path(Path path) = _PathSource;
  factory PathSourceType.assetPath(String assetPath) = _AssetPathSource;
}

final class _PathSource extends PathSourceType {
  final Path path;
  const _PathSource(this.path);
}

final class _AssetPathSource extends PathSourceType {
  final String assetPath;
  const _AssetPathSource(this.assetPath);
}

final class AnimatedSvgPathWidget extends HookWidget {
  final PathSourceType pathSource;
  final PathAnimationType animationType;
  final Duration duration; // アニメーションの実行時間
  final bool loop; // アニメーションをループするかどうか
  final AnimationController? externalController; // 外部から渡されるAnimationController
  final double strokeWidth; // 線の幅
  final Color strokeColor; // 線の色

  const AnimatedSvgPathWidget({
    super.key,
    required this.pathSource,
    required this.animationType,
    this.duration = const Duration(seconds: 10), // デフォルト10秒
    this.loop = false, // デフォルトでループしない
    this.externalController, // デフォルトはnull
    this.strokeWidth = 2.0, // デフォルトの線の幅
    this.strokeColor = Colors.white, // デフォルトの線の色
  });

  @override
  Widget build(BuildContext context) {
    // AnimationControllerを外部から受け取るか、このウィジェット内で生成する
    final controller =
        externalController ?? useAnimationController(duration: duration);

    // アニメーションの進捗率を取得
    final progress = useAnimation(controller);

    useEffect(() {
      if (externalController == null) {
        // 外部からコントローラーが渡されていない場合のみ、ローカルで制御
        () async {
          if (loop) {
            await controller.repeat();
          } else {
            await controller.forward();
          }
        }();
      }
      return null;
    }, [controller, loop]);

    return FutureBuilder<Path>(
      future: _resolvePath(pathSource),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return CustomPaint(
            painter: SvgPathPainter(
              snapshot.data!,
              progress: progress,
              animationType: animationType,
              strokeWidth: strokeWidth, // 線の幅を指定
              strokeColor: strokeColor, // 線の色を指定
            ),
            // 外側でサイズ指定できるようにchildは空のContainerとする
            child: Container(),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error loading path: ${snapshot.error}'));
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Future<Path> _resolvePath(PathSourceType source) async {
    if (source is _PathSource) {
      return source.path;
    } else if (source is _AssetPathSource) {
      return convertSvgPathFromAsset(source.assetPath);
    }
    throw ArgumentError('Unsupported PathSourceType');
  }
}
