# Apple-Hosted Background Assets ガイド

## 概要

Slidysアプリでは動画ファイル（合計約39MB）をApple-Hosted Background Assetsで管理しています。
これによりIPAサイズを削減し、動画はApp Store Connect経由で配信されます。

## アーキテクチャ

```
asset-packs/
└── slidys-videos/
    ├── manifest.json       # アセットパック定義
    └── payload/            # 動画ファイル
        ├── opening_input.mp4
        ├── opening_output.mp4
        ├── book_animation.mp4
        ├── hand_gesture_entity_sample.mp4
        ├── hand_gesture_sign_language.mp4
        └── vision_pro_piano_demo.mp4
```

- **Debugビルド（Xcode Run）**: `Preview Content/` のDevelopment Assetsから`Bundle.main`で読み込み
- **Releaseビルド（TestFlight/App Store）**: `AssetPackManager`経由でダウンロード・読み込み

## 動画ファイル追加手順

### 1. ファイル配置

動画ファイルを以下の2箇所に追加:

```bash
# Asset Pack（本番配信用）
cp new_video.mp4 asset-packs/slidys-videos/payload/

# Development Assets（開発時フォールバック用）
cp new_video.mp4 Apps/Slidys/Slidys/Preview\ Content/
```

### 2. manifest.json 更新

`asset-packs/slidys-videos/manifest.json` の `fileSelectors` にエントリを追加:

```json
{ "file": "new_video.mp4" }
```

### 3. VideoType に case 追加

`Packages/SlidysCore/Sources/SlidesCore/Views/VideoView.swift` の `VideoType` enumに新しいケースを追加:

```swift
case newVideo

// fileName computed property に追加
case .newVideo:
    return "new_video"
```

### 4. ビルド・テスト

```bash
# Asset Pack のビルド
./scripts/build-asset-pack.sh

# Xcode でDebugビルド → Development Assetsからの読み込みを確認
```

## ビルド・アップロード

### セットアップ

1. `.env.example` を `.env` にコピーして認証情報を設定:

```bash
cp .env.example .env
# .env を編集して APP_APPLE_ID, APPLE_ID, APP_SPECIFIC_PASSWORD を設定
```

