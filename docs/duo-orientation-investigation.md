# Duo回転の調査（2026-11-07）

## 確認済み

- 配布済みSlidys 1.0.1(202611071049)のInfo.plistはiPhone/iPadとも4方向を許可。UIRequiresFullScreen=true。
- 個別スライド、SlideBaseView、SpeakerNotesView、SlidysCommonの全画面カバー、カメラ画面に向き固定の実装なし。
- 使用中SlideKit checkout ee71d2aのSourcesを検索。supportedInterfaceOrientations / autorotate / requestGeometryUpdate / prefersInterfaceOrientationLockedの独自制御なし。SlideScreenとPresentationViewは16:9の内容を画面枠へ縮小するだけ。
- アウターのCameraCaptureDeckViewには縦長枠を90度回す独自処理がある。インナーのSceneの向きを変更する処理ではない。
- Xcode MCP RunCodeSnippet、iPhone Duo/iOS27.1で単体UIHostingControllerを生成し、mask=30(.all)、portraitUpsideDown=true、prefersInterfaceOrientationLocked=falseを確認。スニペット実行環境に接続済みSceneはなく、実アプリのpresented controller階層の確認にはならない。

## Appleの説明

https://developer.apple.com/videos/play/tech-talks/111461/

3:42: インナーではsupported interface orientationsを通常通り尊重しない。レイアウトはsize classを使う。
4:37–4:45: UIRequiresFullScreenは引き続き適用され、向き指定が尊重される代わりにインナーでスケーリングされる。

通常iPhoneの上下逆非対応の説明だけでDuoインナーの挙動を断定してはいけない。今回の症状そのものをAppleが既知不具合として認定した根拠は未確認。

## 診断ログ追加

DeviceOrientationFollowerに状態変化時だけ出力する[DuoDual] [Rotation]ログを追加。端末方向、Duoカメラ稼働、Scene role/activation/effectiveGeometryの方向とlock状態、可視Windowのroot/children/presented controllerのクラス・許可mask・lock preference、回転要求と拒否domain/codeを記録する。実画面の切替も追えるよう1秒間隔で状態を比較し、変化がなければ出力しない。

実機で一覧→スライド→ノートの順に開き、それぞれ縦・横・上下逆を試す。Duoアウター出力とHDMI/AirPlayをオフ/オンで比較する。requestの有無、mask、locked、rejected、後続のinterfaceの値で、アプリ側かOS側かを判定する。

Slidysのビルド成功。診断ログ追加版はまだTestFlightへ配布していない。

## 実機でのログ取得（2026-11-09更新）

共通prefixは **`[SlidysRotation]`**。XcodeのコンソールをAll Outputにし、この文字列でフィルターする。RotationカテゴリだけでなくDuoカメラ・アウター表示の関連ログにも同じprefixを付けている。Infoレベルの非表示を避けるため通常の診断はnoticeで出力する。

1. Slidysターゲットを実機で起動。START（バージョン・ビルド・方向設定・UIRequiresFullScreen）が出ることを確認。
2. まずDuoアウター／HDMI出力をオフにして、一覧→スライド→ノートでそれぞれ縦・横・上下逆に持ち替える。各方向で2秒以上待つ。
3. Duoアウター出力をオンにして同じ持ち替えを繰り返す。必要なら外部ディスプレイ接続も追加して比較する。
4. STARTから再現後のRESULT／SNAPSHOTまで、フィルター済みログをコピーする。どの持ち方で画面が止まったかを添える。

ログの読み方:

- EVENT: UIDeviceの方向通知またはScene活性化。端末方向は文字列で表示。端末とUIのlandscape左右が逆なのはUIKitの座標系の仕様。
- HEARTBEAT: 10秒ごと。これだけが続きEVENTが出ないなら方向通知が来ていない。
- APP_MASK_QUERY: OSがAppDelegateへ問い合わせた許可方向。
- REQUEST id=N: 対象Scene・希望するUI方向。外部／アクセサリーSceneへは要求しない。
- REJECTED id=N: OSからの拒否domain/code/説明。
- RESULT id=N: 0.8秒後と2秒後の実方向・一致判定・Sceneのlock状態。これは成功コールバックではなく、その時点の観測。
- SNAPSHOT: 全Sceneのrole・activation・方向・lock・boundsと可視Window。VCはroot/children/presentedをすべて記録し、各mask・lock preference・表示状態を確認できる。変更があった場合は1秒以内に記録。
- SKIP: 平置き／方向不明、既に希望の向き、または対象Sceneなし。

ログにはスピーカーノート・撮影写真・認証情報は含めない。Sceneの実行時ID、OS・ビルド番号、画面階層の型名・レイアウト情報は含まれる。従来の回転要求の動作は変更せず、観測を追加した。Slidysビルド成功。

## 実機ログで原因判明（2026-11-09）

ユーザー提供ログではdevice=upsideDownを検出し、REQUEST id=5 target=4[upsideDown]を送信。しかしUISceneErrorDomain code=101で拒否:

> None of the requested orientations are supported by the view controller. Requested: portraitUpsideDown; Supported: portrait, landscapeLeft, landscapeRight

