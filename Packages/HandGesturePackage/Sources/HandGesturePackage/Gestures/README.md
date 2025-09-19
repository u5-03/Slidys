# 効率的なジェスチャー検索システム

`SingleHandGestureData`をもとに、複数のジェスチャー定義から現在の手の状態に適合するものを高速で検索できるシステムです。

## 🎯 主な特徴

### パフォーマンス最適化
- **早期リターン**: 条件を満たさない場合に即座に判定終了
- **タイプ別検索**: 片手/両手ジェスチャーで検索範囲を絞り込み
- **優先度ソート**: 重要なジェスチャーを優先的に検索
- **統計監視**: 検索パフォーマンスの測定・監視

### 柔軟な設計
- **プロトコルベース**: 簡単にカスタムジェスチャーを追加可能
- **条件定義のみ**: データを持たず、条件のみを定義する軽量設計
- **複数検索方式**: 全検索、最初のマッチ、タイプ別検索をサポート

## 🏗️ アーキテクチャ

```
SingleHandGestureData
         ↓
   GestureDetector ←→ [Gesture Protocols]
         ↓                    ↓
   SearchResults        PeaceSignGesture
                       ThumbsUpGesture
                       CustomGesture...
```

## 📋 基本的な使用方法

### 1. ジェスチャー定義の作成

```swift
public struct PeaceSignGesture: SingleHandGestureProtocol {
    public init() {}
    
    // 識別情報
    public var gestureName: String { "ピースサイン" }
    public var priority: Int { 10 }
    
    // 効率的なマッチング実装
    public func matches(_ gestureData: SingleHandGestureData) -> Bool {
        // 早期リターンで最適化
        guard gestureData.isFingerStraight(.index) && 
              gestureData.isFingerStraight(.middle) else {
            return false
        }
        
        guard gestureData.isFingerBent(.thumb) && 
              gestureData.isFingerBent(.ring) && 
              gestureData.isFingerBent(.little) else {
            return false
        }
        
        return gestureData.isFingerPointing(.index, direction: .top) &&
               gestureData.isFingerPointing(.middle, direction: .top) &&
               gestureData.isPalmFacing(.forward)
    }
    
    // プロトコルメソッドでの条件定義（オプション）
    public var requiresOnlyIndexAndMiddleStraight: Bool { true }
    
    public func requiresFingerPointing(_ finger: FingerType, direction: GestureDetectionDirection) -> Bool {
        return (finger == .index || finger == .middle) && direction == .top
    }
    
    public func requiresPalmFacing(_ direction: GestureDetectionDirection) -> Bool {
        return direction == .forward
    }
}
```

### 2. 検索システムの設定

```swift
// ジェスチャー検出器を初期化
let gestureDetector = GestureDetector()

// ジェスチャーを登録
let gestures: [SingleHandGestureProtocol] = [
    PeaceSignGesture(),
    ThumbsUpGesture(),
    PointingGesture()
]
gestureDetector.registerGestures(gestures)
```

### 3. リアルタイム検索

```swift
// HandTrackingSystemで使用する例
func update(context: SceneUpdateContext) {
    for entity in handEntities {
        guard let handComponent = entity.components[HandTrackingComponent.self] else { continue }
        
        // SingleHandGestureDataを作成
        let gestureData = SingleHandGestureData(
            handTrackingComponent: handComponent,
            handKind: handComponent.chirality == .left ? .left : .right
        )
        
        // 高速検索（最大5個まで）
        let detectedGestures = gestureDetector.findMatchingGestures(
            for: gestureData,
            maxResults: 5
        )
        
        // 結果を処理
        if !detectedGestures.isEmpty {
            handleDetectedGestures(detectedGestures)
        }
    }
}
```

## 🔍 検索方式の種類

### 1. 基本検索

```swift
// すべてのマッチするジェスチャーを検索
let allMatches = gestureDetector.findMatchingGestures(for: gestureData)

// 最高優先度のジェスチャーのみ
let firstMatch = gestureDetector.findFirstMatchingGesture(for: gestureData)

// 最大結果数を制限
let limitedMatches = gestureDetector.findMatchingGestures(
    for: gestureData, 
    maxResults: 3
)
```

### 2. カテゴリ別検索

```swift
// 特定カテゴリのみを検索
let countingGestures = gestureDetector.findMatchingGestures(
    for: gestureData,
    in: .counting
)

// 複数カテゴリでの効率的検索
let results = gestureDetector.findMatchingGesturesByCategory(
    for: gestureData,
    in: [.counting, .pointing, .hand]
)
```

## 📊 パフォーマンス監視

```swift
// 検索統計をリセット
gestureDetector.resetSearchStats()

// 検索実行後に統計を確認
let stats = gestureDetector.searchStats
print("平均検索時間: \(stats.averageSearchTime * 1000)ms")
print("マッチ率: \(stats.matchRate * 100)%")
```

## 🎲 ジェスチャーカテゴリ

```swift
public enum GestureCategory: CaseIterable {
    case pointing        // 指差し系（人差し指、ポインティング）
    case counting        // 数字系（ピースサイン、3本指など）
    case hand           // 手全体系（握り拳、パーなど）
    case gesture        // 特殊ジェスチャー（サムズアップ、OKサインなど）
    case custom         // カスタムジェスチャー
}
```

## ⚡ パフォーマンス最適化のポイント

### 1. ジェスチャー定義での最適化

```swift
public func matches(_ gestureData: SingleHandGestureData) -> Bool {
    // ❌ 非効率: 重い処理を最初に実行
    // if complexCalculation() && simpleCheck() { ... }
    
    // ✅ 効率的: 軽い処理を最初に実行
    guard simpleCheck() else { return false }
    guard mediumComplexityCheck() else { return false }
    return complexCalculation()
}
```

### 2. 検索システムでの最適化

- **カテゴリ絞り込み**: 検索範囲を限定
- **最大結果数制限**: 必要以上の検索を避ける
- **優先度設計**: 重要なジェスチャーを低い値で設定

### 3. 利用シーンに応じた使い分け

```swift
// リアルタイム検索: 高速・制限あり
let quickResults = gestureDetector.findMatchingGestures(
    for: gestureData,
    in: .pointing,
    maxResults: 1
)

// 詳細分析: 精度重視・制限なし
let detailedResults = gestureDetector.findMatchingGesturesByCategory(
    for: gestureData,
    in: GestureDetector.allCategories
)
```

## 🔧 実装例

完全な使用例は `GestureDetectionExample.swift` を参照してください。

```swift
let example = GestureDetectionExample()
example.runAllExamples(handTrackingComponent: handComponent)
```

## 📈 パフォーマンス目標

- **検索時間**: < 1ms per gesture
- **メモリ使用量**: 軽量（ジェスチャー定義はデータを持たない）
- **CPU負荷**: 60FPSでのリアルタイム処理に対応

## 🚀 拡張性

新しいジェスチャーを追加する場合：

1. `SingleHandGestureProtocol` を実装
2. `matches()` メソッドで効率的な判定ロジックを実装
3. 適切な `priority` と `category` を設定
4. `GestureDetector` に登録

システムは自動的に最適化された検索を提供します。 