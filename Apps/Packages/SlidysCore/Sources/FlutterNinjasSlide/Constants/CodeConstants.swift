//
//  CodeConstants.swift
//  Slidys
//
//  Created by Yugo Sugiyama on 2024/11/06.
//

enum CodeConstants {
    static let fixedLengthAnimationCode = """
for (final pathMetric in pathMetrics) {
  if (currentLength + pathMetric.length < startLength) {
    currentLength += pathMetric.length;
    continue;
  }
  final localStart = math.max(0.0, startLength - currentLength);
  final localEnd = math.min(pathMetric.length, endLength - currentLength);
  if (localStart < localEnd) {
    trimmedPath.addPath(
        pathMetric.extractPath(localStart, localEnd), Offset.zero);
  }
  currentLength += pathMetric.length;
  if (currentLength >= endLength) break;
}
"""


    static let iconPathStringCode = """
      Path path = Path();  
      path.lineTo(size.width * 0.05, size.height * 0.57);
      path.cubicTo(size.width * 0.05, size.height * 0.57, size.width * 0.03, size.height * 0.68, size.width * 0.03, size.height * 0.68);
      path.cubicTo(size.width * 0.03, size.height * 0.68, size.width * 0.02, size.height * 0.69, size.width * 0.02, size.height * 0.69);
      path.cubicTo(size.width * 0.02, size.height * 0.69, size.width * 0.02, size.height * 0.69, size.width * 0.02, size.height * 0.69);
      path.cubicTo(size.width * 0.02, size.height * 0.69, size.width * 0.02, size.height * 0.69, size.width * 0.02, size.height * 0.69);
      path.cubicTo(size.width * 0.02, size.height * 0.69, size.width * 0.02, size.height * 0.69, size.width * 0.02, size.height * 0.69);
      path.cubicTo(size.width * 0.02, size.height * 0.69, size.width * 0.02, size.height * 0.69, size.width * 0.02, size.height * 0.69);
      path.cubicTo(size.width * 0.02, size.height * 0.69, size.width * 0.01, size.height * 0.69, size.width * 0.01, size.height * 0.69);
      path.cubicTo(size.width * 0.01, size.height * 0.69, size.width * 0.01, size.height * 0.69, size.width * 0.01, size.height * 0.69);
      path.cubicTo(size.width * 0.01, size.height * 0.69, size.width * 0.01, size.height * 0.69, size.width * 0.01, size.height * 0.69);
      path.cubicTo(size.width * 0.01, size.height * 0.69, size.width * 0.01, size.height * 0.7, size.width * 0.01, size.height * 0.7);
      path.cubicTo(size.width * 0.01, size.height * 0.7, 0, size.height * 0.71, 0, size.height * 0.71);
      path.cubicTo(0, size.height * 0.71, 0, size.height * 0.72, 0, size.height * 0.72);
      path.cubicTo(0, size.height * 0.72, 0, size.height * 0.73, 0, size.height * 0.73);
      path.cubicTo(0, size.height * 0.73, size.width * 0.01, size.height * 0.74, size.width * 0.01, size.height * 0.74);
      path.cubicTo(size.width * 0.01, size.height * 0.74, size.width * 0.01, size.height * 0.75, size.width * 0.01, size.height * 0.75);
      path.cubicTo(size.width * 0.01, size.height * 0.75, size.width * 0.01, size.height * 0.76, size.width * 0.01, size.height * 0.76);
      path.cubicTo(size.width * 0.01, size.height * 0.76, size.width * 0.02, size.height * 0.76, size.width * 0.02, size.height * 0.76);
      path.cubicTo(size.width * 0.02, size.height * 0.76, size.width * 0.02, size.height * 0.77, size.width * 0.02, size.height * 0.77);
      path.cubicTo(size.width * 0.02, size.height * 0.77, size.width * 0.03, size.height * 0.78, size.width * 0.03, size.height * 0.78);
      path.cubicTo(size.width * 0.03, size.height * 0.78, size.width * 0.04, size.height * 0.79, size.width * 0.04, size.height * 0.79);
      path.cubicTo(size.width * 0.04, size.height * 0.79, size.width * 0.06, size.height * 0.8, size.width * 0.06, size.height * 0.8);
      path.cubicTo(size.width * 0.06, size.height * 0.8, size.width * 0.07, size.height * 0.82, size.width * 0.07, size.height * 0.82);
      path.cubicTo(size.width * 0.07, size.height * 0.82, size.width * 0.09, size.height * 0.83, size.width * 0.09, size.height * 0.83);
      path.cubicTo(size.width * 0.09, size.height * 0.83, size.width * 0.1, size.height * 0.84, size.width * 0.1, size.height * 0.84);
      path.cubicTo(size.width * 0.1, size.height * 0.84, size.width * 0.12, size.height * 0.86, size.width * 0.12, size.height * 0.86);
      path.cubicTo(size.width * 0.12, size.height * 0.86, size.width * 0.14, size.height * 0.88, size.width * 0.14, size.height * 0.88);
      path.cubicTo(size.width * 0.14, size.height * 0.88, size.width * 0.15, size.height * 0.89, size.width * 0.15, size.height * 0.89);
      path.cubicTo(size.width * 0.15, size.height * 0.89, size.width * 0.17, size.height * 0.9, size.width * 0.17, size.height * 0.9);
      path.cubicTo(size.width * 0.17, size.height * 0.9, size.width * 0.18, size.height * 0.91, size.width * 0.18, size.height * 0.91);
      path.cubicTo(size.width * 0.18, size.height * 0.91, size.width / 5, size.height * 0.92, size.width / 5, size.height * 0.92);
      path.cubicTo(size.width / 5, size.height * 0.92, size.width * 0.22, size.height * 0.93, size.width * 0.22, size.height * 0.93);
      path.cubicTo(size.width * 0.22, size.height * 0.93, size.width * 0.24, size.height * 0.94, size.width * 0.24, size.height * 0.94);
      path.cubicTo(size.width * 0.24, size.height * 0.94, size.width * 0.26, size.height * 0.94, size.width * 0.26, size.height * 0.94);
      path.cubicTo(size.width * 0.26, size.height * 0.94, size.width * 0.28, size.height * 0.94, size.width * 0.28, size.height * 0.94);
      path.cubicTo(size.width * 0.28, size.height * 0.94, size.width * 0.31, size.height * 0.94, size.width * 0.31, size.height * 0.94);
      path.cubicTo(size.width * 0.31, size.height * 0.94, size.width / 3, size.height * 0.95, size.width / 3, size.height * 0.95);
      path.cubicTo(size.width / 3, size.height * 0.95, size.width * 0.34, size.height * 0.95, size.width * 0.34, size.height * 0.95);
      path.cubicTo(size.width * 0.34, size.height * 0.95, size.width * 0.35, size.height * 0.95, size.width * 0.35, size.height * 0.95);
      path.cubicTo(size.width * 0.35, size.height * 0.95, size.width * 0.37, size.height * 0.95, size.width * 0.37, size.height * 0.95);
      path.cubicTo(size.width * 0.37, size.height * 0.95, size.width * 0.39, size.height * 0.95, size.width * 0.39, size.height * 0.95);
      path.cubicTo(size.width * 0.39, size.height * 0.95, size.width * 0.4, size.height * 0.95, size.width * 0.4, size.height * 0.95);
      path.cubicTo(size.width * 0.4, size.height * 0.95, size.width * 0.43, size.height * 0.94, size.width * 0.43, size.height * 0.94);
      path.cubicTo(size.width * 0.43, size.height * 0.94, size.width * 0.44, size.height * 0.94, size.width * 0.44, size.height * 0.94);
      path.cubicTo(size.width * 0.44, size.height * 0.94, size.width * 0.45, size.height * 0.94, size.width * 0.45, size.height * 0.94);
      path.cubicTo(size.width * 0.45, size.height * 0.94, size.width * 0.46, size.height * 0.94, size.width * 0.46, size.height * 0.94);
      path.cubicTo(size.width * 0.46, size.height * 0.94, size.width * 0.47, size.height * 0.93, size.width * 0.47, size.height * 0.93);
      path.cubicTo(size.width * 0.47, size.height * 0.93, size.width * 0.48, size.height * 0.93, size.width * 0.48, size.height * 0.93);
      path.cubicTo(size.width * 0.48, size.height * 0.93, size.width * 0.49, size.height * 0.93, size.width * 0.49, size.height * 0.93);
      path.cubicTo(size.width * 0.49, size.height * 0.93, size.width * 0.49, size.height * 0.92, size.width * 0.49, size.height * 0.92);
      path.cubicTo(size.width * 0.49, size.height * 0.92, size.width * 0.49, size.height * 0.92, size.width * 0.49, size.height * 0.92);
      path.cubicTo(size.width * 0.49, size.height * 0.92, size.width / 2, size.height * 0.93, size.width / 2, size.height * 0.93);
      path.cubicTo(size.width / 2, size.height * 0.93, size.width / 2, size.height * 0.94, size.width / 2, size.height * 0.94);
      path.cubicTo(size.width / 2, size.height * 0.94, size.width / 2, size.height * 0.94, size.width / 2, size.height * 0.94);
      path.cubicTo(size.width / 2, size.height * 0.94, size.width * 0.51, size.height * 0.95, size.width * 0.51, size.height * 0.95);
      path.cubicTo(size.width * 0.51, size.height * 0.95, size.width * 0.51, size.height * 0.96, size.width * 0.51, size.height * 0.96);
      path.cubicTo(size.width * 0.51, size.height * 0.96, size.width * 0.52, size.height * 0.96, size.width * 0.52, size.height * 0.96);
      path.cubicTo(size.width * 0.52, size.height * 0.96, size.width * 0.52, size.height * 0.97, size.width * 0.52, size.height * 0.97);
      path.cubicTo(size.width * 0.52, size.height * 0.97, size.width * 0.52, size.height * 0.97, size.width * 0.52, size.height * 0.97);
      path.cubicTo(size.width * 0.52, size.height * 0.97, size.width * 0.53, size.height * 0.98, size.width * 0.53, size.height * 0.98);
      path.cubicTo(size.width * 0.53, size.height * 0.98, size.width * 0.53, size.height, size.width * 0.53, size.height);
      path.cubicTo(size.width * 0.53, size.height, size.width * 0.54, size.height, size.width * 0.54, size.height);
      path.cubicTo(size.width * 0.54, size.height, size.width * 0.55, size.height, size.width * 0.55, size.height);
      path.cubicTo(size.width * 0.55, size.height, size.width * 0.55, size.height, size.width * 0.55, size.height);
      path.cubicTo(size.width * 0.55, size.height, size.width * 0.55, size.height, size.width * 0.55, size.height);
      path.cubicTo(size.width * 0.55, size.height, size.width * 0.57, size.height, size.width * 0.57, size.height);
      path.cubicTo(size.width * 0.57, size.height, size.width * 0.59, size.height, size.width * 0.59, size.height);
      path.cubicTo(size.width * 0.59, size.height, size.width * 0.59, size.height, size.width * 0.59, size.height);
      path.cubicTo(size.width * 0.59, size.height, size.width * 0.61, size.height * 0.98, size.width * 0.61, size.height * 0.98);
      path.cubicTo(size.width * 0.61, size.height * 0.98, size.width * 0.63, size.height * 0.97, size.width * 0.63, size.height * 0.97);
      path.cubicTo(size.width * 0.63, size.height * 0.97, size.width * 0.64, size.height * 0.96, size.width * 0.64, size.height * 0.96);
      path.cubicTo(size.width * 0.64, size.height * 0.96, size.width * 0.65, size.height * 0.95, size.width * 0.65, size.height * 0.95);
      path.cubicTo(size.width * 0.65, size.height * 0.95, size.width * 0.66, size.height * 0.94, size.width * 0.66, size.height * 0.94);
      path.cubicTo(size.width * 0.66, size.height * 0.94, size.width * 0.67, size.height * 0.93, size.width * 0.67, size.height * 0.93);
      path.cubicTo(size.width * 0.67, size.height * 0.93, size.width * 0.68, size.height * 0.92, size.width * 0.68, size.height * 0.92);
      path.cubicTo(size.width * 0.68, size.height * 0.92, size.width * 0.69, size.height * 0.91, size.width * 0.69, size.height * 0.91);
      path.cubicTo(size.width * 0.69, size.height * 0.91, size.width * 0.69, size.height * 0.9, size.width * 0.69, size.height * 0.9);
      path.cubicTo(size.width * 0.69, size.height * 0.9, size.width * 0.7, size.height * 0.89, size.width * 0.7, size.height * 0.89);
      path.cubicTo(size.width * 0.7, size.height * 0.89, size.width * 0.71, size.height * 0.89, size.width * 0.71, size.height * 0.89);
      path.cubicTo(size.width * 0.71, size.height * 0.89, size.width * 0.72, size.height * 0.88, size.width * 0.72, size.height * 0.88);
      path.cubicTo(size.width * 0.72, size.height * 0.88, size.width * 0.73, size.height * 0.88, size.width * 0.73, size.height * 0.88);
      path.cubicTo(size.width * 0.73, size.height * 0.88, size.width * 0.74, size.height * 0.89, size.width * 0.74, size.height * 0.89);
      path.cubicTo(size.width * 0.74, size.height * 0.89, size.width * 0.74, size.height * 0.9, size.width * 0.74, size.height * 0.9);
      path.cubicTo(size.width * 0.74, size.height * 0.9, size.width * 0.75, size.height * 0.9, size.width * 0.75, size.height * 0.9);
      path.cubicTo(size.width * 0.75, size.height * 0.9, size.width * 0.76, size.height * 0.91, size.width * 0.76, size.height * 0.91);
      path.cubicTo(size.width * 0.76, size.height * 0.91, size.width * 0.77, size.height * 0.91, size.width * 0.77, size.height * 0.91);
      path.cubicTo(size.width * 0.77, size.height * 0.91, size.width * 0.8, size.height * 0.92, size.width * 0.8, size.height * 0.92);
      path.cubicTo(size.width * 0.8, size.height * 0.92, size.width * 0.84, size.height * 0.93, size.width * 0.84, size.height * 0.93);
      path.cubicTo(size.width * 0.84, size.height * 0.93, size.width * 0.87, size.height * 0.93, size.width * 0.87, size.height * 0.93);
      path.cubicTo(size.width * 0.87, size.height * 0.93, size.width * 0.89, size.height * 0.93, size.width * 0.89, size.height * 0.93);
      path.cubicTo(size.width * 0.89, size.height * 0.93, size.width * 0.91, size.height * 0.93, size.width * 0.91, size.height * 0.93);
      path.cubicTo(size.width * 0.91, size.height * 0.93, size.width * 0.93, size.height * 0.93, size.width * 0.93, size.height * 0.93);
      path.cubicTo(size.width * 0.93, size.height * 0.93, size.width * 0.94, size.height * 0.93, size.width * 0.94, size.height * 0.93);
      path.cubicTo(size.width * 0.94, size.height * 0.93, size.width * 0.95, size.height * 0.93, size.width * 0.95, size.height * 0.93);
      path.cubicTo(size.width * 0.95, size.height * 0.93, size.width * 0.95, size.height * 0.92, size.width * 0.95, size.height * 0.92);
      path.cubicTo(size.width * 0.95, size.height * 0.92, size.width * 0.96, size.height * 0.92, size.width * 0.96, size.height * 0.92);
      path.cubicTo(size.width * 0.96, size.height * 0.92, size.width * 0.96, size.height * 0.91, size.width * 0.96, size.height * 0.91);
      path.cubicTo(size.width * 0.96, size.height * 0.91, size.width * 0.97, size.height * 0.9, size.width * 0.97, size.height * 0.9);
      path.cubicTo(size.width * 0.97, size.height * 0.9, size.width * 0.97, size.height * 0.89, size.width * 0.97, size.height * 0.89);
      path.cubicTo(size.width * 0.97, size.height * 0.89, size.width * 0.98, size.height * 0.88, size.width * 0.98, size.height * 0.88);
      path.cubicTo(size.width * 0.98, size.height * 0.88, size.width * 0.98, size.height * 0.87, size.width * 0.98, size.height * 0.87);
      path.cubicTo(size.width * 0.98, size.height * 0.87, size.width * 0.98, size.height * 0.85, size.width * 0.98, size.height * 0.85);
      path.cubicTo(size.width * 0.98, size.height * 0.85, size.width, size.height * 0.84, size.width, size.height * 0.84);
      path.cubicTo(size.width, size.height * 0.84, size.width, size.height * 0.83, size.width, size.height * 0.83);
      path.cubicTo(size.width, size.height * 0.83, size.width, size.height * 0.83, size.width, size.height * 0.83);
      path.cubicTo(size.width, size.height * 0.83, size.width, size.height * 0.81, size.width, size.height * 0.81);
      path.cubicTo(size.width, size.height * 0.81, size.width, size.height * 0.8, size.width, size.height * 0.8);
      path.cubicTo(size.width, size.height * 0.8, size.width * 0.98, size.height * 0.78, size.width * 0.98, size.height * 0.78);
      path.cubicTo(size.width * 0.98, size.height * 0.78, size.width * 0.98, size.height * 0.77, size.width * 0.98, size.height * 0.77);
      path.cubicTo(size.width * 0.98, size.height * 0.77, size.width * 0.98, size.height * 0.75, size.width * 0.98, size.height * 0.75);
      path.cubicTo(size.width * 0.98, size.height * 0.75, size.width * 0.98, size.height * 0.73, size.width * 0.98, size.height * 0.73);
      path.cubicTo(size.width * 0.98, size.height * 0.73, size.width * 0.97, size.height * 0.71, size.width * 0.97, size.height * 0.71);
      path.cubicTo(size.width * 0.97, size.height * 0.71, size.width * 0.97, size.height * 0.68, size.width * 0.97, size.height * 0.68);
      path.cubicTo(size.width * 0.97, size.height * 0.68, size.width * 0.97, size.height * 0.67, size.width * 0.97, size.height * 0.67);
      path.cubicTo(size.width * 0.97, size.height * 0.67, size.width * 0.96, size.height * 0.65, size.width * 0.96, size.height * 0.65);
      path.cubicTo(size.width * 0.96, size.height * 0.65, size.width * 0.96, size.height * 0.64, size.width * 0.96, size.height * 0.64);
      path.cubicTo(size.width * 0.96, size.height * 0.64, size.width * 0.96, size.height * 0.63, size.width * 0.96, size.height * 0.63);
      path.cubicTo(size.width * 0.96, size.height * 0.63, size.width * 0.96, size.height * 0.62, size.width * 0.96, size.height * 0.62);
      path.cubicTo(size.width * 0.96, size.height * 0.62, size.width * 0.96, size.height * 0.6, size.width * 0.96, size.height * 0.6);
      path.cubicTo(size.width * 0.96, size.height * 0.6, size.width * 0.96, size.height * 0.6, size.width * 0.96, size.height * 0.6);
      path.cubicTo(size.width * 0.96, size.height * 0.6, size.width * 0.96, size.height 
"""
}
