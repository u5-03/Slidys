# ノート内のスライドを操作して出力する

発表者メニュー → スライドの出力方式:

- **通常表示（従来）**: 出力先ごとに独立描画。RealityViewやWebViewのローカル状態は共有しない。
- **手元の操作を映す**: 操作用の現在スライドの描画結果だけを、HDMI / AirPlay / Duoアウターへ表示する。

## 手元画面を明示して取得する

ScreenCaptureKitのアプリ共有は、外部画面やDuoアウターを取得してしまうことが実機ログで確認された。
iOSの公開APIでは共有フィルターのWindowを直接指定できないため、この経路は使用しない。
画面収録の許可や共有ピッカーは不要。

現在のスライド枠を表すUIViewの`window`を取得元にする。
`UIScreen.main`や画面全体から推測せず、スライド枠もWindow座標で計算する。
`UIView.drawHierarchy(in:afterScreenUpdates: false)`でスライド枠を最大15fpsで画像化する。
最大辺1920ピクセル・最大2073600画素、8bitの共通フレームを1枚生成し、全出力先のUIImageViewで共有する。
出力先ごとのUIKitスナップショットや更新タイマーは保持しない。
同期的な画面更新を強制する`true`はRealityViewのちらつきにつながったため使用しない。

Scene固有のdisplayLinkへの付け替えをやめ、通常のdisplayLinkを使う。
更新が200ms以上止まった場合は250ms間隔のタイマーでも更新し、画面切替時の停止から復帰する。
取得元マーカーは弱参照のリストで管理し、SwiftUIが一方を取り外しても残った有効な枠から取得する。

切り抜いたviewportを出力先へ縦横比を維持して配置する。
各出力先の画像を同じフレームに差し替える。一時的に取得できない場合は直前のフレームを維持する。
出力先がなくなった時とバックグラウンドでは取得を停止し、メモリ警告時も保持フレームを解放する。
元Viewがない、Window外、バックグラウンドの場合は黒表示。
スピーカーノートを含む画面全体を出力するフォールバックは行わない。

## 検証範囲

- Slidysのビルド。
- 実機ログのDuo内側669×951、スライド567×319、出力678×466を使った切り抜き計算。
- HDMI 1920×1080の配置、縦横比維持、画面外の拒否。
- RealityViewの操作とWebView動画が外部へ連続反映されるかは実機で再確認が必要。

描画済みの画面を取得する方式のため、OSのキャプチャ保護や未描画のGPUコンテンツを保証するものではない。
解像度は手元のスライド枠に依存する。方式切替でViewが再生成されるので、操作前に選択する。
診断ログは`[PresenterCapture]`で、取得元の登録、取得条件による停止、描画更新のタイマーへの退避、取得元・表示先の寸法変化を出力する。

## 表示先とノートの切り替え

出力方式と手元のレイアウトは独立している。手元の操作を映す場合でも、ミラーリングへ戻せる。
通常の「スピーカーノートを表示」は同じView内に表示し、別Sceneは開かない。
外部ディスプレイの発表者表示は接続中の専用メニューから明示して選択する。

iPhone Duoには次の3モードがある。

- 外側にスライド・内側にノート
- 両画面にスライド（操作を共有）
- 内側にスライド・外側にノート

操作共有では、操作可能なスライドのあるWindowを取得元とする。入れ替え時は外側のカメラアクセサリーSceneが取得元になる。
双方が相手をキャプチャする循環は作らない。

フルHD上限制限は保持画像のサイズを制限するもので、OS内部の描画バッファやRealityKitの全メモリ使用量を保証しない。
実機での長時間使用、モード切替、RealityView・動画の反映は別途検証が必要。

## Manual diagnostics: [PresenterCapture]

Filter the Xcode console by `[PresenterCapture]` and retain the entire session.
Test HDMI alone, then HDMI plus Duo, operating RealityView and video for at least 30 seconds each.
Repeat presentation/mirroring and independent/capture switches about 10 times.
Test all three Duo modes, including operating the outer notes in swapped mode.
Continue for five minutes if possible, then stop Duo, disconnect HDMI and close the slides.

Successful capture reports `stats` about every five seconds.
- `fps`: produced frames, not verified display refreshes.
- `incomplete`: UIKit drawHierarchy returned false. Zero does not guarantee GPU/video content is visible.
- `fallback`: watchdog ticks; `meanRenderMS`: average image rendering time.
- `pixels`: maximum edge must be <=1920 and area <=2073600. `frameBytes` must not multiply when `outputs` becomes 2.
- `footprintMB`: process-wide physical footprint, including RealityKit/WebKit. -1 means query failed.
- `peakObservedMB`: largest sampled footprint, not the OS high-water mark.
- `availableMB`: OS-reported additional available memory, not a fixed app limit.

Look for sustained growth across repeated switches and prolonged use.
After the last output detaches, expect `driver stopped frame-released` and `frameBytes=0`.
Process memory need not fall immediately after releasing a frame; this alone does not prove a leak.
Memory warning logs record footprint before/after clearing retained frames.
Include visual observations and the exact action that failed; logs cannot verify image contents or prove the crash is resolved.

Resolution now follows the highest physical-pixel destination demand, with aspect-fit and a Full HD cap.
HDMI and Duo still share one image; no smaller duplicate image is rendered for Duo.
`destinationPixels` logs destination sizes and `sourceNativePixels` logs the source backing size.
Increasing the bitmap size cannot guarantee additional detail in already-rasterized RealityView/video surfaces.

## Slide-only hosting boundary

The live slide is now mounted once in a dedicated UIHostingController via PresenterSlideCaptureSurface.
Both the regular presentation and interactive notes preview use this boundary.
The renderer draws only that hosting view, rather than the whole UIWindow.
Toolbar menus and speaker notes outside it cannot be included by window cropping.
Environment values are forwarded into the hosted slide; hit testing remains on the same live slide.
The source is measured in window coordinates for output size, but rendered in its own local coordinates.
The log field `captureScope=slide-subtree` identifies the new path.

TaiyakiFocusView removes its old scene on disappearance; existing task cancellation checks prevent a cancelled load from attaching a model.
This does not guarantee an immediate drop in the process footprint or solve a RealityKit internal assertion.
Compare meanRenderMS, fps, footprintMB and visual RealityView/video reproduction on the device.
