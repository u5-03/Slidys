import 'dart:math' as math;

import 'package:flutter/material.dart';

final class RadialLayoutWidget extends StatelessWidget {
  RadialLayoutWidget({super.key});
  final List<Widget> children = List.generate(16, (index) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle, // 円形に変更
        color: Colors.accents[index % Colors.accents.length],
      ),
    );
  });

  @override
  Widget build(BuildContext context) {
    return CustomMultiChildLayout(
      delegate: RadialLayoutDelegate(count: children.length),
      children: [
        for (int i = 0; i < children.length; i++)
          LayoutId(id: 'child$i', child: children[i]),
      ],
    );
  }
}

final class RadialLayoutDelegate extends MultiChildLayoutDelegate {
  RadialLayoutDelegate({required this.count});
  final int count;

  @override
  void performLayout(Size size) {
    // 円の半径を計算
    final radius = math.min(size.width, size.height) / 2;

    // 各ウィジェットの間の角度を計算
    final angleIncrement = 2 * math.pi / count;

    for (var i = 0; i < count; i++) {
      // ウィジェットのサイズを計算
      if (hasChild('child$i')) {
        final childSize = layoutChild('child$i', BoxConstraints.loose(size));

        // ウィジェットの中心を計算
        final angle = angleIncrement * i - math.pi / 2;
        final xPos = math.cos(angle) * (radius - childSize.width / 2);
        final yPos = math.sin(angle) * (radius - childSize.height / 2);

        // 中心から計算された座標に配置
        positionChild(
          'child$i',
          Offset(
            size.width / 2 + xPos - childSize.width / 2,
            size.height / 2 + yPos - childSize.height / 2,
          ),
        );
      }
    }
  }

  @override
  bool shouldRelayout(RadialLayoutDelegate oldDelegate) {
    return count != oldDelegate.count;
  }
}
