import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_slide/widgets/piano_ui/piano_key.dart';

class PianoKeyStroke {
  final PianoKey key;
  final int velocity;
  final int timestampNanoSecond;
  final bool isOn;

  PianoKeyStroke({
    required this.key,
    required this.velocity,
    required this.timestampNanoSecond,
    this.isOn = true,
  });

  int get velocityPercent {
    final percent =
        (velocity.toDouble() / PianoKeyStroke.maxVelocity * 100).toInt();
    return min(max(percent, 0), 100);
  }

  double get velocityRatio {
    return velocityPercent / 100;
  }

  int get noteNumber => key.noteNumber;

  KeyStrokedType get keyStrokedType {
    return isOn
        ? KeyStrokedType.stroked(velocityPercent)
        : KeyStrokedType.unstroked();
  }

  static const int maxVelocity = 127;
  static const int minVelocity = 0;

  static PianoKeyStroke random() {
    return PianoKeyStroke(
      key: PianoKey.randomKey(Octave.fourth),
      velocity: Random().nextInt(PianoKeyStroke.maxVelocity + 1),
      timestampNanoSecond: UInt64.now(),
      isOn: true,
    );
  }

  String get id {
    return key.id + isOn.toString() + timestampNanoSecond.toString();
  }

  Duration get miliSecondInterval {
    return Duration(milliseconds: timestampNanoSecond ~/ 1000000);
  }

  Duration get secondInterval {
    return Duration(seconds: timestampNanoSecond ~/ 1000000000);
  }

  PianoKeyStroke get asStrokeOff {
    return PianoKeyStroke(
      key: key,
      velocity: velocity,
      timestampNanoSecond: timestampNanoSecond,
      isOn: false,
    );
  }

  KeyStrokedType get asKeyStrokedType {
    return keyStrokedType;
  }
}

sealed class KeyStrokedType {
  const KeyStrokedType();
  static KeyStrokedType stroked(int percent) => KeyStrokedStroke(percent);
  static KeyStrokedType unstroked() => KeyStrokedUnstroked();

  bool get isStroked => this is KeyStrokedStroke;

  int get velocityPercent {
    switch (this) {
      case KeyStrokedStroke(:final percent):
        return percent;
      case KeyStrokedUnstroked():
        return 0;
    }
  }
}

final class KeyStrokedStroke extends KeyStrokedType {
  KeyStrokedStroke(this.percent);
  final int percent;
}

final class KeyStrokedUnstroked extends KeyStrokedType {}

extension PianoKeyStrokeListExtension on List<PianoKeyStroke> {
  List<PianoKeyStroke> get onlyStrokedKeyStroke {
    final List<PianoKeyStroke> pianoKeyStroke = [];
    forEach((keyStroke) {
      if (pianoKeyStroke
          .any((ks) => ks.noteNumber == keyStroke.noteNumber && ks.isOn)) {
        pianoKeyStroke
            .removeWhere((ks) => ks.noteNumber == keyStroke.noteNumber);
      } else {
        pianoKeyStroke.add(keyStroke);
      }
    });
    return pianoKeyStroke;
  }

  String get id {
    return fold<String>('', (initialValue, value) => initialValue + value.id);
  }
}

class UInt64 {
  static int now() {
    final machTime = DateTime.now().microsecondsSinceEpoch *
        1000; // Convert microseconds to nanoseconds
    return machTime;
  }
}
