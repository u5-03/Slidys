import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_kaigi_slide/extensions/int.dart';

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
  int get charactersLength {
    // 絵文字と見なされるパターン
    // (\p{Emoji_Presentation}|\p{Extended_Pictographic}): 単一絵文字のマッチパターン
    // \p{Emoji_Presentation}は標準の絵文字を表し、\p{Extended_Pictographic}はより広範な絵文字や記号をカバーする
    // (\u200D(\p{Emoji_Presentation}|\p{Extended_Pictographic}))*: これはゼロ幅結合子（\u200D）を使用して複数の絵文字が結合されたシーケンス(e.g.家族の絵文字)をマッチさせるためのパターン
    final emojiPattern = RegExp(
      r'(\p{Emoji_Presentation}|\p{Extended_Pictographic})(\u200D(\p{Emoji_Presentation}|\p{Extended_Pictographic}))*',
      unicode: true,
    );
    // 改行を削除するロジックはサーバーチームとの調整で見送り
    // final newlineRemovedText = newlineRemoved;

    // 絵文字をカウント
    final emojiMatches = emojiPattern.allMatches(this);

    // 絵文字以外の文字をカウント
    final nonEmojiText = replaceAll(emojiPattern, '');
    final nonEmojiCount = nonEmojiText.runes.length;

    // 絵文字と非絵文字の合計を返す
    return emojiMatches.length + nonEmojiCount;
  }

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
