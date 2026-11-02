# TestFlight へ手元から配布する

Xcode Cloud を使わず、手元の Mac で archive → ipa → App Store Connect アップロード → TestFlight の
テスターグループ追加(外部テスター向けの Beta App Review 提出まで)を行う。

## 準備(初回のみ)

認証は MyApps(Shireka など)の deploy スクリプトと同じ仕組みを使う。秘密はリポジトリの外に置く。

```
~/.appstoreconnect/                 ← ASC_HOME(環境変数で変更可)
├── private_keys/
│   └── AuthKey_<KEY_ID>.p8         (chmod 600)
└── slidys.env                      (chmod 600) ← 無ければ shireka.env を使う(同じチームのキー)
```

`slidys.env` の中身(`ASC_ENV_FILE` で別の場所を指定することもできる):

```
ASC_KEY_ID=XXXXXXXXXX
ASC_ISSUER_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
ASC_TEAM_ID=669226BDWM
```

1. API キーが無ければ App Store Connect > ユーザーとアクセス > 統合 > App Store Connect API で作る
   (アクセス: **App Manager**)。すでに MyApps 用の `shireka.env` があれば、そのまま流用される
2. App Store Connect > TestFlight でテスターグループを作っておく(既定のグループ名は Slidys が `ExternalTestGroup`、SlidysFlutter が `ExternalTester`。
   リポジトリの `.env` の `TESTFLIGHT_GROUPS` でカンマ区切り指定可)
3. SlidysFlutter を配布する場合は Flutter が必要
   - `brew tap leoafarias/fvm && brew install fvm cocoapods`
   - `cd flutter_slide && fvm install`(`.fvmrc` のバージョンが入る)→ `fvm flutter pub get && fvm flutter precache --ios`
   - `cd Apps/SlidysFlutter && pod install`

## 使い方

```sh
make testflight-slidys    # Slidys(ネイティブ)を archive → upload → 配布
make testflight-flutter   # SlidysFlutter(Flutter デモ入り)を同様に
```

段階ごとに実行することもできる(直前の archive を `build/testflight/<target>/latest` から使う):

```sh
make testflight-archive-flutter
make testflight-export-flutter      # ipa を手元に残したいとき(upload には不要)
make testflight-upload-flutter
make testflight-distribute-flutter  # 処理完了を待ってグループに追加
```

環境変数で上書きできるもの:

| 変数 | 既定 | 用途 |
|---|---|---|
| `BUILD_NUMBER` | 実行時刻 `yyyyMMddHHmm` | CFBundleVersion。毎回増えるので衝突しない |
| `MARKETING_VERSION` | プロジェクトの値 | CFBundleShortVersionString |
| `TESTFLIGHT_GROUPS` | Slidys: `ExternalTestGroup` / SlidysFlutter: `ExternalTester` | 追加するグループ名(カンマ区切り) |
| `TESTFLIGHT_NOTES` | なし | 「テスト内容」に入れる文言 |

例: `TESTFLIGHT_NOTES="FlutterKaigi2026 デッキ" make testflight-flutter`

## テスターの追加・削除

```sh
make testflight-testers-slidys                                        # グループごとのテスター一覧
make testflight-tester-add-slidys EMAIL=a@example.com                 # TESTFLIGHT_GROUPS の先頭グループに追加
make testflight-tester-add-slidys EMAIL=a@example.com,b@example.com GROUP=ExternalTestGroup
make testflight-tester-remove-slidys EMAIL=a@example.com GROUP=ExternalTestGroup
```

- 外部グループ: 未登録のメールアドレスは新規テスターとして作成され、グループにビルドがあれば
  TestFlight から招待メールが届く。`FIRST_NAME` / `LAST_NAME` は任意
- 内部グループ: App Store Connect のユーザー(チームメンバー)しか追加できない。先に
  「ユーザーとアクセス」から招待し、そのうえで追加する

## 補足

- archive は Automatic 署名(Apple Development)。export / upload では、API キーで Developer Portal に
  「<アプリ名> AppStore CLI」というプロファイルを作って(既にあれば再利用)手元に入れ、manual 署名で
  Apple Distribution に署名し直す(Xcode の Cloud Signing は API キーだと権限エラーになるため)。
  実装は `Scripts/testflight_profiles.py`
- `SIGN_WITH_XCODE_ACCOUNT=1` を付けると archive / export を Xcode のログインアカウントで署名する
- SlidysFlutter は `Apps/Slidys.xcworkspace`(Packages・両アプリ・Pods を含む)でビルドする。
  `SlidysFlutter.xcworkspace` は CocoaPods 生成で Packages が入っていない
- API キーの env が無いときは archive / export だけ Xcode にログイン済みのアカウントで署名する(upload / distribute はキー必須)
- `.claude/settings.json` で `~/.appstoreconnect/**` と `*.p8` の読み取りを拒否している(AI が秘密を読まない)
- 成果物は `build/testflight/<target>/<日時>/` に残る(`.xcarchive`, `ipa/`, 各ログ)
- 輸出コンプライアンスは Info.plist の `ITSAppUsesNonExemptEncryption=false` と、配布スクリプト側の
  `usesNonExemptEncryption=false` の両方で申告している(HTTPS のみの標準的な暗号化のため)
- 外部グループへ追加すると Beta App Review が自動で提出される。初回や大きな変更のときは承認まで
  時間がかかるので、それまでは内部グループで確認する
