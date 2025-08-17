# ジェスチャー実装ガイド

## 概要
このガイドでは、統合ジェスチャー検出システムに新しいジェスチャーを追加する方法を説明します。

## システムアーキテクチャ

### プロトコル階層
```
BaseGestureProtocol
├── SingleHandGestureProtocol (片手ジェスチャー)
└── TwoHandGestureProtocol (両手ジェスチャー)
```

### 統合検出フロー
1. `HandGestureTrackingSystem` がエンティティを収集
2. `UnifiedGestureDetector` がジェスチャーを検出
3. `GestureInfoStore` が結果を保存
4. `GestureInfoWindow` が結果を表示

## 片手ジェスチャーの実装例

### 例1: ロックサイン（人差し指と小指を伸ばす）
```swift
import Foundation

public struct RockSignGesture: SingleHandGestureProtocol {
    public var gestureName: String { "Rock Sign" }
    public var description: String { "人差し指と小指を伸ばすロックサイン" }
    public var priority: Int { 50 }
    public var category: GestureCategory { .gesture }
    
    public init() {}
    
    public func matches(_ gestureData: SingleHandGestureData) -> Bool {
        // 人差し指と小指が伸びている
        guard gestureData.isFingerStraight(.index),
              gestureData.isFingerStraight(.little) else {
            return false
        }
        
        // 他の指は曲がっている
        guard gestureData.isFingerBent(.thumb),
              gestureData.isFingerBent(.middle),
              gestureData.isFingerBent(.ring) else {
            return false
        }
        
        return true
    }
}
```

### 例2: OKサイン（親指と人差し指で輪を作る）
```swift
public struct OKSignGesture: SingleHandGestureProtocol {
    public var gestureName: String { "OK Sign" }
    public var description: String { "親指と人差し指で輪を作るOKサイン" }
    public var priority: Int { 60 }
    public var category: GestureCategory { .gesture }
    
    public init() {}
    
    public func matches(_ gestureData: SingleHandGestureData) -> Bool {
        // 親指と人差し指の先端が近い（3cm以内）
        guard let thumbTip = gestureData.getJointPosition(.thumbTip),
              let indexTip = gestureData.getJointPosition(.indexFingerTip) else {
            return false
        }
        
        let distance = simd_distance(thumbTip, indexTip)
        guard distance < 0.03 else { return false }
        
        // 他の3本の指は伸びている
        return gestureData.isFingerStraight(.middle) &&
               gestureData.isFingerStraight(.ring) &&
               gestureData.isFingerStraight(.little)
    }
}
```

## 両手ジェスチャーの実装例

### 例1: タイムアウトサイン（両手でT字を作る）
```swift
public struct TimeoutGesture: TwoHandGestureProtocol {
    public var gestureName: String { "Timeout" }
    public var description: String { "両手でT字を作るタイムアウトサイン" }
    public var priority: Int { 40 }
    public var category: GestureCategory { .gesture }
    
    public init() {}
    
    public func matches(_ gestureData: HandsGestureData) -> Bool {
        // 片手は垂直（手のひらが正面）
        let verticalHand = gestureData.leftHand
        guard verticalHand.isPalmFacing(.forward) else { return false }
        
        // もう片手は水平（手のひらが下向き）
        let horizontalHand = gestureData.rightHand
        guard horizontalHand.isPalmFacing(.down) else { return false }
        
        // 両手の距離が適切（10-20cm）
        let distance = gestureData.palmCenterDistance
        guard distance > 0.10 && distance < 0.20 else { return false }
        
        // 垂直の手の上に水平の手がある
        guard let verticalPos = gestureData.getJointPosition(hand: .left, joint: .wrist),
              let horizontalPos = gestureData.getJointPosition(hand: .right, joint: .wrist) else {
            return false
        }
        
        return horizontalPos.y > verticalPos.y
    }
}
```

## ジェスチャーの登録方法

### 1. ジェスチャーをファイルに実装
`Implementations/` ディレクトリに新しいファイルを作成：
```
Packages/HandGesturePackage/Sources/HandGesturePackage/Implementations/RockSignGesture.swift
```

### 2. HandGestureTrackingSystemに追加
```swift
private static var unifiedDetector: UnifiedGestureDetector = {
    let gestures: [BaseGestureProtocol] = [
        // 既存のジェスチャー
        PeaceSignGesture(),
        ThumbsUpGesture(),
        // 新しいジェスチャーを追加
        RockSignGesture(),
        OKSignGesture(),
        TimeoutGesture()
    ]
    return UnifiedGestureDetector(gestures: gestures)
}()
```

### 3. 動的にジェスチャーを追加（オプション）
```swift
// 実行時にジェスチャーを追加
let customGestures: [BaseGestureProtocol] = [
    RockSignGesture(),
    OKSignGesture()
]
HandGestureTrackingSystem.targetGestures = customGestures
```

## パフォーマンス最適化のヒント

### 1. 優先度の設定
- 頻繁に使用されるジェスチャーには低い優先度値（高優先度）を設定
- 複雑な計算を含むジェスチャーには高い優先度値（低優先度）を設定

### 2. カテゴリの活用
```swift
// 特定カテゴリのみを検索
let pointingGestures = unifiedDetector.detectGesturesByCategory(
    from: handEntities,
    categories: [.pointing]
)
```

### 3. 早期リターン
```swift
public func matches(_ gestureData: SingleHandGestureData) -> Bool {
    // 最も基本的な条件から確認
    guard gestureData.isFingerStraight(.index) else { return false }
    
    // より複雑な計算は後で
    let distance = calculateComplexDistance()
    return distance < threshold
}
```

## デバッグとテスト

### ジェスチャーの確認
1. アプリを実行
2. GestureInfoWindowで検出結果を確認
3. パフォーマンス統計を監視

### ログ出力
```swift
public func matches(_ gestureData: SingleHandGestureData) -> Bool {
    let result = performMatching(gestureData)
    
    if result {
        print("🎯 \(gestureName) が検出されました")
    }
    
    return result
}
```

## ベストプラクティス

1. **シンプルな条件から始める**: 基本的な指の状態から確認
2. **適切な閾値を使用**: 距離は0.03-0.05m（3-5cm）が一般的
3. **エラーハンドリング**: nilチェックを忘れずに
4. **ドキュメント化**: ジェスチャーの説明を明確に
5. **テスト**: 様々な手の大きさ・角度でテスト

## 今後の拡張

このシステムは以下のような用途に拡張可能です：
- 手話認識（多数のジェスチャーセット）
- ゲームコントロール（動的ジェスチャー）
- UIインタラクション（精密な手の動き）
- 教育アプリケーション（ジェスチャー学習）