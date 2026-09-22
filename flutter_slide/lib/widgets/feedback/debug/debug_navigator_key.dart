import 'package:flutter/widgets.dart';

/// ルート Navigator への参照。
///
/// フローティングのデバッグボタンは `MaterialApp.builder` (Navigator より上位) から
/// 生成されるため、その context では `Navigator.of(context)` が Navigator を見つけられない。
/// そこで MaterialApp に `navigatorKey` を渡し、この key 経由で確実に画面遷移する。
final GlobalKey<NavigatorState> debugRootNavigatorKey =
    GlobalKey<NavigatorState>();
