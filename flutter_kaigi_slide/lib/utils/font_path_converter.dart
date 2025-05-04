import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' show Path, Size, Offset, Rect;

import 'package:flutter/services.dart' show rootBundle;
import 'package:text_to_path_maker/text_to_path_maker.dart';

/// テキスト＋フォントから Path を生成するユーティリティ
final class TextPathConverter {
  TextPathConverter._();

  /// [text]           : 変換したい文字列
  /// [fontAssetPath]  : 'lib/assets/fonts/HeftyRewardSingleLine-JRqWx.ttf'
  /// [fontSize]       : 文字高さのおおよその px
  /// [targetSize]     : この領域内にフィットさせる
  /// [letterSpacing]  : 文字間スペース (px)
  static Future<Path> generatePath(
    String text,
    String fontAssetPath,
    double fontSize,
    Size targetSize, {
    double letterSpacing = 4,
  }) async {
    // 1) フォントアセットを ByteData として読み込み → PMFont をパース
    final byteData = await rootBundle.load(fontAssetPath);
    final pmFont = PMFontReader()
        .parseTTFAsset(byteData); // :contentReference[oaicite:0]{index=0}

    // 2) 各グリフの内部-unit Path を取得し、一度に union して高さを測る
    Rect? rawUnitsBounds;
    final glyphUnitsPaths = <Path>[];
    for (final code in text.runes) {
      final glyph = pmFont.generatePathForCharacter(code);
      glyphUnitsPaths.add(glyph);
      final b = glyph.getBounds();
      rawUnitsBounds =
          (rawUnitsBounds == null) ? b : rawUnitsBounds.expandToInclude(b);
    }
    rawUnitsBounds ??= const Rect.fromLTWH(0, 0, 0, 1); // 安全策
    final unitToPx = fontSize / rawUnitsBounds.height;

    // 3) 「内部単位 → px ＋ Y反転＋baseline 補正」をまとめた行列
    //    (y 軸反転のため、第1行と第5行でマイナス、6行目で baseline を持ち上げ)
    final invertMatrix = Float64List.fromList([
      unitToPx,
      0,
      0,
      0,
      0,
      -unitToPx,
      0,
      0,
      0,
      0,
      1,
      0,
      0,
      (rawUnitsBounds.top + rawUnitsBounds.height) * unitToPx,
      0,
      1,
    ]);

    // 4) 各グリフを px 空間に変換 → 個別にリスト化
    final glyphPxPaths =
        glyphUnitsPaths.map((p) => p.transform(invertMatrix)).toList();

    // 5) px 単位で文字を横に積み重ね (letterSpacing も px 単位なのでそのまま足す)
    final combinedPx = Path();
    double xOffsetPx = 0;
    for (final charPath in glyphPxPaths) {
      combinedPx.addPath(charPath, Offset(xOffsetPx, 0));
      final wb = charPath.getBounds().width;
      xOffsetPx += wb + letterSpacing;
    }

    // 6) 最後に「targetSize にフィット ＋ 中央寄せ」の変換行列をかける
    final b2 = combinedPx.getBounds();
    final fitScale = math.min(
      targetSize.width / b2.width,
      targetSize.height / b2.height,
    );
    final dx =
        (targetSize.width - b2.width * fitScale) / 2 - b2.left * fitScale;
    final dy =
        (targetSize.height - b2.height * fitScale) / 2 - b2.top * fitScale;
    final fitMatrix = Float64List.fromList([
      fitScale,
      0,
      0,
      0,
      0,
      fitScale,
      0,
      0,
      0,
      0,
      1,
      0,
      dx,
      dy,
      0,
      1,
    ]);

    return combinedPx.transform(fitMatrix);
  }
}
