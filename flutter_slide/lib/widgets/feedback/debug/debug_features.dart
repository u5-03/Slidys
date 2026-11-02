/// デバッグ機能 (フローティングボタン / Issue 起票 / 画面リプレイ) を有効化するかのフラグ。
///
/// iOS 版アプリの `AppEnvironment.isDebugFunctionEnabled` に相当する。
/// **ビルドモード (kDebugMode) ではなく明示フラグにしている理由**:
/// Flutter の Debug ビルドは JIT なので、実機では `flutter run` / デバッガ無しの単独起動で
/// クラッシュする。実機やカンファレンスのデモでは Profile / Release でビルドする必要があるが、
/// その際 `kDebugMode` は false になりデバッグ機能が消えてしまう。
///
/// このサンプルはデバッグ機能のデモが目的なので **既定を true** にして、Release / Profile でも
/// (Xcode から直接 Run しても) 機能が出るようにしている。無効化したい場合は dart-define で上書きする。
///
/// 例:
///   flutter run                                            # 機能ON
///   flutter run --release                                  # 機能ON (実機でも JIT クラッシュしない)
///   flutter run --release --dart-define=ENABLE_DEBUG_FEATURES=false  # 機能OFF
const bool kDebugFeaturesEnabled = bool.fromEnvironment(
  'ENABLE_DEBUG_FEATURES',
  defaultValue: true,
);