root UIHostingControllerとNavigationStackはmask=30(.all)だが、fullScreenCoverが作るPresentationHostingController<AnyView>はmask=26(.allButUpsideDown)。Scene locked=false、duoCapture=false。直接の拒否原因はこのモーダル表示層の許可方向。センサー未検出・AppDelegate設定漏れ・SlideKitのメッシュ等が原因ではない。Duo固有OSバグという結論も不要。

SlidysCommonViewのスライド表示のみをfullScreenCoverから同一Window内のoverlay+NavigationStackへ変更。既存rootの4方向許可を使い、閉じる導線はslideCloseActionを維持する。下の一覧のヒットテスト・アクセシビリティは表示中無効化。Other画面と一覧プレビューのモーダルは今回の修正対象外。

Slidysビルド成功。実機で同じ持ち替えを再試行し、PresentationHostingController(mask=26)がスライド階層から消え、target=upsideDownのRESULT matches=trueとなるかを確認する。実機での修正確認は未完了。TestFlight未配布。

## 同様の全画面表示を置換（2026-11-09）

スライド以外にもSlidysCommonViewのOther画面、Saitama一覧プレビュー、SamplePageViewのデモを同一Window内の前面表示へ変更。SlidysCore/Sources配下にfullScreenCoverの呼び出しは残っていない。SlideDeckPreviewViewに任意のonCloseを追加し、モーダルに依存せず閉じる状態を戻せるようにした。既存のmacOS等の呼び出しでは環境dismissを引き続き利用。

PDF書き出しのsheetとmacOSのsheetは用途が異なるため維持。UIRequiresFullScreen・4方向許可・外部出力の処理は変更しない。Slidysビルド成功。最終的なDuo上下逆の実機確認は未完了。

## 回転要求の撤去（2026-11-09）

同一Window表示へ変更後、全方向で向きが合わないという実機報告。以前追加したDeviceOrientationFollowerのUIDevice→UIInterfaceOrientation変換とrequestGeometryUpdateによる強制回転が、OS標準のDuo回転制御と競合し得るため撤去。これは新症状の原因確定ではなく、不要な独自制御を取り除く修正。

現在は方向通知の観測のみ。アプリ側の全方向許可は維持し、回転はOSに任せる。ログは[SlidysRotation]を維持し、EVENT mode=observeOnlyと0.8秒/2秒後のOBSERVED/SNAPSHOTを記録。次のイベントで上書きされた観測にはsuperseded=trueを付ける。REQUEST/REJECTEDはこの版では発行しない。

Slidysビルド成功。実機で一度アプリを終了して再起動し、通常の縦横と上下逆を確認する必要がある。実機解決はまだ断定しない。

## 観測専用版の実機ログ（2026-11-09、build69/iOS27.2）

新しいログはmode=observeOnly。PresentationHostingControllerはなく、可視アプリ側のroot/NavigationController/NavigationStackは全てmask=30(.all)、prefersLock=false。UITrackingElementWindowControllerのmask=2は非keyのシステム編集補助Windowであり、これだけを根拠に原因と判断しない。

UIDevice通知にportrait / landscapeLeft / landscapeRight / faceUp / unknownは存在するが、upsideDownは一度もない。Duoカメラ出力はfalse、Sceneは1つ、locked=false。端末portraitでScene landscapeLeft、端末landscapeLeftでScene portraitという組み合わせが保持される。Duoのセンサー座標とインナーの自然な画面座標を一対一と仮定して異常や変換角度を決めない。

従来のcode101拒否はこのログには存在せず、前のモーダル層の拒否は解消している。ただしユーザーの見た目の問題は未解決。現在が『特定の持ち方だけ追従しない』か『全方向で不一致』かを確認中。UIRequiresFullScreen=1は依然有効で、ネイティブ表示モードとの比較は今後の切り分け候補。OSバグと断定せず、このログだけを理由に再び強制回転や固定角度補正を追加しない。

## 特定の縦持ちだけが残ることを確認（2026-11-09）

ユーザー回答: アウターディスプレイが上になる縦持ちだけ回らず、他の向きは正常。通常の自動回転全体の故障ではない。

比較のためSlidysのDebug/ReleaseのUIRequiresFullScreenをNOへ変更。アプリ側の4方向許可・同一Window表示・観測専用ログは維持。Duoの互換スケーリング表示を外す一変数の切り分けであり、これが原因だったと確定したわけではない。iPadでは従来の全画面必須制限もなくなるため、ウィンドウ表示でのレイアウト確認が別途必要。Slidysビルド成功。TestFlight配布なし。

実機再実行時にSTARTのUIRequiresFullScreen=0を確認し、問題の持ち方を含む一周を試す。iPhoneアプリのplist/Scene状態は再起動して比較する。今回もセンサーのorientationを画面のorientationへ強制変換しない。


## UIRequiresFullScreen無効化後の実機結果（2026-11-09）

ユーザーから「よさそうです」と改善報告。追加ログにはupsideDown方向のEVENTが4回含まれる。修正版を内部TestFlightへ配布する依頼を受領。メニューから方向依存の「右側」を取り除き、「スピーカーノートを表示」に統一。独自の強制回転は戻さない。
