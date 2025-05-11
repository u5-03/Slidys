import 'package:flutter/material.dart';
import 'package:flutter_slide/components/svg_path_widget.dart';
import 'package:flutter_slide/components/text_path_widget.dart';
import 'package:flutter_slide/utils/svg_path_painter.dart';
import 'package:flutter_slide_example/gen/assets.gen.dart';
import 'package:flutter_slide_example/gen/fonts.gen.dart';

final class PathAnimationListScreen extends StatelessWidget {
  const PathAnimationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Path Animation List'),
      ),
      body: ListView(
        children: [
          const Text(
            'Path Animation List SingleLineテスト',
            style: TextStyle(
              fontSize: 32,
              fontFamily: FontFamily.heftyRewardSingleLine,
              fontWeight: FontWeight.w900,
            ),
          ),
          AspectRatio(
            aspectRatio: 1,
            child: TextPathWidget(
              text: 'Path Animation List SingleLineテスト',
              fontFamily: FontFamily.heftyRewardSingleLine,
              animationType: PathAnimationType.progressiveDraw(),
            ),
          ),
          AspectRatio(
            aspectRatio: 1,
            child: AnimatedSvgPathWidget(
              assetPath: 'assets/images/icon.svg',
              animationType: PathAnimationType.progressiveDraw(),
            ),
          ),
          AspectRatio(
            aspectRatio: 1,
            child: AnimatedSvgPathWidget(
              assetPath: 'assets/images/icon.svg',
              animationType: PathAnimationType.fixedRatioMove(0.1),
            ),
          ),
          Assets.images.icon.svg(
            width: 200,
            height: 200,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}
