import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_slide/constants/constants.dart';
import 'package:flutter_slide/widgets/path_animation/path_content_move_animation_widget.dart';

final class IconMoveTabWidget extends HookWidget {
  const IconMoveTabWidget({super.key});

  static final _rootKey = GlobalKey();
  static final _tabKey = GlobalKey();
  static final _centerWidgetKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final currentIndex = useState(1);
    final pathState = useState<Path?>(null);
    final startState = useState<Offset?>(null);
    final endState = useState<Offset?>(null);
    final animationController = useAnimationController(
      duration: const Duration(seconds: 2),
    )..repeat();

    void updatePositions() {
      final RenderBox? centerBox =
          _centerWidgetKey.currentContext?.findRenderObject() as RenderBox?;
      final RenderBox? tabBox =
          _tabKey.currentContext?.findRenderObject() as RenderBox?;
      final rootBox = _rootKey.currentContext?.findRenderObject() as RenderBox?;
      final RenderBox? stackBox = context.findRenderObject() as RenderBox?;
      if (centerBox != null &&
          tabBox != null &&
          stackBox != null &&
          rootBox != null) {
        final centerPos =
            centerBox.localToGlobal(Offset.zero, ancestor: stackBox);
        final Size centerSize = centerBox.size;
        final centerCenter =
            centerPos + Offset(centerSize.width / 2, centerSize.height / 2);
        final tabPos = tabBox.localToGlobal(Offset.zero);
        final tabSize = tabBox.size;
        final tabCenter =
            tabPos + Offset(tabSize.width / 2, tabSize.height / 2);
        startState.value = centerCenter;
        endState.value = tabCenter;
        // final centerPoint = rootBox.globalToLocal(centerCenter);
        pathState.value = Path()
          ..moveTo(centerCenter.dx, centerCenter.dy)
          ..quadraticBezierTo(tabCenter.dx * 1.1, centerCenter.dy * 0.9,
              tabCenter.dx, tabCenter.dy);
      }
    }

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        updatePositions();
      });
      return null;
    }, const []);

    return LayoutBuilder(builder: (context, constraints) {
      return Stack(
        key: _rootKey,
        fit: StackFit.expand,
        children: [
          Scaffold(
            appBar: AppBar(
              title: const Text('Icon Move Tab Sample'),
            ),
            body: Stack(
              children: [
                // 中央のWidget
                Center(
                  child: Container(
                    key: _centerWidgetKey,
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.star, color: Colors.white, size: 36),
                  ),
                ),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: currentIndex.value,
              onTap: (index) {
                currentIndex.value = index;
              },
              items: [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.directions_car),
                  label: 'Car',
                ),
                BottomNavigationBarItem(
                  key: _tabKey,
                  icon: const Icon(Icons.directions_bike),
                  label: 'Bike',
                ),
              ],
            ),
          ),
          if (pathState.value != null &&
              startState.value != null &&
              endState.value != null) ...[
            IgnorePointer(
                child: CustomPaint(
              painter: MyPainter(
                pathState.value!,
              ),
              child: const SizedBox.expand(),
            )),
            Positioned(
              top: startState.value!.dy - 10,
              left: startState.value!.dx - 10,
              child: SizedBox(
                height: endState.value!.dy - startState.value!.dy + 20,
                width: endState.value!.dx - startState.value!.dx + 20,
                child: ColoredBox(
                  color: Colors.blue.withValues(alpha: 0.2),
                  child: PathContentMoveAnimationWidget(
                    path: pathState.value!,
                    externalController: animationController,
                    content: Image.asset(
                      'assets/images/icon.png',
                      width: 100,
                      height: 100,
                      package: packageName,
                    ),
                  ),
                ),
              ),
            ),
          ],
          // Path描画
          if (startState.value != null && endState.value != null) ...[
            // startのPointに⚪︎
            Positioned(
              left: startState.value!.dx - 12,
              top: startState.value!.dy - 12,
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // endのPointに⚪︎
            Positioned(
              left: endState.value!.dx - 12,
              top: endState.value!.dy - 12,
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ],
      );
    });
  }
}

class MyPainter extends CustomPainter {
  final Path path;

  MyPainter(this.path);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant MyPainter oldDelegate) =>
      oldDelegate.path != path;
}
