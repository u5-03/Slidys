import 'dart:math';

import 'package:flutter/material.dart';

@immutable
final class PianoKey {
  const PianoKey({required this.keyType, required this.octave});

  factory PianoKey.random() {
    return PianoKey(keyType: KeyType.random(), octave: Octave.random());
  }

  factory PianoKey.fromNoteNumber(int noteNumber) {
    final numberOfKeys = KeyType.values.length;
    final octaveIndex = noteNumber ~/ numberOfKeys;
    final keyIndex = noteNumber % numberOfKeys;

    final keyType = KeyType.values[keyIndex];
    final octave = Octave.values[octaveIndex];

    return PianoKey(keyType: keyType, octave: octave);
  }
  final KeyType keyType;
  final Octave octave;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PianoKey) return false;
    return other.id == id && other.noteNumber == noteNumber;
  }

  @override
  int get hashCode => id.hashCode ^ noteNumber.hashCode;

  @override
  String toString() => 'PianoKey(id: $id, noteNumber: $noteNumber)';

  String get id {
    return keyType.id.toString() + octave.id.toString();
  }

  int get noteNumber {
    return octave.octaveNumber * KeyType.values.length + keyType.keyIndex;
  }

  bool get isC {
    return keyType == KeyType.c;
  }

  bool get isBlackKey {
    return keyType.isBlackKey;
  }

  bool get isWhiteKey {
    return !keyType.isBlackKey;
  }

  String keyDisplayValue(KeyDisplayType keyDisplayType) {
    String keyString;
    switch (keyDisplayType) {
      case KeyDisplayType.english:
        keyString = keyType.keyEnglishName;
      case KeyDisplayType.germany:
        keyString = keyType.keyGermanyName;
      case KeyDisplayType.italic:
        keyString = keyType.keyItalicName;
      case KeyDisplayType.italicKatakana:
        keyString = keyType.keyItalicKatakanaName;
      case KeyDisplayType.japanese:
        keyString = keyType.keyJapaneseName;
    }
    return octave.octaveNumber.toString() + keyString;
  }

  static List<PianoKey> allCases() {
    return Octave.values
        .map(
          (octave) => KeyType.values
              .map((keyType) => PianoKey(keyType: keyType, octave: octave))
              .toList(),
        )
        .expand((x) => x)
        .toList();
  }

  static PianoKey randomKey(Octave octave) {
    return PianoKey(keyType: KeyType.random(), octave: octave);
  }
}

enum Octave {
  minusFirst,
  zero,
  first,
  second,
  third,
  fourth,
  fifth,
  sixth,
  seventh,
  eighth,
  ninth;

  static Octave random() {
    return Octave.values[Random().nextInt(Octave.values.length)];
  }

  int get id => octaveNumber;

  int get octaveNumber => index - 1;
}

enum KeyDisplayType {
  english,
  germany,
  italic,
  italicKatakana,
  japanese;

  String get id => name;

  static const KeyDisplayType defaultDisplay = KeyDisplayType.english;

  String get displayName {
    switch (this) {
      case KeyDisplayType.english:
        return '英語';
      case KeyDisplayType.germany:
        return 'ドイツ';
      case KeyDisplayType.italic:
        return 'イタリア';
      case KeyDisplayType.italicKatakana:
        return 'イタリア(カタカナ)';
      case KeyDisplayType.japanese:
        return '日本';
    }
  }
}

enum KeyType {
  c,
  cSharp,
  d,
  dSharp,
  e,
  f,
  fSharp,
  g,
  gSharp,
  a,
  aSharp,
  b;

  static KeyType random() {
    return KeyType.values[Random().nextInt(KeyType.values.length)];
  }

  int get id => keyIndex;

  bool get isNextBlackKeyEmpty {
    switch (this) {
      case KeyType.dSharp:
      case KeyType.aSharp:
        return true;
      default:
        return false;
    }
  }

  List<List<KeyType>> get keyTypePairs {
    return [
      [KeyType.c, KeyType.cSharp],
      [KeyType.d, KeyType.dSharp],
      [KeyType.e],
      [KeyType.f, KeyType.fSharp],
      [KeyType.g, KeyType.gSharp],
      [KeyType.a, KeyType.aSharp],
      [KeyType.b],
    ];
  }

  int get keyIndex => index;

