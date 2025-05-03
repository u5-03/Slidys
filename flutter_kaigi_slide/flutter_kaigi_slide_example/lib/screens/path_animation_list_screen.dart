import 'package:flutter/material.dart';
import 'package:flutter_kaigi_slide/components/svg_path_widget.dart';
import 'package:flutter_kaigi_slide_example/gen/assets.gen.dart';

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
            'Path Animation List',
            style: TextStyle(fontSize: 32),
          ),
          const AspectRatio(
            aspectRatio: 1,
            child: AnimatedSvgPathWidget(
              assetPath: 'assets/images/icon.svg',
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
