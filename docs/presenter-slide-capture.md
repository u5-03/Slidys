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

## Metal experiment (after baseline b820c56)

The baseline is pushed to codex/saitama-swift-3d-quiz. The Metal experiment is separate working-tree changes.

- UIKit drawHierarchy writes directly into a BGRA CVPixelBuffer backed by an IOSurface.
- A CVPixelBufferPool reuses buffers with an allocation threshold of 3. A busy producer drops work rather than allocating without bound.
- CVMetalTextureCache exposes that buffer to Metal. This avoids UIImage generation; it does NOT eliminate UIKit capture or guarantee end-to-end zero-copy.
- One immutable frame is referenced by both output render passes; the CVPixelBuffer AND CVMetalTexture wrapper are retained through GPU completion.
- Each output uses CAMetalLayer, with two drawable buffers and aspect-fit rendering. Display drawables remain separate resources per output.
- GPU submission runs on a serial worker. There is no waitUntilCompleted on the main thread.
- At most two GPU submissions are in flight; source capture remains on the main actor.
- Starts at 30fps. Every two seconds, choose a divisor of the lower of the source and fastest output maximum refresh rates, using 1.5 times the smoothed capture cost as the CPU budget. A 15fps floor applies on supported displays. Actual delivered fps may be lower; device/OS refresh policies still apply.
- An incomplete UIKit capture is counted and forwarded as partial, instead of freezing the entire slide. This does not restore video pixels that WebKit omits.

Diagnostics retain [PresenterCapture]. `backend=metal`, `targetFPS`, `busyDrops`, `inFlight`, `gpuFrames`, `gpuFailures`, and `meanSubmitToCompleteMS` distinguish capture from asynchronous presentation. The latter includes worker/drawable wait and GPU completion latency, not GPU execution time alone. `meanRenderMS` remains CPU-side capture cost. `frameBytes` describes the retained latest frame, not the whole pool or display drawables. The pool can retain up to three full-size frames and GPU outputs allocate their own drawable surfaces.

Xcode Preview verified Metal command completion and the pool's fourth concurrent allocation being refused. UIKit drawHierarchy returned incomplete on the Preview's initial presentation, so image orientation, actual external output, RealityView/video content, and performance improvement are NOT verified by that check. Validate these on a physical device before distributing this experiment.

## Recovery after closing notes

Temporary output hiding during SwiftUI transitions no longer stops the producer permanently.
Registering an eligible source also restarts a stopped producer even if the output view was reused.
The source hosting controller re-registers on updates when attached to a supported scene.
Output sizing now uses the local slide bounds (the same space used for capture); it does not reject a scaled hosting view just because its converted rect is outside UIWindow bounds.
`partial-slide-frame-forwarded` identifies UIKit snapshots that are incomplete. They no longer freeze all output, but WebKit video pixels may still be absent. Device logs and observations are required to distinguish these cases.

## ScreenCaptureKit + Metal experimental mode

### Stage routing: HDMI + Duo + presenter notes

Treat Duo as a near-mandatory output. The primary menu actions now preserve it:

| Action | HDMI | Duo outer | Inner | Capture |
| --- | --- | --- | --- | --- |
| 外部にスライド・手元にノート（通常） | Direct slide render | Direct slide render if Duo was enabled | Notes with noninteractive thumbnails | None |
| 操作デモ（Duo維持・試験） | Shared cropped stream | Same shared cropped stream; Duo stays enabled | Interactive current slide in notes | Full-display ScreenCaptureKit, unverified on Duo |
| その他・緊急用 → HDMIのみでデモ（Duo停止） | Request OS mirroring by disabling the external scene accessory and releasing its window | Off | Single interactive slide | None |

The emergency action is explicit, not the default stage plan. Returning to normal output resets capture to independent and restores Duo if the emergency action suspended it. The ordinary action does not start Duo if it wasn't running; enable outer-slides mode through the Duo menu first.

The previous $preferredMode subscriber invoked applyMode() while reading the old published value. Applying mode changes now happens in didSet. Scene-accessory availability is tracked separately from connected scene delegates so the external-display menu can remain available while the accessory is disabled. Rendering updates only publish connection changes when the value actually changes.

Checked locally: native build, Xcode-executed coordinator transitions without an active camera, pure routing assertions for the configurations above, and an Xcode Preview snapshot of the actual external-display menu items. Physical HDMI fallback to OS mirroring, simultaneous HDMI/Duo performance, camera/accessory lifecycle, Tweet playback, audio and menu exclusion are NOT verified by these checks.

For hardware acceptance, run the same 30-second taiyaki manipulation and Tweet play/pause sequence (a) with HDMI only, (b) with HDMI plus Duo; keep the full-display experimental mode explicit, record [PresenterCapture] logs, and inspect both displays. Require actual correct images on both displays, responsive local input, no capture fallback, no growing memory/failures, and at least 30 forwarded/completed fps during motion. Also open the menu: full-display capture still includes intersecting overlays. That requirement remains unresolved. Do not call this stage-ready until these physical checks pass.

