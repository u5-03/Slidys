import 'dart:math';

extension IntExt on int {
  static int randomMax({required int max}) {
    final random = Random();
    return random.nextInt(max + 1);
  }

  static int random({required int digit}) {
    if (digit <= 0) return 0;

    // 最小値と最大値を計算
    final min = pow(10, digit - 1).toInt();
    final max = pow(10, digit).toInt() - 1;

    // 乱数生成器
    final rng = Random();

    // 指定された範囲内で乱数を生成
    return min + rng.nextInt(max - min + 1);
  }

  static int randomRange({required int min, required int max}) {
    final random = Random();
    return min + random.nextInt(max - min + 1);
  }
}
