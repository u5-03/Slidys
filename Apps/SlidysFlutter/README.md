# SlidysFlutter

ネイティブの `SlidysFlutter` ターゲットに Flutter の画面を埋め込む Add-to-app アプリです。
Flutter と iOS プラグインは、Flutter 公式の `FlutterNativeIntegration` Swift Package で組み込みます。
CocoaPods のインストールや `pod install` は不要です。

## ローカルでの準備

リポジトリのルートで実行します。

```sh
Apps/ci_scripts/prepare_flutter.sh
open Apps/Slidys.xcworkspace
```

Scheme に `SlidysFlutter` を選んで Run / Archive してください。
`SlidysFlutter.xcodeproj` 単体でも必要なローカルパッケージを参照します。
プロジェクトの Swift / SDK 要件を満たす Xcode と、Python 3、Git が必要です。

準備スクリプトは `flutter_slide/.fvmrc` のバージョン（現在 3.47.5）を使用します。
既存の FVM SDK を利用し、SDK がない場合は同じバージョンを `.fvm/flutter_sdk` に取得します。
`FLUTTER_ROOT` で別の SDK の場所を指定する場合も、バージョンは `.fvmrc` と一致させてください。

`pubspec.lock` に従った依存取得後、全 iOS ネイティブプラグインの SPM 対応を確認します。
Flutter がモジュール用に再生成する `.ios/Podfile` を削除してから、次を実行します。

```sh
flutter build swift-package --platform ios --build-mode debug,release --no-codesign
```

生成先の `flutter_slide/build/ios/SwiftPackages/` は Git 管理しません。
初回チェックアウト、`flutter clean`、Flutter SDK・依存関係の変更後には、準備スクリプトを再実行してください。
通常の Dart コード変更は Scheme の Pre-action と `Assemble Flutter` Build Phase により再ビルドされます。
SPM 未対応の iOS プラグインを追加すると、準備スクリプトはエラーで停止します。

`video_player_avfoundation 2.12.0` は Objective-C ターゲットの Flutter 依存宣言が不足しているため、
生成後に `fix_video_player_spm.py` が生成パッケージ内の宣言を補完します。
SDK や pub キャッシュは変更しません。上流で解消された場合も、既存の依存宣言は重複追加しません。

## Xcode Cloud 用の準備

Xcode Cloud のワークフロー設定は手動で行ってください。リポジトリ側は以下に対応しています。

- Workspace: `Apps/Slidys.xcworkspace`
- Scheme: `SlidysFlutter`（共有済み）
- 配布用 Action: iOS の Archive（Release）
- Post-action: 必要な TestFlight のテスターグループへの配布
- Release Bundle ID: `yugo.sugiyama.iOSDC2024SlideFlutter`
- Signing: 既存の Automatic Signing / Development Team を使用。App Store Connect 側のアプリ登録と権限を確認してください。

`Apps/ci_scripts/ci_post_clone.sh` が Xcode のパッケージ解決より前に SDK の取得、
`pub get`、Swift Package の生成を実行します。`CI_XCODEBUILD_ACTION=archive` の場合は
Release のみを生成します。Flutter 用のカスタム環境変数や FVM / CocoaPods の事前インストールは不要です。
署名はホストアプリの Archive 時に Xcode が行います。

`SlidysFlutter.xcodeproj` を選ぶワークフローでも、同階層の `ci_scripts` シンボリックリンクから
共通の CI スクリプトを実行します。

同じ Workspace の他アプリをビルドする場合も、依存解決に必要な Flutter パッケージを生成します。
既存の `SlidysShareScreenshots` 用スタブ作成処理とマクロ検証設定も引き続き実行されます。

### 既存アプリのビルド番号を引き継ぐ

TestFlight 配布時は Xcode Cloud のビルド番号が使われます。
同じアプリバージョンで過去にアップロードした番号より小さい場合、
`The bundle version must be higher than the previously uploaded version` で配布が失敗します。
`CURRENT_PROJECT_VERSION` の変更ではなく、App Store Connect 側の採番設定を変更してください。

1. 対象アプリの TestFlight で、同じバージョンのアップロード済みビルド番号の最大値を確認します。
2. **Xcode Cloud → Settings → Build Number → Next Build Number → Edit** を開きます。
3. アップロード済みの最大値と、Cloud ですでに使用した番号の両方より大きい整数を保存します。
4. 新しいビルドを開始します。失敗済みの成果物には新しい番号は反映されません。

2026-10-29 の確認時点では、`1.0.0` のアップロード済み最大値は `202610241731` です。
Cloud 側でそれ以上の番号をまだ使っていなければ、次回番号は `202610241732` に設定できます。
以降は Cloud の自動インクリメントを使い、別の配布経路を使う場合も番号を重複させないでください。
設定には Admin または App Manager 権限が必要です。

公式手順: [Xcode Cloud の次回ビルド番号の設定](https://developer.apple.com/documentation/xcode/setting-the-next-build-number-for-xcode-cloud-builds)

公式手順: [Flutter Add-to-app / Swift Package Manager](https://docs.flutter.dev/add-to-app/ios/project-setup)

## 検証

準備スクリプトの回帰テスト:

```sh
python3 -m unittest discover -s Apps/ci_scripts/tests -v
```

Xcode 27.1 で実機向け Release の署名なし Archive と、Flutter エンジン・Dart 資産・
動画プラグインの Privacy Manifest の埋め込みを確認しています。
TestFlight 向けの署名とアップロードは Xcode Cloud の設定後に確認してください。
