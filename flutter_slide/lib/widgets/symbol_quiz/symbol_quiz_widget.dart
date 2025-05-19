import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_slide/components/svg_path_widget.dart';

final class SymbolQuizWidget extends HookWidget {
  const SymbolQuizWidget({
    required this.pathSource,
    required this.animationType,
    this.duration = const Duration(seconds: 30),
    this.loop = true,
    this.strokeWidth = 3.0,
    this.strokeColor = Colors.white,
    super.key,
  });

  final PathSourceType pathSource;
  final PathAnimationType animationType;
  final Duration duration;
  final bool loop;
  final double strokeWidth;
  final Color strokeColor;

  @override
  Widget build(BuildContext context) {
    final animationController = useAnimationController(duration: duration);
    final isAnimatingState = useState(false);
    return Column(
      children: [
        Expanded(
          child: AnimatedSvgPathWidget(
            pathSource: pathSource,
            animationType: animationType,
            duration: duration,
            loop: loop,
            strokeWidth: strokeWidth,
            strokeColor: strokeColor,
            externalController: animationController,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isAnimatingState.value ||
                !animationController.isForwardOrCompleted)
              IconButton(
                icon: const Icon(Icons.play_arrow),
                onPressed: () {
                  isAnimatingState.value = true;
                  animationController.duration = duration;
                  animationController.forward();
                },
              )
            else
              IconButton(
                icon: const Icon(Icons.pause),
                onPressed: () {
                  isAnimatingState.value = false;
                  animationController.stop();
                },
              ),
            ElevatedButton(
              child: const Text('Show Answer'),
              onPressed: () async {
                animationController.stop();
                animationController.value = 0;
                animationController.duration = const Duration(seconds: 2);
                await animationController.forward();
              },
            ),
          ],
        ),
      ],
    );
  }
}
