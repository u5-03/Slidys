# iPhone / iPad で発表する(外部ディスプレイ / PDF 書き出し)

## 外部ディスプレイ

映像出力に対応する iPhone / iPad を HDMI アダプタや AirPlay で外部ディスプレイにつなぎ、
デッキを開くと、アプリが外部画面用の Window にスライドを描画する。
iOS / iPadOS 27 以降は、スライド表示中の ViewController に `UISceneAccessory.externalNonInteractive`
を登録する。ノート表示へ切り替えても登録を保持し、スライドを閉じたときに解除する。
26 以前は Info.plist と AppDelegate による従来方式を使う。

操作はすべてナビゲーションバーの **発表者メニュー**(スライド表示中は右上、外部出力中は左上の「…」)から:

- **右側にスピーカーノートを表示 / 閉じる**: 手元の画面を左スライド / 右ノートに分割
- **外部ディスプレイに出力(手元はノート)**(接続中のみ活性): 外部ディスプレイにスライドだけを出し、手元はスピーカーノート
  (現在/次のプレビュー・原稿・経過時間・「戻る / 次へ」)になる
- **手元にもスライドを表示(操作用)**: 外部出力中に、埋め込んだ Flutter のデモなどを操作したいとき。手元にスライドが出て、
  外部ディスプレイには手元の画面がスナップショットで映る(`ExternalDisplayMirroringPreferred` のスライド)
- 操作が終わったら、もう一度 **外部ディスプレイに出力(手元はノート)** を選ぶ。ノートは続きのページから表示される
- **最初のスライドへ** / **スライドを閉じる**

- 実装: `SlidesCore/Views/ExternalDisplay/ExternalDisplayCoordinator.swift`。
  SlideKit の `ExternalDisplayManager` / `SlideWindowSceneDelegate` と同じ考え方で、外部ディスプレイの
  UIWindowScene に自前の UIWindow を作る。27 以降の登録は `ExternalDisplayAccessoryView` が行い、
  登録した Scene configuration の delegate として既存の `ExternalDisplaySceneDelegate` を再利用する。
  26 以前のアプリ側の配線は 2 つ:
  - Info.plist の `UIApplicationSceneManifest` > `UISceneConfigurations` に
    `UIWindowSceneSessionRoleExternalDisplayNonInteractive` として `SlidysExternalDisplaySceneDelegate` を登録
    (これが無いと UIKit は外部ディスプレイ用の Scene を作らない。Xcode の `UIApplicationSceneManifest_Generation` は
    Info.plist の設定を上書きしてしまうので OFF にしている)
  - `UIApplicationDelegate` の `configurationForConnecting` で
    `ExternalDisplayCoordinator.sceneConfiguration(for:)` を返す(Slidys は `SlidysAppDelegate`、SlidysFlutter は `FlutterAppDelegate`)
- 外部ディスプレイ側(presentation モード)は別 Window に SlideRouterView を描くため、デッキが `.environment(...)` で
  注入した値(Flutter の Router など)は自動では届かない。デッキは `.environment(\.externalDisplaySlideDecorator)` で
  「外部ディスプレイ用スライドに同じ環境値を付け直す」処理を登録する(FlutterKaigi2026 / FlutterKaigi / FlutterNinjas は登録済み。
  これが無いと外部側の Flutter デモが空になる)
- スライド内の埋め込み View(Flutter の画面など)は `.excludesFromSlideTapNavigation()` で、左上/右上のページ送り
  タップ領域からくり抜かれている(タップしてもページが進まず、中の View に届く)
- ハードウェアキーボード / プレゼン用リモコン(クリッカー)の矢印・Page Up/Down でも送れる。「P」でノート分割の切り替え。
  クリッカーのキーは SwiftUI のフォーカスに頼らず、`SlideClickerKeyInterceptor`
  (`SlidesCore/Views/SlideClickerKeyInterceptor.swift`)が UIApplication.sendEvent を差し替えて受け、表示中のデッキを直接送る。
  外部ディスプレイの Window や、タップしてキー入力を握る Flutter の View があっても効く。
  両アプリの AppDelegate の didFinishLaunching で `SlideClickerKeyInterceptor.install()` を呼んでいる
  (SwiftUI の App ライフサイクルは NSPrincipalClass を無視するので UIApplication のサブクラスでは差し込めない)

### 動作確認(シミュレーター)

iOS シミュレーターの I/O > External Displays で外部画面を接続して確認する。
Scene が届かない場合は、Console の subsystem `Slidys` / category `ExternalDisplay` で、
`external accessory registered`、`external scene willConnect`、`external window created` を確認する。
実機でも接続・切断、出力モードの切り替えを確認する。
外部ディスプレイに出す内容だけを確認したいときは、起動引数 `-SlidysExternalDisplayPreview` を付けて起動すると、
手元画面の左上に同じ内容(`ExternalDisplayRootView`)がオレンジ枠の小窓で重なる(操作は透過)。

## PDF 書き出し

スライド一覧のデッキ名を **長押し**(macOS は右クリック)→「PDFを書き出す」。
書き出しが終わると共有シートから AirDrop / ファイルに保存できる。

- 実装: `SlidesCore/Views/PDFExport/SlidePDFExporter.swift`。SlideKit の `SlidePDFExporter`
  (macOS 専用)と同じく `ImageRenderer` で 1 ページずつ PDF コンテキストに描画する
- フェーズ付きのスライドは全項目を表示した状態で 1 ページになる
- Flutter の画面・動画・Web・RealityView は ImageRenderer で描けないので、`isSlideThumbnail` 環境値で
  ダミー表示(`EmbeddedContentPlaceholder`)に置き換わる
- 対応デッキは `SlideViewProtocol.pdfExportSource` を実装したもの(FlutterKaigi2026 / iOSDC2026)。
  他のデッキも同じプロパティを足せばメニューに出る
