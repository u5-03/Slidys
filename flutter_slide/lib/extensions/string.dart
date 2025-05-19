import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_slide/extensions/int.dart';

enum StringCharacterType {
  alphabet,
  number,
  kana,
  emoji,
}

extension on StringCharacterType {
  String get resource {
    switch (this) {
      case StringCharacterType.alphabet:
        return 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
      case StringCharacterType.number:
        return '0123456789';
      case StringCharacterType.kana:
        return 'あいうえおかきくけこさしすせそたちつてとなにぬねのはひふへほまみむめもやゆよらりるれろわをん';
      case StringCharacterType.emoji:
        return '😀😁😂👬👨‍👩‍👦👨‍👨‍👧‍👦';
    }
  }
}

extension StringExt on String {
  static String random(
    int length, {
    List<StringCharacterType> characterTypes = StringCharacterType.values,
  }) {
    final rand = Random();
    final words = characterTypes
        .map((e) => e.resource)
        .reduce((value, element) => value + element);
    // 絵文字😄を含んだStringの配列操作は、charactersにして処理することが必要
    // Ref: https://crieit.net/posts/Flutter-flutter-string-is-not-well-formed-UTF-16
    return List.generate(length, (index) {
      final emojiIndex = rand.nextInt(words.characters.length);
      return words.characters.toList()[emojiIndex];
    }).join();
  }

  static String get randomLength => random(Random().nextInt(50));

  static String randomRange({required int min, required int max}) =>
      random(IntExt.randomRange(min: min, max: max));

  bool get isValidUrl {
    final uri = Uri.tryParse(this);
    return uri != null && uri.isAbsolute;
  }

  bool get isUrl => Uri.tryParse(this)?.hasAbsolutePath ?? false;

  String get camelCaseToSnakeCaseConverted {
    return replaceAllMapped(
      RegExp('([a-z])([A-Z])'),
      (Match m) => '${m[1]}_${m[2]?.toLowerCase()}',
    );
  }

  String get newlineRemoved => replaceAll('\n', '').replaceAll('\r', '');

  String get newlineReplacedToSingleNewline => replaceAll(RegExp(r'\n+'), '\n');

  Uri get asUri => Uri.parse(this);
}
