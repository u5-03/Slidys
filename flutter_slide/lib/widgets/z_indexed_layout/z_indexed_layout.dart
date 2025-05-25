import 'package:flutter/material.dart';

@immutable
final class ZIndexedChild {
  const ZIndexedChild({required this.child, required this.zIndex});
  final Widget child;
  final int zIndex;
}

final class ZIndexedLayout extends StatelessWidget {
  const ZIndexedLayout({required this.children, super.key});
  final List<ZIndexedChild> children;

  @override
  Widget build(BuildContext context) {
    // Zインデックスに基づいてウィジェットをソート
    final sortedChildren = List<ZIndexedChild>.from(children)
      ..sort(
        (ZIndexedChild a, ZIndexedChild b) => a.zIndex.compareTo(b.zIndex),
      );

    return CustomMultiChildLayout(
      delegate: ZIndexedLayoutDelegate(sortedChildren),
      children: sortedChildren.map((zChild) {
        return LayoutId(id: zChild, child: zChild.child);
      }).toList(),
    );
  }
}

class ZIndexedLayoutDelegate extends MultiChildLayoutDelegate {
  ZIndexedLayoutDelegate(this.sortedChildren);
  final List<ZIndexedChild> sortedChildren;

  @override
  void performLayout(Size size) {
    for (final zChild in sortedChildren) {
      if (hasChild(zChild)) {
        layoutChild(zChild, BoxConstraints.loose(size));
        positionChild(zChild, const Offset(0, 0)); // 例として、すべて同じ位置に配置
      }
    }
  }

  @override
  bool shouldRelayout(ZIndexedLayoutDelegate oldDelegate) {
    return oldDelegate.sortedChildren != sortedChildren;
  }
}
