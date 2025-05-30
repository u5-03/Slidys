import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_slide/components/animated_svg_path_widget.dart';
import 'package:flutter_slide/utils/font_path_converter.dart';
import 'package:flutter_slide/utils/svg_path_converter.dart';
import 'package:flutter_slide/utils/svg_path_painter.dart';

final class SvgPathWidget extends HookWidget {
  final PathSourceType pathSource;
  final double? defaultProgress; // アニメーションの進捗率AnimationController
  final double strokeWidth; // 線の幅
  final Color strokeColor; // 線の色

  const SvgPathWidget({
    super.key,
    required this.pathSource,
    this.defaultProgress, // 外部から進捗率を指定する場合
    this.strokeWidth = 2.0, // デフォルトの線の幅
    this.strokeColor = Colors.white, // デフォルトの線の色
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Path>(
      future: _resolvePath(pathSource),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: CustomPaint(
              painter: SvgPathPainter(
                snapshot.data!,
                progress: defaultProgress ?? 1,
                animationType: const ProgressiveDraw(),
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
