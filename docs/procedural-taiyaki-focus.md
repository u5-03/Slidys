# Swift生成たい焼きの部位フォーカス

iOSDC2026のAstra版は`TaiyakiEntity.make()`がSwiftで頂点・UV・三角形・法線、テクスチャ画素を生成し、`MeshDescriptor`から`MeshResource`を作る。Body / Tail / DorsalFin / Eye / LogoなどのModelEntityを通常のEntityの子に追加する。USDZやBlenderのEmptyには依存しない。

この階層に`Anchor_Eye`などの名前を付けた空のEntityを追加し、TaiyakiFocusViewのモデルソースをproceduralにすると、Blender版と同じ射影・＋ボタン・pivotのTransform補間を利用できる。ここでいうアンカーはモデル内の目印であり、ワールド追跡用のAnchorEntityではない。

現在は目・尾びれ・背びれ・焼印の4か所。部位Entityの境界の中心XYと正面側Zから位置を求める簡易版で、意味的な部位の自動検出ではない。必要なら生成関数が持つ設計座標や表面評価関数から、さらに正確な点と表面法線を返す方式へ変更できる。生成版はあんこのみなので具材切り替えUIは出さない。

## 確認

2026-11-07、Xcode MCP RunCodeSnippetで実際のTaiyakiEntity.make()を実行。

- 13 ModelEntity / 89,584三角形。
- 4つの名前付きEntityが存在し、正規化後のpivot座標を取得できた。
- 既存のフォーカス式 `target - rotation.act(local * scale)` を適用し、各アンカーがtargetに移動することをpreconditionで確認。誤差は最大約5.3e-8。
- Slidysのビルド成功。
- Xcode Previewのキャプチャは非同期生成前の黒画面。Simulatorを起動したがUI操作ツールがwindowNotFoundAtPositionを返し、＋タップ・解除・回転の目視検証は未完了。

Saitamaデッキの「モデルの目印を、UIの入り口にする」の直後にデモ・説明を追加。