**Current experiment (2026-11-20):** use **手元の操作を映す（画面全体・試験）**. The picker now calls `present()` for full-display capture, following Apple's iOS sample. Earlier in-app/window-picker attempts and automatic fallback described below are historical. This revision does **not** automatically switch to bitmap capture on failure. It reports `system failed ... automaticFallback=false`; select the old mode explicitly if needed. This distinction is essential for evaluating performance.

Full-display crops use the slide's screen coordinates (`UIWindow.convert(...to: screen.coordinateSpace)`) and validate against that screen's bounds, not the UIWindow's local bounds. Add `NSScreenCaptureUsageDescription` for the native Slidys target. Background capture and microphone capture are not enabled; this path is intended for foreground presentation.

Local checks: native Slidys build passed; Xcode Preview of the output-mode labels checked; actual Core Image/Metal output pixels verified on the Mac GPU for all eight EXIF orientations. The GPU check uses synthetic BGRA input and verifies off-center crop coordinates. It does not verify iOS YUV input, Duo source selection, WebKit video, audio or device refresh rate.

### One device acceptance run before the presentation

1. Connect Duo output and select the full-display experimental mode. Complete the system sharing picker. The log must say `selection=full-display revision=full-display-v1`.
2. Show a recognizably different current slide from the audience/status screen. Confirm the correct inner slide appears on the output. Require `system first-frame-forwarded` and `stats backend=screencapturekit`; absence of these is a failure, not a performance result.
3. Rotate/zoom taiyaki continuously for 30 seconds. Aim for at least 30 `forwardedFPS` and `completedFPS` over several five-second intervals, no GPU failures and acceptable hand-held smoothness. These are processing/presentation completion rates, not a physical display measurement. Static slides may legitimately emit fewer frames.
4. Play, pause, resume and seek the Tweet video from the inner screen. Confirm matching video imagery and behavior on the output, with no separately started player. Check audio separately if the talk requires it; this revision does not forward captured audio.
5. Hide/show notes, rotate the device, change slides and return to both demos. Repeat with HDMI if HDMI will be used on stage. Observe five minutes for freeze, persistent memory growth or poor response.
6. Open/close the presenter menu. Full-display capture can include overlays that intersect the slide crop. This remains a known limitation and must be assessed for the presentation.

Decision: if source selection, video or smoothness fails this run, do not use this experimental capture path on stage. Use normal direct rendering / OS mirroring for the interactive demo, accepting the presenter-mode switch. Bitmap capture has already measured about 7–8.5fps and omitted Tweet video, so it is not a quality fallback for this demo. Sharing RealityKit state or separately synchronizing WebKit players is a larger change and is not part of this final capture experiment.

For the current revision, ScreenCaptureKit GPU completion/failure counts and submit-to-completion time are interval metrics, reset every five seconds. `completedFPS` measures completed processing/presentation jobs, not per-output refresh. Log the entire run with `[PresenterCapture]` from picker entry through closing the demo.

Select **手元の操作を映す（高fps・試験）** from the slide output picker. Existing capture modes remain available. iOS 27+ presents the system current-application sharing picker. It may require consent even when the older bitmap mode did not. Use **画面共有を選び直す** to retry after cancellation or a source mismatch.

Pipeline: SCStream -> bounded latest-packet inbox -> coordinate/orientation validation -> off-main Core Image GPU crop/rotation/YUV conversion -> shared BGRA Metal frame -> HDMI/Duo. It does NOT call drawHierarchy. At most two processing/presentation jobs are in flight, the crop output pool has an allocation threshold of three, and pending inbox frames replace older ones.

SDK constraints verified in iPhoneOS27.1 SCStream.h and SCContentSharingPicker.h:
- iOS has no init(desktopIndependentWindow:), display/window exclusions or shareable-window enumeration.
- sourceRect, pixelFormat, queueDepth and minimumFrameInterval are unavailable on iOS. Actual delivery cadence and source pixel format are OS-controlled; do not promise 60/120fps.
- Use presentForCurrentApplication() after making the interactive source window key. This is not a guarantee that a particular Scene is selected.

Frame metadata is used instead of stretching any received image into the expected window:
- contentRect * scaleFactor * contentScale maps content points to the raw surface.
- videoOrientation is applied before cropping; all eight EXIF orientations are covered by pure geometric checks.
- screenRect (or filter.contentRect as fallback) is compared to the source UIWindow dimensions, including axis swapping when explicitly indicated by EXIF orientation.
- Previously observed outer 678x466 vs inner 669x951 is rejected, and an actionable status is displayed instead of silently outputting the wrong crop.

Dimension matching is necessary but NOT sufficient to prove Scene identity: two same-sized windows remain ambiguous. A stronger source identity mechanism and physical-device validation remain required before making this the default.

IMPORTANT: this path crops an OS capture of the app, not the isolated slide subtree. A menu/modal covering the slide can re-enter the capture. Full prevention of that overlay has not been implemented for this experimental mode. The existing subtree bitmap mode remains the option when menu exclusion is required. This is a known experimental limitation, not a verified fix for every slide/media type.

