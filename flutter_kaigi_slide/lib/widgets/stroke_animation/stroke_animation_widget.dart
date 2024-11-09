import 'package:flutter/material.dart';
import 'package:flutter_kaigi_slide/widgets/stroke_animation/piano_note_painter.dart';


class StrokeAnimationWidget extends StatefulWidget {
  @override
  _StrokeAnimationWidgetState createState() => _StrokeAnimationWidgetState();
}

class _StrokeAnimationWidgetState extends State<StrokeAnimationWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 10),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(100, 100),// 描画領域のサイズを指定
          painter: PianoNotePainter(_controller),
        );
      },
    );
    return CustomPaint(
      size: Size(100, 100),  // 描画領域のサイズを指定
      painter: PianoNotePainter(_controller),
    );
  }
}
