import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_slide/constants/constants.dart';
import 'package:flutter_slide/widgets/path_animation/path_content_move_animation_widget.dart';

final class IconMoveTabWidget extends HookWidget {
  const IconMoveTabWidget({super.key});

  static final _rootKey = GlobalKey();
  static final _tabKey = GlobalKey();
  static final _centerWidgetKey = GlobalKey();
  double get _padding => 80;

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
            Positioned(
              top: startState.value!.dy - 10 - _padding,
              left: startState.value!.dx - 10 - _padding,
              child: SizedBox(
                height: endState.value!.dy -
                    startState.value!.dy -
                    40 +
                    _padding * 2,
                width: endState.value!.dx -
                    startState.value!.dx +
                    20 +
                    _padding * 2,
                child: PathContentMoveAnimationWidget(
                  path: pathState.value!,
                  padding: EdgeInsets.fromLTRB(
                    _padding - 20,
                    _padding - 80,
                    _padding - 60,
                    _padding,
                  ),
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
          ],
        ],
      );
    });
  }
}