  int get isWhiteKeyIndex {
    switch (this) {
      case KeyType.c:
        return 0;
      case KeyType.d:
        return 1;
      case KeyType.e:
        return 2;
      case KeyType.f:
        return 3;
      case KeyType.g:
        return 4;
      case KeyType.a:
        return 5;
      case KeyType.b:
        return 6;
      default:
        return -1;
    }
  }

  double get keyOffsetRatio {
    const defaultOffset = 0.12;
    switch (this) {
      case KeyType.cSharp:
        return -defaultOffset;
      case KeyType.dSharp:
        return defaultOffset;
      case KeyType.fSharp:
        return -defaultOffset;
      case KeyType.gSharp:
        return 0;
      case KeyType.aSharp:
        return defaultOffset;
      default:
        return 0;
    }
  }

  bool get isBlackKey {
    switch (this) {
      case KeyType.cSharp:
      case KeyType.dSharp:
      case KeyType.fSharp:
      case KeyType.gSharp:
      case KeyType.aSharp:
        return true;
      case KeyType.c:
      case KeyType.d:
      case KeyType.e:
      case KeyType.f:
      case KeyType.g:
      case KeyType.a:
      case KeyType.b:
        return false;
    }
  }

  bool get isWhiteKey => !isBlackKey;

  String get keyEnglishName {
    switch (this) {
      case KeyType.c:
        return 'C';
      case KeyType.cSharp:
        return 'C#';
      case KeyType.d:
        return 'D';
      case KeyType.dSharp:
        return 'D#';
      case KeyType.e:
        return 'E';
      case KeyType.f:
        return 'F';
      case KeyType.fSharp:
        return 'F#';
      case KeyType.g:
        return 'G';
      case KeyType.gSharp:
        return 'G#';
      case KeyType.a:
        return 'A';
      case KeyType.aSharp:
        return 'A#';
      case KeyType.b:
        return 'B';
    }
  }

  String get keyGermanyName {
    switch (this) {
      case KeyType.c:
        return 'C';
      case KeyType.cSharp:
        return 'Cis';
      case KeyType.d:
        return 'D';
      case KeyType.dSharp:
        return 'Dis';
      case KeyType.e:
        return 'E';
      case KeyType.f:
        return 'F';
      case KeyType.fSharp:
        return 'Fis';
      case KeyType.g:
        return 'G';
      case KeyType.gSharp:
        return 'Gis';
      case KeyType.a:
        return 'A';
      case KeyType.aSharp:
        return 'Ais';
      case KeyType.b:
        return 'H';
    }
  }

  String get keyItalicName {
    switch (this) {
      case KeyType.c:
        return 'Do';
      case KeyType.cSharp:
        return 'Do♯';
      case KeyType.d:
        return 'Re';
      case KeyType.dSharp:
        return 'Re♯';
      case KeyType.e:
        return 'Mi';
      case KeyType.f:
        return 'Fa';
      case KeyType.fSharp:
        return 'Fa♯';
      case KeyType.g:
        return 'Sol';
      case KeyType.gSharp:
        return 'Sol♯';
      case KeyType.a:
        return 'La';
      case KeyType.aSharp:
        return 'La♯';
      case KeyType.b:
        return 'Si';
    }
  }

  String get keyItalicKatakanaName {
    switch (this) {
      case KeyType.c:
        return 'ド';
      case KeyType.cSharp:
        return 'ド♯';
      case KeyType.d:
        return 'レ';
      case KeyType.dSharp:
        return 'レ♯';
      case KeyType.e:
        return 'ミ';
      case KeyType.f:
        return 'ファ';
      case KeyType.fSharp:
        return 'ファ♯';
      case KeyType.g:
        return 'ソ';
      case KeyType.gSharp:
        return 'ソ♯';
      case KeyType.a:
        return 'ラ';
      case KeyType.aSharp:
        return 'ラ♯';
      case KeyType.b:
        return 'シ';
    }
  }

  String get keyJapaneseName {
    switch (this) {
      case KeyType.c:
        return 'ハ';
      case KeyType.cSharp:
        return '嬰ハ';
      case KeyType.d:
        return 'ニ';
      case KeyType.dSharp:
        return '嬰ニ';
      case KeyType.e:
        return 'ホ';
      case KeyType.f:
        return 'ヘ';
      case KeyType.fSharp:
        return '嬰ヘ';
      case KeyType.g:
        return 'ト';
      case KeyType.gSharp:
        return '嬰ト';
      case KeyType.a:
        return 'イ';
      case KeyType.aSharp:
        return '嬰イ';
      case KeyType.b:
        return 'ロ';
    }
  }
}
