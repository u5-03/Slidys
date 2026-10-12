import 'dart:ui' show PlatformDispatcher;

/// ホスト(Swift のスライド)で選ばれている表示言語。
///
/// Swift 側は FlutterViewController の初期ルートに `?lang=en` を付けて渡す
/// (例: `/logSlide?lang=en`)。発表中に言語を切り替えると Flutter の画面ごと作り直されるので、
/// 起動時に 1 回読むだけでよい。
class SlideLanguage {
  SlideLanguage._();

  static bool isEnglish = false;

  /// main() の最初に呼ぶ: 初期ルートのクエリから表示言語を決める
  static void applyInitialRoute() {
    final route = PlatformDispatcher.instance.defaultRouteName;
    isEnglish = Uri.tryParse(route)?.queryParameters['lang'] == 'en';
  }
}

/// 表示言語に合わせて日本語 / 英語の文言を返す
String tr(String ja, String en) => SlideLanguage.isEnglish ? en : ja;
