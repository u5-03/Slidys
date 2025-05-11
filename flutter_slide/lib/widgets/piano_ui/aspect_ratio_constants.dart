import 'dart:ui';

class AspectRatioConstants {
  static const Size whiteKeyAspectRatioSize = Size(22, 150);
  static double get whiteKeyAspectRatio =>
      whiteKeyAspectRatioSize.width / whiteKeyAspectRatioSize.height;
  static const Size blackKeyAspectRatioSize = Size(14, 100);
  static double get blackKeyAspectRatio =>
      blackKeyAspectRatioSize.width / blackKeyAspectRatioSize.height;
  static const Size octaveAspectRatio = Size(165, 150);
}
