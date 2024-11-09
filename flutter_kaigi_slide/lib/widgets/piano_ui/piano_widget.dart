import 'package:flutter/material.dart';
import 'package:flutter_kaigi_slide/widgets/piano_ui/aspect_ratio_constants.dart';
import 'package:flutter_kaigi_slide/widgets/piano_ui/piano_key.dart';
import 'package:flutter_kaigi_slide/widgets/piano_ui/piano_key_stroke.dart';
import 'package:flutter_kaigi_slide/widgets/piano_ui/piano_key_widget.dart';

final class PianoWidget extends StatelessWidget {
  PianoWidget({super.key});
  final pianoKeys = PianoKey.allCases();

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final whiteKeyWidth = constraints.maxHeight /
                AspectRatioConstants.whiteKeyAspectRatioSize.height *
                AspectRatioConstants.whiteKeyAspectRatioSize.width;
            final whitePianoKeys =
                pianoKeys.where((key) => key.isWhiteKey).toList();
            final keyMargin = whiteKeyWidth * 0.1;
            final width = whiteKeyWidth * whitePianoKeys.length +
                keyMargin * (whitePianoKeys.length - 1);
            final sortedPianoKeys = List<PianoKey>.from(pianoKeys)
              ..sort(
                (a, b) =>
                    a.isBlackKey == b.isBlackKey ? 0 : (a.isBlackKey ? 1 : -1),
              );
            return SizedBox(
              width: width,
              child: CustomMultiChildLayout(
                delegate: _PianoLayoutDelegate(
                  whiteKeyWidth: whiteKeyWidth,
                  keyMargin: keyMargin,
                  pianoKeys: pianoKeys,
                ),
                children: sortedPianoKeys.map((key) {
                  if (key.isWhiteKey) {
                    return LayoutId(
                      id: key,
                      child: PianoKeyWidget.white(
                        pianoKey: key,
                        keyStrokedType: KeyStrokedType.unstroked(),
                        didTriggerKeyStrokeEvent: (_) {},
                      ),
                    );
                  } else {
                    return LayoutId(
                      id: key,
                      child: PianoKeyWidget.black(
                        pianoKey: key,
                        keyStrokedType: KeyStrokedType.unstroked(),
                        didTriggerKeyStrokeEvent: (_) {},
                      ),
                    );
                  }
                }).toList(),
              ),
            );
          },
        ),
      );
}

final class _PianoLayoutDelegate extends MultiChildLayoutDelegate {
  _PianoLayoutDelegate({
    required this.pianoKeys,
    required this.keyMargin,
    required this.whiteKeyWidth,
  });
  final double whiteKeyWidth;
  final double keyMargin;
  final List<PianoKey> pianoKeys;
  double get blackKeyWidth =>
      whiteKeyWidth /
      AspectRatioConstants.whiteKeyAspectRatioSize.width *
      AspectRatioConstants.blackKeyAspectRatioSize.width;
  double get blackKeyHeight =>
      blackKeyWidth /
      AspectRatioConstants.blackKeyAspectRatioSize.width *
      AspectRatioConstants.blackKeyAspectRatioSize.height;

  @override
  void performLayout(Size size) {
    var whiteKeyX = 0.toDouble();
    for (final pianoKey in pianoKeys) {
      // final index = item.$1;
      // final pianoKey = item.$2;
      if (!hasChild(pianoKey)) continue;
      if (pianoKey.isWhiteKey) {
        layoutChild(
          pianoKey,
          BoxConstraints.tightFor(width: whiteKeyWidth, height: size.height),
        );
        positionChild(pianoKey, Offset(whiteKeyX, 0));
        whiteKeyX += whiteKeyWidth + keyMargin;
      } else {
        layoutChild(
          pianoKey,
          BoxConstraints.tightFor(
            width: blackKeyWidth,
            height: blackKeyHeight,
          ),
        );
        final blackKeyOffset = blackKeyWidth * pianoKey.keyType.keyOffsetRatio;
        final blackKeyX = whiteKeyX -
            blackKeyWidth / 2 -
            keyMargin / 2 +
            blackKeyOffset;
        positionChild(pianoKey, Offset(blackKeyX, 0));
      }
    }
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) => false;
}
