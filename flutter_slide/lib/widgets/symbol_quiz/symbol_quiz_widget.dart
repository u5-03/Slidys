import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_slide/components/animated_svg_path_widget.dart';

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
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 80),
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
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 40,
          children: [
            SizedBox.square(
              dimension: 120,
              child: Builder(
                builder: (context) {
                  if (!isAnimatingState.value ||
                      !animationController.isForwardOrCompleted) {
                    return IconButton(
                      icon: const Icon(
                        Icons.play_arrow,
                        size: 120,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        isAnimatingState.value = true;
                        animationController.duration = duration;
                        animationController.forward();
                      },
                    );
                  } else {
                    return IconButton(
                      icon: const Icon(
                        Icons.pause,
                        size: 120,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        isAnimatingState.value = false;
                        animationController.stop();
                      },
                    );
                  }
                },
              ),
            ),
            ElevatedButton(
              child: const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'Show Answer',
                  style: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
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
