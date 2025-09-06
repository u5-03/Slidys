# GestureDetector アーキテクチャ詳解

## 概要
`UnifiedGestureDetector`は、多数のジェスチャーを効率的に検出するために設計された高性能ジェスチャー認識システムです。

## システム構成図

```
┌─────────────────────────────────────────────────────────────┐
│                    UnifiedGestureDetector                     │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐  ┌──────────────┐  ┌───────────────┐  │
│  │ Gesture Registry │  │ Index System │  │ Search Engine │  │
│  │                 │  │              │  │               │  │
│  │ • Priority Sort │  │ • Type       │  │ • Early Exit  │  │
│  │ • Registration  │  │ • Type       │  │ • Filtering   │  │
│  │                 │  │              │  │ • Statistics  │  │
│  └─────────────────┘  └──────────────┘  └───────────────┘  │
└─────────────────────────────────────────────────────────────┘
                               ↓
                    ┌──────────────────┐
                    │ Detection Result │
                    │                  │
                    │ • Success/Error  │
                    │ • Confidence     │
                    │ • Metadata       │
                    └──────────────────┘
```

## 1. 効率化メカニズム

### 1.1 優先度ベースの検索順序

```swift
// ジェスチャーは優先度順にソートされる
sortedGestures = gestures.sorted { $0.priority < $1.priority }
```

**動作原理:**
- 優先度の数値が小さいほど先に検査される
- 頻繁に使用されるジェスチャーを高優先度に設定
- 最初にマッチしたジェスチャーで検索を早期終了可能

**例:**
```
優先度 10: ピースサイン（頻出）
優先度 20: サムズアップ（頻出）
優先度 50: ポインティング
優先度 100: 特殊ジェスチャー
```

### 1.2 インデックスシステム

#### タイプインデックス
```swift
private var typeIndex: [GestureType: [Int]] = [:]
```

**構造例:**
```
singleHand: [0, 1, 2, 3, 4, 5]  // 片手ジェスチャーのインデックス
twoHand: [6, 7, 8, 9]           // 両手ジェスチャーのインデックス
```

### 1.3 検索フローの最適化

```
入力: handEntities
  ↓
[1] エンティティから手のデータを抽出
  ↓
[2] 検索対象の絞り込み
  • targetGestures指定 → 指定ジェスチャーのみ
  • タイプ指定 → タイプインデックスから取得
  • デフォルト → 全ジェスチャー（優先度順）
  ↓
[3] ジェスチャーマッチング
  • 優先度順にチェック
  • maxResults到達で早期終了
  ↓
[4] 結果の返却
  • DetectedGesture配列
  • エラー情報
```

## 2. 検出アルゴリズム詳細

### 2.1 基本検出フロー

```swift
public func detectGestures(
    from handEntities: [Entity],
    targetGestures: [BaseGestureProtocol]? = nil
) -> GestureDetectionResult {
    // 1. 手のデータ抽出
    let (leftHand, rightHand) = extractHandComponents(handEntities)
    
    // 2. ジェスチャーデータ作成
    let gestureData = createGestureData(leftHand, rightHand)
    
    // 3. 検索実行
    let gesturesToCheck = targetGestures ?? sortedGestures
    var detectedGestures: [DetectedGesture] = []
    
    for gesture in gesturesToCheck {
        if matchesGesture(gesture, gestureData) {
            detectedGestures.append(createDetectedGesture(gesture))
            
            // 早期終了チェック
            if shouldEarlyExit(detectedGestures) {
                break
            }
        }
    }
    
    return .success(detectedGestures)
}
```

### 2.2 カテゴリ別検出

```swift
detectGesturesByCategory(
    categories: [.pointing, .counting],
    maxResultsPerCategory: 3
)
```

**処理フロー:**
```
1. カテゴリごとにループ
   ↓
2. categoryIndex[category]から該当インデックスを取得
   例: pointing → [0, 5, 8]
   ↓
3. インデックスに対応するジェスチャーのみをチェック
   sortedGestures[0], sortedGestures[5], sortedGestures[8]
   ↓
4. カテゴリごとに最大数まで収集
```

## 3. パフォーマンス最適化戦略

### 3.1 早期終了条件

```swift
if let maxResults = maxResults, results.count >= maxResults {
    break  // 必要数に達したら即終了
}
```

### 3.2 不要な計算の回避

```swift
// 片手ジェスチャーで両手データがない場合はスキップ
if gesture.gestureType == .twoHand && handsGestureData == nil {
    continue
}
```

### 3.3 統計情報による最適化

```swift
public struct SearchStats {
    searchCount: Int        // 総検索回数
    gesturesChecked: Int    // チェックしたジェスチャー数
    matchesFound: Int       // マッチした数
    averageSearchTime: TimeInterval
}
```

**活用例:**
- マッチ率が低いジェスチャーの優先度を下げる
- 平均検索時間が長いカテゴリを特定して最適化

## 4. 実装例：100個のジェスチャーを効率的に処理

### シナリオ：手話認識システム

```swift
// ジェスチャーの登録（優先度付き）
let gestures: [BaseGestureProtocol] = [
    // 頻出文字（優先度: 1-20）
    LetterA(priority: 1),
    LetterE(priority: 2),
    LetterI(priority: 3),
    
    // 数字（優先度: 21-40）
    Number1(priority: 21),
    Number2(priority: 22),
    
    // 単語（優先度: 41-100）
    WordHello(priority: 41),
    WordThankYou(priority: 42),
    
    // 特殊記号（優先度: 101+）
    SpecialSymbol1(priority: 101),
    // ... 合計100個
]

// カテゴリ別検索で効率化
let result = detector.detectGesturesByCategory(
    from: handEntities,
    categories: [.letters],  // 文字カテゴリのみ検索
    maxResultsPerCategory: 1
)
```

### パフォーマンス比較

**最適化なし（線形検索）:**
- 平均チェック数: 50個（全100個の中央値）
- 最悪ケース: 100個すべてチェック

**最適化あり:**
- カテゴリフィルタ使用時: 平均10-20個
- 優先度＋早期終了: 平均5-15個
- 高優先度ジェスチャーのみ: 平均3-5個

## 5. 拡張ポイント

### 5.1 動的優先度調整
```swift
// 使用頻度に基づいて優先度を自動調整
func adjustPriorities(basedOn usageStats: [String: Int]) {
    // 実装例
}
```

### 5.2 機械学習との統合
```swift
// 信頼度スコアによる事前フィルタリング
func prefilterWithML(handData: HandData) -> [GestureCategory] {
    // MLモデルで可能性の高いカテゴリを予測
}
```

### 5.3 並列処理
```swift
// カテゴリごとに並列検索
func detectGesturesParallel(categories: [GestureCategory]) {
    // DispatchQueueで並列化
}
```

## まとめ

`UnifiedGestureDetector`の効率性は以下の要素の組み合わせにより実現されています：

1. **優先度ソート** - 頻出ジェスチャーを先にチェック
2. **インデックスシステム** - カテゴリ/タイプで高速フィルタリング
3. **早期終了** - 必要十分な結果で即座に処理終了
4. **統計情報** - パフォーマンスの継続的な監視と最適化

これにより、数百のジェスチャーがある環境でも、リアルタイム（60fps）での認識が可能になります。