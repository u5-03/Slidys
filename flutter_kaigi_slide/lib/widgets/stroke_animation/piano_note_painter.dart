import 'package:flutter/material.dart';

class PianoNotePainter extends CustomPainter {
  PianoNotePainter(this.animation) : super(repaint: animation);
  final Animation<double> animation;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path();

    path.moveTo(0.71638 * size.width, 0.60023 * size.height);
    path.cubicTo(
      0.71638 * size.width,
      0.50711 * size.height,
      0.6409 * size.width,
      0.43162 * size.height,
      0.54777 * size.width,
      0.43162 * size.height,
    );
    path.cubicTo(
      0.54393 * size.width,
      0.43162 * size.height,
      0.5402 * size.width,
      0.432 * size.height,
      0.53646 * size.width,
      0.43229 * size.height,
    );
    path.cubicTo(
      0.53287 * size.width,
      0.40382 * size.height,
      0.52939 * size.width,
      0.37614 * size.height,
      0.52614 * size.width,
      0.35003 * size.height,
    );
    path.cubicTo(
      0.56569 * size.width,
      0.32149 * size.height,
      0.60542 * size.width,
      0.29398 * size.height,
      0.63524 * size.width,
      0.2646 * size.height,
    );
    path.cubicTo(
      0.74184 * size.width,
      0.15961 * size.height,
      0.71108 * size.width,
      0 * size.height,
      0.58382 * size.width,
      0 * size.height,
    );
    path.cubicTo(
      0.45656 * size.width,
      0 * size.height,
      0.45391 * size.width,
      0.13893 * size.height,
      0.45867 * size.width,
      0.17551 * size.height,
    );
    path.cubicTo(
      0.46121 * size.width,
      0.19488 * size.height,
      0.46803 * size.width,
      0.25345 * size.height,
      0.47474 * size.width,
      0.3028 * size.height,
    );
    path.cubicTo(
      0.47212 * size.width,
      0.30482 * size.height,
      0.46988 * size.width,
      0.30647 * size.height,
      0.46823 * size.width,
      0.30755 * size.height,
    );
    path.cubicTo(
      0.35837 * size.width,
      0.37933 * size.height,
      0.28051 * size.width,
      0.46661 * size.height,
      0.28371 * size.width,
      0.5891 * size.height,
    );
    path.cubicTo(
      0.28631 * size.width,
      0.6901 * size.height,
      0.38232 * size.width,
      0.78795 * size.height,
      0.50958 * size.width,
      0.78795 * size.height,
    );
    path.cubicTo(
      0.51933 * size.width,
      0.78821 * size.height,
      0.52884 * size.width,
      0.78751 * size.height,
      0.53823 * size.width,
      0.78637 * size.height,
    );
    path.cubicTo(
      0.53943 * size.width,
      0.79569 * size.height,
      0.54051 * size.width,
      0.80382 * size.height,
      0.5414 * size.width,
      0.81022 * size.height,
    );
    path.cubicTo(
      0.55253 * size.width,
      0.88975 * size.height,
      0.5239 * size.width,
      0.94066 * size.height,
      0.48732 * size.width,
      0.95179 * size.height,
    );
    path.cubicTo(
      0.45072 * size.width,
      0.96293 * size.height,
      0.41732 * size.width,
      0.9502 * size.height,
      0.41097 * size.width,
      0.93748 * size.height,
    );
    path.cubicTo(
      0.40459 * size.width,
      0.92474 * size.height,
      0.41891 * size.width,
      0.92791 * size.height,
      0.438 * size.width,
      0.92315 * size.height,
    );
    path.cubicTo(
      0.45709 * size.width,
      0.91839 * size.height,
      0.46982 * size.width,
      0.88816 * size.height,
      0.4714 * size.width,
      0.87224 * size.height,
    );
    path.cubicTo(
      0.4755 * size.width,
      0.83116 * size.height,
      0.43794 * size.width,
      0.79748 * size.height,
      0.39664 * size.width,
      0.79748 * size.height,
    );
    path.cubicTo(
      0.35534 * size.width,
      0.79748 * size.height,
      0.32699 * size.width,
      0.83128 * size.height,
      0.32187 * size.width,
      0.87224 * size.height,
    );
    path.cubicTo(
      0.3187 * size.width,
      0.8977 * size.height,
      0.32505 * size.width,
      0.91839 * size.height,
      0.33619 * size.width,
      0.93748 * size.height,
    );
    path.cubicTo(
      0.368 * size.width,
      0.98361 * size.height,
      0.4205 * size.width,
      1.00747 * size.height,
      0.47936 * size.width,
      0.99791 * size.height,
    );
    path.cubicTo(
      0.55223 * size.width,
      0.98609 * size.height,
      0.59396 * size.width,
      0.92344 * size.height,
      0.58751 * size.width,
      0.84839 * size.height,
    );
    path.cubicTo(
      0.5864 * size.width,
      0.83537 * size.height,
      0.58354 * size.width,
      0.81003 * size.height,
      0.57957 * size.width,
      0.77682 * size.height,
    );
    path.cubicTo(
      0.65943 * size.width,
      0.74906 * size.height,
      0.71638 * size.width,
      0.67334 * size.height,
      0.71638 * size.width,
      0.60023 * size.height,
    );
    path.close();

