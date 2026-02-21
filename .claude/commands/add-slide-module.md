# Add Slide Module: $ARGUMENTS

新しいスライドモジュール `$ARGUMENTS` を Slidys プロジェクトに追加してください。

## 命名規則

- モジュール名: `$ARGUMENTS` (例: `HakodateSwiftSlide`)
- View 名: `${モジュール名}View` (例: `HakodateSwiftSlideView`)
- enum case 名: モジュール名を lowerCamelCase に変換 (例: `hakodateSwift`)
  - 末尾の `Slide` は省略する

## 作成するファイル

Base path: `Packages/SlidysCore/Sources/$ARGUMENTS/`

### 1. `$ARGUMENTS.swift` (メインエントリポイント)

既存モジュール（MinokamoSwiftSlide など）を参考に以下を定義:
- `${モジュール名}View: SlideViewProtocol` を `public struct` で定義
- `SlideConfiguration: SlideConfigurationProtocol` に以下のスライドを登録:
  1. `CenterTextSlide(text: "イベント名")` — イベント名はモジュール名から推測
  2. `ReadmeSlide(title:info:)` — iOSDC2025Slide の ReadmeSlide と同じ自己紹介テキストをコピー
- import は `SwiftUI`, `SlideKit`, `SlidesCore` のみ

### 2. `Constants/Constants.swift`

- `Constants.presentationName` — イベント名を設定
- Font extensions (`extraLargeFont`, `largeFont`, `midiumFont`) — 既存モジュールと同じ typo (`midiumFont`) を維持すること
- Color extensions (`defaultForegroundColor`, `slideBackgroundColor`, `strokeColor`, `themeColor`)

### 3. `Assets.xcassets/`

MinokamoSwiftSlide から構造をコピー:
- `Contents.json`
- `AccentColor.colorset/Contents.json`
- `AppIcon.appiconset/Contents.json`
- `icon.imageset/Contents.json` + `red_beans.png`（バイナリコピー）

## 既存ファイルの修正

### `Packages/SlidysCore/Package.swift`

3箇所の追加:
1. **products 配列**に `.library(name: "$ARGUMENTS", targets: ["$ARGUMENTS"])` を追加（末尾に追加）
2. **SlidysCommon の dependencies** に `"$ARGUMENTS"` を追加
3. **targets 配列**に `.target(name: "$ARGUMENTS", dependencies: ["SlidesCore"])` を追加（iOSDC2025Slide の target の後に追加）

### `Packages/SlidysCore/Sources/SlidysCommon/SlidysCommonView.swift`

4箇所の追加:
1. `import $ARGUMENTS` を追加
2. `SlideType` enum に `case ${lowerCamelCase}` を追加
3. `displayValue` に対応する `case` を追加 (表示名はイベント名 + " #1")
4. `view` に対応する `case` で `${モジュール名}View()` を返す

## 検証

1. `swift build` を `Packages/SlidysCore/` で実行してコンパイル成功を確認
