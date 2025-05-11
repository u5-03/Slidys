import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_drawing/path_drawing.dart';
import 'package:xml/xml.dart';

/// SVGファイルから全ての<path>要素のd属性を抽出し、
/// それらを1つのPathに統合して返す関数
Future<Path> convertSvgPathFromAsset(String assetPath) async {
  final svgString = await rootBundle.loadString(assetPath);
  final document = XmlDocument.parse(svgString);
  final pathElements = document.findAllElements('path');
  final combined = Path();

  for (final element in pathElements) {
    final dAttribute = element.getAttribute('d');
    if (dAttribute != null && dAttribute.isNotEmpty) {
      final path = parseSvgPathData(dAttribute);
      combined.addPath(path, Offset.zero);
    }
  }
  return combined;
}