    path.moveTo(0.50639 * size.width, 0.18347 * size.height);
    path.cubicTo(
      0.49686 * size.width,
      0.08483 * size.height,
      0.5626 * size.width,
      0.03235 * size.height,
      0.60715 * size.width,
      0.0594 * size.height,
    );
    path.cubicTo(
      0.67053 * size.width,
      0.09788 * size.height,
      0.57897 * size.width,
      0.20579 * size.height,
      0.51584 * size.width,
      0.26645 * size.height,
    );
    path.cubicTo(
      0.51143 * size.width,
      0.22982 * size.height,
      0.50806 * size.width,
      0.20063 * size.height,
      0.50639 * size.width,
      0.18347 * size.height,
    );
    path.close();

    path.moveTo(0.43004 * size.width, 0.73543 * size.height);
    path.cubicTo(
      0.35051 * size.width,
      0.6925 * size.height,
      0.34256 * size.width,
      0.56842 * size.height,
      0.39028 * size.width,
      0.48091 * size.height,
    );
    path.cubicTo(
      0.41122 * size.width,
      0.44254 * size.height,
      0.4473 * size.width,
      0.40962 * size.height,
      0.4872 * size.width,
      0.37886 * size.height,
    );
    path.cubicTo(
      0.48931 * size.width,
      0.39105 * size.height,
      0.49239 * size.width,
      0.41317 * size.height,
      0.49605 * size.width,
      0.44148 * size.height,
    );
    path.cubicTo(
      0.43165 * size.width,
      0.46681 * size.height,
      0.39209 * size.width,
      0.53723 * size.height,
      0.41062 * size.width,
      0.60401 * size.height,
    );
    path.cubicTo(
      0.42576 * size.width,
      0.65854 * size.height,
      0.47781 * size.width,
      0.66913 * size.height,
      0.4879 * size.width,
      0.65624 * size.height,
    );
    path.cubicTo(
      0.49373 * size.width,
      0.64879 * size.height,
      0.4731 * size.width,
      0.64401 * size.height,
      0.46029 * size.width,
      0.6056 * size.height,
    );
    path.cubicTo(
      0.45109 * size.width,
      0.578 * size.height,
      0.45391 * size.width,
      0.54615 * size.height,
      0.47936 * size.width,
      0.52549 * size.height,
    );
    path.cubicTo(
      0.48717 * size.width,
      0.51913 * size.height,
      0.49572 * size.width,
      0.51408 * size.height,
      0.50469 * size.width,
      0.51027 * size.height,
    );
    path.cubicTo(
      0.5145 * size.width,
      0.59014 * size.height,
      0.52583 * size.width,
      0.68654 * size.height,
      0.53392 * size.width,
      0.75203 * size.height,
    );
    path.cubicTo(
      0.50165 * size.width,
      0.75752 * size.height,
      0.46508 * size.width,
      0.75436 * size.height,
      0.43004 * size.width,
      0.73543 * size.height,
    );
    path.close();

    path.moveTo(0.62412 * size.width, 0.70363 * size.height);
    path.cubicTo(
      0.61446 * size.width,
      0.71668 * size.height,
      0.59701 * size.width,
      0.72988 * size.height,
      0.57508 * size.width,
      0.7396 * size.height,
    );
    path.cubicTo(
      0.56697 * size.width,
      0.67344 * size.height,
      0.55609 * size.width,
      0.58754 * size.height,
      0.5453 * size.width,
      0.50229 * size.height,
    );
    path.cubicTo(
      0.5678 * size.width,
      0.50262 * size.height,
      0.5912 * size.width,
      0.51044 * size.height,
      0.61299 * size.width,
      0.52706 * size.height,
    );
    path.cubicTo(
      0.67344 * size.width,
      0.57318 * size.height,
      0.65116 * size.width,
      0.66704 * size.height,
      0.62412 * size.width,
      0.70363 * size.height,
    );
    path.close();

    // canvas.drawPath(path, paint);

    // Pathを並列に表示する
    final pathMetrics = path.computeMetrics();
    for (final pathMetric in pathMetrics) {
      final extractPath =
          pathMetric.extractPath(0, pathMetric.length * animation.value);
      canvas.drawPath(extractPath, paint);
    }

    // final PathMetrics pathMetrics = path.computeMetrics();
    // double progress = animation.value * pathMetrics.length;

    // print(pathMetrics.length);
    // for (final PathMetric pathMetric in pathMetrics) {
    //   print(pathMetric.length);
    //   if (progress > pathMetric.length) {
    //     canvas.drawPath(
    //         pathMetric.extractPath(0.0, pathMetric.length * animation.value),
    //         paint);
    //     progress -= pathMetric.length;
    //   } else {
    //     canvas.drawPath(
    //         pathMetric.extractPath(0.0, pathMetric.length * animation.value),
    //         paint);
    //     break;
    //   }
    // }
    // print('progress: $progress');
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
    return oldDelegate is PianoNotePainter &&
        oldDelegate.animation.value != animation.value;
  }
}
