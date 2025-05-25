import 'dart:math' as math;

import 'package:flutter/material.dart';

class CircleMusicNoteView extends StatefulWidget {
  const CircleMusicNoteView({
    required this.shouldRunAnimation,
    super.key,
  });

  final bool shouldRunAnimation;

  factory CircleMusicNoteView.demo() => const CircleMusicNoteView(shouldRunAnimation: false);

  factory CircleMusicNoteView.demoWithAnimation() => const CircleMusicNoteView(shouldRunAnimation: true);

  @override
  State<CircleMusicNoteView> createState() => _CircleMusicNoteViewState();
}

class _CircleMusicNoteViewState extends State<CircleMusicNoteView>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();
    if (widget.shouldRunAnimation) {
      final controller = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 10),
      )..repeat(); // アニメーションを繰り返す

      _animation = Tween<double>(begin: 0, end: 2 * math.pi).animate(controller);
      _controller = controller;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animation = _animation;
    return LayoutBuilder(
      builder: (context, constraints) {
      final radius = constraints.maxWidth * 0.38;
      final circleSize = radius / 3;
      final children = List
      .generate(
        16,
        (index) => Container(
          width: circleSize,
          height: circleSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                Colors.primaries[index % Colors.primaries.length],
          ),
        ),
      );
    if (animation == null) {
      return CustomMultiChildLayout(
        delegate: CircleLayoutDelegate(
          radius: radius,
          angle: 0,
          childCount: children.length,
        ),
        children: [
          for (int i = 0; i < children.length; i++)
            LayoutId(
              id: 'child$i',
              child: children[i],
            ),
        ],
      );
    }
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return CustomMultiChildLayout(
          delegate: CircleLayoutDelegate(
            radius: radius,
            angle: animation.value,
            childCount: children.length,
          ),
          children: [
            for (int i = 0; i < children.length; i++)
              LayoutId(
                id: 'child$i',
                child: children[i],
              ),
          ],
        );
      },
    );
  });
  }
}

class CircleLayoutDelegate extends MultiChildLayoutDelegate {
  CircleLayoutDelegate({
    required this.radius,
    required this.angle,
    required this.childCount,
  });
  final double radius;
  final double angle;
  final int childCount;

  @override
  void performLayout(Size size) {
    final angleIncrement = 2 * math.pi / childCount;

    for (var i = 0; i < childCount; i++) {
      final id = 'child$i';
      if (hasChild(id)) {
        final childSize = layoutChild(id, BoxConstraints.loose(size));

        // 円環状に各ウィジェットの位置を計算
        final childAngle = angleIncrement * i + angle;
        final xPos = math.cos(childAngle) * radius +
            size.width / 2 -
            childSize.width / 2;
        final yPos = math.sin(childAngle) * radius +
            size.height / 2 -
            childSize.height / 2;

        positionChild(id, Offset(xPos, yPos));
      }
    }
  }

  @override
  bool shouldRelayout(CircleLayoutDelegate oldDelegate) {
    return angle != oldDelegate.angle ||
        radius != oldDelegate.radius ||
        childCount != oldDelegate.childCount;
  }
}