Logs: [PresenterCapture] system status/start, raw buffer/content/scale/orientation on rejection, and backend=screencapturekit stats. consumedFPS counts packets delivered after the latest-packet mailbox, forwardedFPS counts cropped submissions; neither proves distinct displayed frames. meanCropMS includes GPU conversion on its worker, not main-thread snapshot time. Actual device display, WebView video reproduction, same-sized Scene selection, memory and hand-held smoothness are unverified until measured on hardware.

### Physical-device log collection

Filter the Xcode console by `[PresenterCapture]`. Collect from before selecting the experimental mode until after the problem, including about 10 seconds of continuous model rotation or video playback. Include switching notes, rotating the device and changing HDMI/Duo modes if relevant.

- `system request`: app/build/OS and requested source geometry/Scene role.
- `system geometry`: emitted when crop, orientation, resolution or destinations change.
- `system first-frame-forwarded`: confirms the first GPU crop was submitted for display, not proof that the physical monitor displayed it.
- `system heartbeat`: every five seconds even when no valid frame is forwarded. `packetAgeSeconds` and `forwardedAgeSeconds` distinguish stream silence from downstream rejection; `never` means nothing received/forwarded yet. Non-complete statuses can include normal idle frames on static slides. Thermal state is nominal=0/fair=1/serious=2/critical=3.
- `stats backend=screencapturekit`: interval consumed/forwarded fps and crop time. GPU completion/failure counts and mean submit-to-completion time are cumulative renderer metrics; they include drawable/worker waits, not just GPU execution.
- Every diagnostic includes process footprint/available memory. Geometry contains coordinates only; image pixels, tweet content and camera images are not logged.

### iOS device findings (2026-11-20)

Device logs showed complete frames with contentRect/scaleFactor/screenRect but no videoOrientation key. A missing orientation now means delivered surface coordinates (EXIF up), logged as orientationSource=surface. Explicit metadata is still honored. Window-size/axis validation remains in place; this does not prove 180-degree orientation when metadata is absent.

The current-application picker repeatedly returned 678x466 (or 466x678) while the presenter window was 669x951. Making the window key did not solve this. A subsequent device test confirmed present(using: .window) is rejected as unsupported on iOS despite compiling. This change was reverted to presentForCurrentApplication(). Picker/stream failures now switch output to the existing bitmap Metal mode. A continuous geometry mismatch also falls back after one second, allowing transient rotation frames to settle. Logs identify this with system fallback backend=metal reason=... . This restores the previous output path; it does not solve high-fps inner-Scene acquisition or missing WebKit video pixels in that path. A wrong-size stream remains rejected rather than stretching/cropping the accessory output as though it were the presenter window.


## 2026-11-20: source rendering and implicit capture audit

Physical-device diagnostics showed a RealityView drawable of 5401x2401 pixels
inside a slide whose final on-screen region was roughly 867x488 points. The
console repeatedly reported CAMetalLayer allocation failures. The model entity
had been added and the SwiftUI anchors remained visible, so a missing model file
was not the only explanation. RealityView layout now budgets its native surface
to a maximum edge of 1920 pixels before the outer slide transform. Apply this to
both taiyaki focus and the summoned quiz scene. Confirm actual drawable geometry
with `[PresenterCapture] metal-surface`; calculated budget is not runtime proof.

The same log showed ~8 fps and ~118 ms snapshots with outputMode=independent and
Duo stopped. Interactive-slide protocol conformance had silently opted HDMI into
bitmap capture. That implicit selection is removed. HDMI-only mirroring with
independent output now disables the scene accessory and requests OS mirroring;
Duo-active bitmap mirroring remains explicitly labeled and retains its known
performance/video limitations. `[PresenterCapture] transport-check` reports the
requested/effective route and actual OS mirror inventory.

Transient RealityView disappearance no longer detaches the pivot from its scene.
Tweet thumbnails no longer create live WebViews. Live Tweet playback is inline,
without AirPlay/PiP redirection; this setting does not make WebKit video available
to drawHierarchy. System capture still requires separate physical validation,
including source selection and menu exclusion. No claim of validated three-screen
video playback is made by these changes.


### Outer copy: prioritize inner display and HDMI (2026-11-20)

When independent output uses HDMI OS mirroring and Duo mirroredSlides, outer
bitmap acquisition is capped at 2 requested fps. After each capture, enforce an
absolute cooldown of max(0.5 seconds, 4 * actual capture duration), including
watchdog callbacks. This limits measured snapshot work to approximately 20% of
capture+quiet time instead of continuously blocking the main thread. Actual
transfer frequency is typically lower than 2fps. No source/HDMI downsampling is
introduced; their OS mirroring route is unchanged. Each individual snapshot can
still cause a hitch; this is load reduction, not asynchronous UIView capture.

Stats include presenterPriority, throttleSkips, and quietPeriodMS. Verify physical
smoothness separately: transmitted fps does not measure source or HDMI refresh.