2. `APP_SPECIFIC_PASSWORD` は [appleid.apple.com](https://appleid.apple.com) → サインインとセキュリティ → アプリ用パスワード で生成。

### コマンド

```bash
# Asset Pack のビルドのみ（.aar 生成）
make asset-pack-build

# アップロードのみ（.env の認証情報が必要）
make asset-pack-upload

# ビルド + アップロード（一括）
make asset-pack
```

スクリプトを直接実行する場合:

```bash
./Scripts/build-asset-pack.sh build    # ビルドのみ
./Scripts/build-asset-pack.sh upload   # アップロードのみ
./Scripts/build-asset-pack.sh all      # 一括（デフォルト）
```

## ローカルテスト方法（AssetPackManager経由）

Development Assetsフォールバックではなく、実際の `AssetPackManager` フローをテストする手順。
**シミュレータでは動作しないため、実機が必要。**

### 1. 自己署名証明書の準備（初回のみ）

`ba-serve` はHTTPSで動作するため、自己署名CA・証明書が必要:

```bash
# CA秘密鍵の作成
openssl genrsa -out ca.key 2048

# CA証明書の作成
openssl req -x509 -new -key ca.key -days 365 -out ca.crt -subj "/CN=BA Test CA"

# サーバー秘密鍵の作成
openssl genrsa -out server.key 2048

# CSR作成 → CA署名でサーバー証明書発行
openssl req -new -key server.key -out server.csr -subj "/CN=ba-serve"
openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days 365
```

`ca.crt` をテスト実機にAirDrop等で送信し、設定 → 一般 → VPNとデバイス管理 からインストール。
設定 → 一般 → 情報 → 証明書信頼設定 で「ルート証明書を全面的に信頼」を有効にする。

### 2. Asset Pack のビルド

```bash
./scripts/build-asset-pack.sh
```

### 3. モックサーバー起動

```bash
xcrun ba-serve --certificate server.crt --key server.key ./asset-packs/slidys-videos
```

### 4. 実機の設定

- **iOS/visionOS**: 設定 → デベロッパ → Development Overrides → モックサーバーのURL（例: `https://192.168.x.x:port`）を入力
- **macOS**: `xcrun ba-serve url-override` で設定

### 5. 環境変数によるBundle.mainフォールバックスキップ

Xcode Schemeの Environment Variables に `SKIP_BUNDLE_VIDEO_FALLBACK=1` を設定すると、
`Bundle.main` からの動画読み込みをスキップし、`AssetPackManager` 経路を強制できます。

**動作フロー**:
- **環境変数なし（通常Debug）**: Preview Content → Bundle.mainで再生（従来通り）
- **環境変数あり + `ba-serve`起動 + 実機**: AssetPackManager経由で再生（本番相当テスト）
- **環境変数あり + シミュレータ**: エラー表示（AssetPackManagerのエラーハンドリングUI確認用）

設定方法: Xcode → Product → Scheme → Edit Scheme → Run → Arguments → Environment Variables に
`SKIP_BUNDLE_VIDEO_FALLBACK` を追加（値は任意）。

### 6. 動作確認のコツ

- 上記の `SKIP_BUNDLE_VIDEO_FALLBACK` 環境変数を使うと、Preview Contentを除外せずにAssetPackManager経路をテスト可能
- tvOSの `ba-serve` 対応は未提供（2025年時点）

## TestFlightでのデプロイ手順

### .aar アップロード方法

`.aar` のアップロードはアプリビルド（.ipa）とは**独立**して行う。

| ツール | 方法 |
|--------|------|
| **Transporter.app** | GUIでドラッグ＆ドロップ（最も簡単） |
| **altool** | `xcrun altool --upload-asset-pack slidys-videos.aar --apple-id <APP_ID> -u <USER>` |
| **iTMSTransporter** | CLIツール。2026以降は `-assetFile` フラグを使用 |
| **App Store Connect REST API** | CI/CD向けプログラマティックアップロード |

### 内部テスター vs 外部テスターの違い

| | 内部テスター（最大100人） | 外部テスター |
|--|------------------------|------------|
| **審査** | **不要** — 処理完了後すぐ利用可能 | **毎回必要** — アップロードごとに審査 |
| **適用バージョン** | 常に最新の処理済みバージョン | 審査通過後のバージョン |
| **同時審査** | N/A | 1バージョンずつのみ（最大10パックをバッチ提出可） |
| **おすすめ用途** | 開発中の素早い検証 | リリース前の最終確認 |

**重要**: アプリ本体の審査とAsset Packの審査は**別プロセス**。
Asset PackはApp Store Connectの **Distribution タブ** から審査に提出する。

アプリ本体は同一バージョンなら外部テスター向け審査は1回で済むが、
**Asset Packは新バージョンをアップロードするたびに毎回審査が必要**。

### 推奨ワークフロー

```
1. 内部テスターで検証（審査不要・イテレーション高速）
2. 問題なければ外部テスター向けに審査提出
3. 審査通過後、外部テスターに自動配信
```

## Asset Pack 分割戦略

### 現在の構成

全動画を1パック（`slidys-videos`）に集約。合計約39MBで更新頻度が低いため、現時点ではこの構成で十分。

### 将来的な分割案（モジュール単位）

動画が増えたり特定スライドだけ頻繁に更新する場合は、スライドモジュール単位での分割を推奨:

```
asset-packs/
├── slidys-iosdc/              # iOSDCSlide用（essential）
│   └── payload/
│       ├── opening_input.mp4      (3.0 MB)
│       └── opening_output.mp4     (6.1 MB)
├── slidys-nagoya/             # NagoyaSwiftSlide用（on-demand）
│   └── payload/
│       └── book_animation.mp4     (11 MB)
├── slidys-iosdc2025/          # iOSDC2025Slide用（on-demand）
│   └── payload/
│       ├── hand_gesture_entity_sample.mp4  (7.6 MB)
│       └── hand_gesture_sign_language.mp4  (8.2 MB)
└── slidys-flutterkaigi/       # FlutterKaigiSlide用（on-demand）
    └── payload/
        └── vision_pro_piano_demo.mp4       (3.0 MB)
```

### 分割の判断基準

| 要素 | 1パック（現状） | モジュール単位 | 動画ごと |
|------|---------------|--------------|---------|
| 更新効率 | 1動画変更で39MB全体再DL | 該当モジュール分だけ | 最小限 |
| 管理の手軽さ | 最も楽 | バランス良い | パック数が増えて煩雑 |
| ポリシー柔軟性 | 全動画同一 | モジュールごとに設定可 | 最大限 |
| 審査コスト | 1回/更新 | 変更パックだけ | パック数分 |

### ダウンロードポリシーの使い分け

パックごとに異なるポリシーを設定できる:

- **essential**: アプリインストール時に自動DL。インストール進捗バーに反映。初回起動に必須のコンテンツ向け
- **prefetch**: インストール時にDL開始、バックグラウンドで継続。すぐ必要だが初回起動には不要なコンテンツ向け
- **on-demand**: `ensureLocalAvailability(of:)` 呼び出し時にDL。オプショナルなコンテンツ向け

### 制約事項

- アプリあたり **最大100パック**
- 全パック合計 **最大200GB**（80%で警告メール）
- 1パックあたり **最大4GB**
- パックは**アトミック**にDL・更新（個別ファイルのパッチ更新は不可）
- **アーカイブしたパックIDは再利用不可**（アーカイブは不可逆）
- 新バージョンのパックは**全アプリバージョンに適用**される → 後方互換性に注意
- 異なるパック間でファイルパスの重複は不可

## トラブルシューティング

### 動画が再生されない（Debugビルド）

- `Apps/Slidys/Slidys/Preview Content/` に対象のmp4ファイルが存在するか確認
- Xcodeプロジェクトの `DEVELOPMENT_ASSET_PATHS` に `"Slidys/Preview Content"` が設定されているか確認

### 動画が再生されない（TestFlight）

- `Info.plist` に `BAUsesAppleHosting = true` が設定されているか確認
- `manifest.json` の `fileSelectors` に対象ファイルが含まれているか確認
- Transporterで `.aar` が正常にアップロードされたか確認
- デバイスのネットワーク接続を確認（essentialポリシーのため初回起動前にダウンロードが必要）

### AssetPackManager のエラー

- `assetPack(withID:)` でエラーが出る場合、`manifest.json` の `assetPackID` が一致しているか確認
- `ensureLocalAvailability(of:)` がタイムアウトする場合、ネットワーク状況を確認

### ba-package コマンドが見つからない

Xcode 26以降のCommand Line Toolsがインストールされている必要があります:

```bash
xcode-select --install
```
