# iOSDC Japan 2025: visionOSハンドトラッキングで実現する手話認識システム - その可能性と限界

## はじめに

iOSDC Japan 2025で「手話ジェスチャーの検知と翻訳 〜ハンドトラッキングの可能性と限界〜」というタイトルで登壇させていただきます。このセッションでは、visionOSのハンドトラッキング機能を使用したリアルタイム手話ジェスチャー認識の技術的な実装について、その可能性と現実的な制約の両面から深く掘り下げていきます。

Appleの最新空間コンピューティングプラットフォームを活用し、物理的なジェスチャーとデジタルコミュニケーションの架け橋となる、意味のあるジェスチャーベースのインタラクションの実現方法をデモンストレーションします。

## ジェスチャー検出の実装アプローチ

本セッションで紹介するジェスチャー検出システムは、以下の3つのステップで実装しています：

### 1. 手のトラッキングシステムを初期化する
- **ARKitSessionで権限リクエスト**: Info.plistへ利用目的の追記が必要
- **SpatialTrackingSessionで.handを有効化**: visionOS 2.0の新機能を活用

### 2. 手の関節の位置や向きなどの情報を取得する
- **HandSkeletonの必要な関節を選定**: 27個の関節から必要なものを選択
- **AnchorEntityを設定し、各関節をリアルタイム追跡**: 自動的に関節位置を更新
- **Component経由でEntityの各関節の位置や向きを取得**: ECSパターンでデータアクセス

### 3. 関節情報からジェスチャーを判定する
- 各関節の位置や向きから、ジェスチャーの条件に一致するかどうかを判定
- プロトコル指向設計により、新しいジェスチャーの追加が容易

## 開発環境と前提条件

### 必要な環境

このセッションで紹介する実装には、以下の開発環境が必要です：

- **Xcode**: 16.2以降
- **visionOS**: 2.0以降（AnchorEntityはvisionOS 2.0で導入）
- **Swift**: 6.0
- **実機**: Apple Vision Pro（シミュレータでは手のトラッキングが制限されます）

### 重要な依存関係

```swift
import ARKit        // SpatialTrackingSession
import RealityKit   // AnchorEntity, Entity-Component-System
import SwiftUI      // UI構築
```

**注意**: `AnchorEntity`はvisionOS 2.0以降でのみ利用可能です。visionOS 1.xでは代替実装が必要になります。

## セッション概要

### 学べること

このセッションでは、visionOS向けジェスチャー認識システムの構築について、以下の内容を包括的にカバーします：

1. **ハンドトラッキングの基礎**: visionOSのSpatialTrackingSessionとAnchorEntityの理解
2. **ジェスチャー検出アーキテクチャ**: 柔軟でプロトコル指向のジェスチャー検出システムの構築
3. **実践的な実装**: バリデーション付き手話ジェスチャーの実装
4. **パフォーマンス最適化**: 90Hzでのリアルタイムジェスチャー処理戦略
5. **制限事項と回避策**: 空間ハンドトラッキングの課題への対処

### 対象者

このセッションは以下のようなiOS/visionOS開発者を対象としています：
- SwiftUIとRealityKitの基本的な知識を持っている方
- 空間コンピューティングとジェスチャーベースインターフェースに興味がある方
- ハンドトラッキング実装の実践的な側面を理解したい方
- ヒューマンコンピュータインタラクションの未来に関心がある方

## HandSkeletonの仕組み

### HandSkeletonとは

ARKitが提供する手の骨格モデルで、27個の関節点（ジョイント）で構成されています。これにより、手の形状を高精度で追跡できます。

### 取得可能な関節情報

- **手首（wrist）**: 手の基準点
- **各指の関節**: 
  - metacarpal（中手骨）
  - proximal（基節骨）
  - intermediate（中節骨）
  - distal（末節骨）
  - tip（指先）
- **前腕（forearmArm）**: 腕の向きを判定

### 各関節から取得できるデータ

```swift
// 位置情報（SIMD3<Float>）
let position = joint.position

// 向き情報（simd_quatf）
let orientation = joint.orientation

// 親関節からの相対位置
let relativePosition = joint.relativeTransform
```

### 座標系

- **右手系座標**: 右:+X、上:+Y、手前:+Z
- **単位**: メートル
- **原点**: デバイスの初期位置を基準

## RealityKitとECS（Entity-Component-System）

### ECSアーキテクチャの基本

RealityKitは、ECSパターンを採用した3Dレンダリングフレームワークです：

#### 1. Entity（エンティティ）
3D空間のオブジェクトを表現します。球体、文字、手など、あらゆる3D要素がEntityです。

#### 2. Component（コンポーネント）
Entityに機能を付与します。見た目（ModelComponent）、動き（Transform）、物理演算（PhysicsBodyComponent）など。

#### 3. System（システム）
特定のComponentを持つEntityを毎フレーム処理します。ゲームループの中核となる部分です。

### RealityViewの基本構造

```swift
RealityView { content in
    // ルートEntityを作成してシーンに追加
    let rootEntity = Entity()
    content.add(rootEntity)
    
    // 手のエンティティコンテナを作成
    let handEntitiesContainerEntity = Entity()
    rootEntity.addChild(handEntitiesContainerEntity)
}
```

### SpatialTrackingSessionで手の追跡を有効化

visionOS 2.0から導入されたAnchorEntityを使用した実装：

```swift
// 手の追跡を有効化
let session = SpatialTrackingSession()
let config = SpatialTrackingSession.Configuration(tracking: [.hand])
await session.run(config)

// AnchorEntityで関節を自動追跡
let anchorEntity = AnchorEntity(
    .hand(.left, location: .palm),
    trackingMode: .predicted  // 予測補正で追跡遅延を低減
)

// 追加するだけで自動追跡開始
handEntitiesContainerEntity.addChild(anchorEntity)
```

### 関節マーカーの作成と配置

```swift
// 球体マーカー用のEntityを作成
let sphere = ModelEntity(
    mesh: .generateSphere(radius: 0.005),
    materials: [UnlitMaterial(color: .yellow)]
)

// AnchorEntityに追加（関節に追従）
anchorEntity.addChild(sphere)
```

### HandGestureTrackingSystemの実装

カスタムSystemを作成して、毎フレーム手の状態を監視します：

#### 1. EntityQueryで手のEntityを取得

```swift
let handEntities = context.scene.performQuery(
    EntityQuery(where: .has(HandTrackingComponent.self))
)
```

#### 2. HandTrackingComponentから情報を抽出

```swift
for entity in handEntities {
    if let component = entity.components[HandTrackingComponent.self] {
        let chirality = component.chirality  // .left or .right
        let handSkeleton = component.handSkeleton
    }
}
```

#### 3. ジェスチャー検出処理

```swift
let detectedGestures = GestureDetector.detectGestures(
    from: handTrackingComponents,
    targetGestures: targetGestures
)
```

このSystemは`update(context:)`メソッドが毎フレーム自動的に呼ばれ、SceneUpdateContextから必要な情報を取得して処理を行います。

## 技術アーキテクチャ

### リポジトリ構成

プロジェクトは3つの主要パッケージで構成され、それぞれがジェスチャー認識パイプラインで特定の役割を担っています：

```
Slidys/
├── Packages/
│   ├── iOSDC2025Slide/       # Slidysフレームワークで構築したプレゼンテーション
│   ├── HandGestureKit/        # コアジェスチャー検出ライブラリ（OSS対応）
│   └── HandGesturePackage/    # アプリケーション固有の実装
```

### HandGestureKit: コアライブラリ

`HandGestureKit`はジェスチャー認識の基盤レイヤーとして機能します。任意のvisionOSプロジェクトに統合可能な、スタンドアロンのオープンソースライブラリとして設計されています。

#### 主要コンポーネント

**1. ジェスチャーデータモデル**

ライブラリはハンドトラッキングのための包括的なデータ構造を提供します：

```swift
public struct SingleHandGestureData {
    public let handTrackingComponent: HandTrackingComponent
    public let handKind: HandKind
    
    // ジェスチャー検出精度のための閾値設定
    public let angleToleranceRadians: Float
    public let distanceThreshold: Float
    public let directionToleranceRadians: Float
    
    // パフォーマンス最適化のための事前計算値
    private let palmNormal: SIMD3<Float>
    private let forearmDirection: SIMD3<Float>
    private let wristPosition: SIMD3<Float>
    private let isArmExtended: Bool
}
```

この構造体は必要なすべてのハンドトラッキングデータをカプセル化し、頻繁に使用される値を事前計算することで実行時のオーバーヘッドを最小化します。

**2. プロトコル指向設計**

ジェスチャーシステムはプロトコルの階層構造に基づいて構築されています：

```swift
// すべてのジェスチャーの基本プロトコル
public protocol BaseGestureProtocol {
    var id: String { get }
    var gestureName: String { get }
    var priority: Int { get }
    var gestureType: GestureType { get }
}

// 豊富なデフォルト実装を持つ片手ジェスチャープロトコル
public protocol SingleHandGestureProtocol: BaseGestureProtocol {
    func matches(_ gestureData: SingleHandGestureData) -> Bool
    
    // 指の状態要件
    func requiresFingersStraight(_ fingers: [FingerType]) -> Bool
    func requiresFingersBent(_ fingers: [FingerType]) -> Bool
    func requiresFingerPointing(_ finger: FingerType, direction: GestureDetectionDirection) -> Bool
    
    // 手のひらの向き要件
    func requiresPalmFacing(_ direction: GestureDetectionDirection) -> Bool
    
    // 腕の位置要件
    func requiresArmExtended() -> Bool
    func requiresArmExtendedInDirection(_ direction: GestureDetectionDirection) -> Bool
}
```

このプロトコル設計により、新しいジェスチャーを必要な条件だけをオーバーライドして簡単に追加できます。

**3. ジェスチャー検出エンジン**

`GestureDetector`クラスは、登録されたジェスチャーを優先度順に評価します：

```swift
public class GestureDetector {
    private var gestures: [BaseGestureProtocol] = []
    
    public func detect(from handData: SingleHandGestureData) -> [BaseGestureProtocol] {
        return gestures
            .sorted { $0.priority < $1.priority }
            .filter { gesture in
                guard let singleHandGesture = gesture as? SingleHandGestureProtocol else {
                    return false
                }
                return singleHandGesture.matches(handData)
            }
    }
}
```

### 実装例：手話ジェスチャー

#### 1. サムズアップジェスチャー

```swift
public class ThumbsUpGesture: SingleHandGestureProtocol {
    public var gestureName: String { "Thumbs Up" }
    public var priority: Int { 100 }
    
    // 親指だけが伸びている状態を要求
    public var requiresOnlyThumbStraight: Bool { true }
    
    // 親指が上を向いていることを要求
    public func requiresFingerPointing(_ finger: FingerType, direction: GestureDetectionDirection) -> Bool {
        return finger == .thumb && direction == .up
    }
}
```

**検出ロジックの詳細**

サムズアップジェスチャーの`matches`関数は、プロトコルのデフォルト実装を活用して以下の条件をチェックします：

```swift
// SingleHandGestureProtocolのデフォルト実装より
public func matches(_ gestureData: SingleHandGestureData) -> Bool {
    // 1. 親指だけが伸びているかチェック
    if requiresOnlyThumbStraight {
        // 内部では以下の条件を検証：
        // - 親指: isFingerStraight(.thumb) == true
        // - 人差し指: isFingerBent(.index) == true
        // - 中指: isFingerBent(.middle) == true
        // - 薬指: isFingerBent(.ring) == true
        // - 小指: isFingerBent(.little) == true
        guard isOnlyThumbStraight(gestureData) else { return false }
    }
    
    // 2. 親指が上を向いているかチェック
    if requiresFingerPointing(.thumb, direction: .up) {
        // 親指のベクトルと上方向ベクトルの角度を計算
        // angleToleranceRadians（デフォルト: π/4）以内なら真
        guard gestureData.isFingerPointing(.thumb, direction: .up) else { return false }
    }
    
    return true
}
```

**指の曲がり判定の実装**

```swift
// SingleHandGestureData内の判定ロジック
public func isFingerStraight(_ finger: FingerType) -> Bool {
    // 各指の関節角度を取得
    let jointAngles = getJointAngles(for: finger)
    
    // すべての関節が閾値以下の曲がり具合なら「伸びている」と判定
    return jointAngles.allSatisfy { angle in
        angle < straightThreshold // デフォルト: 30度
    }
}

public func isFingerBent(_ finger: FingerType) -> Bool {
    // 少なくとも1つの関節が閾値以上曲がっていれば「曲がっている」と判定
    let jointAngles = getJointAngles(for: finger)
    return jointAngles.contains { angle in
        angle > bentThreshold // デフォルト: 60度
    }
}
```

#### 2. ピースサイン

```swift
public class PeaceSignGesture: SingleHandGestureProtocol {
    public var gestureName: String { "Peace Sign" }
    public var priority: Int { 90 }
    
    // 人差し指と中指だけが伸びている状態を要求
    public var requiresOnlyIndexAndMiddleStraight: Bool { true }
    
    // 手のひらが前を向いていることを要求
    public func requiresPalmFacing(_ direction: GestureDetectionDirection) -> Bool {
        return direction == .forward
    }
}
```

**検出ロジックの詳細**

```swift
public func matches(_ gestureData: SingleHandGestureData) -> Bool {
    // 1. 人差し指と中指だけが伸びているかチェック
    if requiresOnlyIndexAndMiddleStraight {
        // 以下の条件をすべて満たす必要がある：
        // - gestureData.isFingerStraight(.index) == true
        // - gestureData.isFingerStraight(.middle) == true
        // - gestureData.isFingerBent(.thumb) == true
        // - gestureData.isFingerBent(.ring) == true
        // - gestureData.isFingerBent(.little) == true
        guard isOnlyIndexAndMiddleStraight(gestureData) else { return false }
    }
    
    // 2. 手のひらの向きをチェック
    if requiresPalmFacing(.forward) {
        // 手のひらの法線ベクトルを計算し、前方向との角度を確認
        let palmNormal = gestureData.palmNormal
        let forwardVector = SIMD3<Float>(0, 0, -1) // 前方向
        let angle = acos(dot(palmNormal, forwardVector))
        
        guard angle < directionToleranceRadians else { return false }
    }
    
    return true
}
```

#### 3. 祈りのジェスチャー（両手）

```swift
public class PrayerGesture: TwoHandGestureProtocol {
    public var gestureName: String { "Prayer" }
    public var priority: Int { 80 }
    
    public func matches(_ leftGestureData: SingleHandGestureData, _ rightGestureData: SingleHandGestureData) -> Bool {
        // 両手の手のひらが向かい合っている
        let palmsFacing = arePalmsFacingEachOther(leftGestureData, rightGestureData)
        
        // 両手が近い距離にある
        let handsClose = areHandsClose(leftGestureData, rightGestureData, threshold: 0.1)
        
        // すべての指が伸びている
        let fingersStraight = areAllFingersStraight(leftGestureData) && 
                              areAllFingersStraight(rightGestureData)
        
        return palmsFacing && handsClose && fingersStraight
    }
}
```

### ジェスチャー検出の実装を簡潔にする仕組み

#### プロトコルのデフォルト実装による簡潔性

HandGestureKitの最大の特徴は、プロトコルの豊富なデフォルト実装により、新しいジェスチャーを**最小限のコードで定義できる**ことです：

```swift
// 新しいジェスチャーの追加が非常に簡単
public class OKSignGesture: SingleHandGestureProtocol {
    public var gestureName: String { "OK Sign" }
    public var priority: Int { 95 }
    
    // 必要な条件だけを宣言的に定義
    public var requiresOnlyIndexAndThumbTouching: Bool { true }
    public var requiresMiddleRingLittleStraight: Bool { true }
}
```

この簡潔な定義だけで、複雑なジェスチャー検出ロジックが自動的に適用されます。

#### 条件の組み合わせパターン

よく使用される指の組み合わせは、専用のプロパティとして提供されています：

```swift
// 便利なプロパティ群
public protocol SingleHandGestureProtocol {
    // 複雑な指の条件（便利プロパティ）
    var requiresAllFingersBent: Bool { get }              // グー（全指曲げ）
    var requiresOnlyIndexFingerStraight: Bool { get }     // 人差し指だけ
    var requiresOnlyIndexAndMiddleStraight: Bool { get }  // ピース
    var requiresOnlyThumbStraight: Bool { get }           // サムズアップ
    var requiresOnlyLittleFingerStraight: Bool { get }    // 小指だけ
    
    // 手首の状態
    var requiresWristBentOutward: Bool { get }            // 手首を外側に曲げる
    var requiresWristBentInward: Bool { get }             // 手首を内側に曲げる
    var requiresWristStraight: Bool { get }               // 手首をまっすぐ
}
```

#### 検証ユーティリティ

`GestureValidation`クラスが、よく使用される検証パターンを提供：

```swift
public enum GestureValidation {
    // 特定の指だけが伸びているかを検証
    static func validateOnlyTargetFingersStraight(
        _ gestureData: SingleHandGestureData,
        targetFingers: [FingerType]
    ) -> Bool {
        for finger in FingerType.allCases {
            if targetFingers.contains(finger) {
                guard gestureData.isFingerStraight(finger) else { return false }
            } else {
                guard gestureData.isFingerBent(finger) else { return false }
            }
        }
        return true
    }
    
    // グーのジェスチャーを検証
    static func validateFistGesture(_ gestureData: SingleHandGestureData) -> Bool {
        return FingerType.allCases.allSatisfy { 
            gestureData.isFingerBent($0) 
        }
    }
}
```

## GestureDetectorの処理ロジック

### プロトコル階層

GestureDetectorは、階層化されたプロトコル設計により、様々な種類のジェスチャーを統一的に処理します：

```swift
protocol BaseGestureProtocol {
    var gestureName: String { get }
    var priority: Int { get }
    var gestureType: GestureType { get }
}

protocol SingleHandGestureProtocol: BaseGestureProtocol {
    func matches(_ gestureData: SingleHandGestureData) -> Bool
}

protocol TwoHandsGestureProtocol: BaseGestureProtocol {
    func matches(_ gestureData: HandsGestureData) -> Bool
}
```

### 検出アーキテクチャ

```swift
class GestureDetector {
    // 優先度順にソートされたジェスチャー配列
    private var sortedGestures: [BaseGestureProtocol]
    
    // シリアルジェスチャー専用トラッカー
    private let serialTracker = SerialGestureTracker()
    
    // タイプ別インデックス(高速検索用)
    private var typeIndex: [GestureType: [Int]]
}
```

### 便利な判定メソッド

`SingleHandGestureData`は、ジェスチャー判定を簡潔に記述できる便利メソッドを提供：

```swift
// SingleHandGestureDataで提供される便利メソッド
gestureData.isFingerStraight(.index)     // 人差し指が伸びているか
gestureData.isFingerBent(.thumb)         // 親指が曲がっているか  
gestureData.isPalmFacing(.forward)       // 手のひらが前向きか
gestureData.areAllFingersExtended()      // 全指が伸びているか
gestureData.isAllFingersBent             // 握り拳状態か

// 複数条件の組み合わせ例
guard gestureData.isFingerStraight(.index),
      gestureData.isFingerStraight(.middle),
      gestureData.areAllFingersBentExcept([.index, .middle])
else { return false }
```

### ジェスチャー判定条件

ジェスチャーの判定には以下の4つの主要な条件を使用：

- **指の状態**: isExtended/isCurled
- **手の向き**: palmDirection
- **関節角度**: angleWithParent
- **関節距離**: jointToJointDistance

### 検出フロー

```swift
func detectGestures(from components: [HandTrackingComponent]) -> GestureDetectionResult {
    // 1. シリアルジェスチャーのタイムアウトチェック
    if serialTracker.isTimedOut() {
        serialTracker.reset()
    }
    
    // 2. 優先度順に通常ジェスチャーを検出
    for gesture in sortedGestures {
        if gesture.matches(handData) {
            return [gesture.gestureName]
        }
    }
    
    // 3. シリアルジェスチャーの進行状態を更新
    if let serial = checkSerialGesture() {
        return handleSerialResult(serial)
    }
}
```

## 連続ジェスチャーの追跡システム

### SerialGestureProtocol

時系列で連続するジェスチャー（手話など）を検出するための仕組み：

```swift
protocol SerialGestureProtocol {
    // 順番に検出すべきジェスチャーの配列
    var gestures: [BaseGestureProtocol] { get }
    
    // ジェスチャー間の最大許容時間(秒)
    var intervalSeconds: TimeInterval { get }
    
    // 各ステップの説明(UI表示用)
    var stepDescriptions: [String] { get }
}
```

### SerialGestureTracker - 状態管理

1. **現在のジェスチャーインデックスを追跡**
2. **各ジェスチャー間のタイムアウトを監視**
3. **タイムアウトor完了後に状態をリセット**

### 検出フローの例

```swift
// 例：「ありがとう」の手話
let arigatouGesture = SignLanguageArigatouGesture()
gestures = [
    // Step 1: 初期位置検出
    ArigatouInitialPositionGesture(),  // 両手を同じ高さに
    // Step 2: 最終位置検出 → completed ✅
    ArigatouFinalPositionGesture()     // 上に移動した位置に右手を移動
]
```

### SerialGestureDetectionResult

連続ジェスチャーの検出結果は4つの状態を持ちます：

- **progress**: 次のステップへ進行
- **completed**: 全ステップ完了
- **timeout**: 時間切れ
- **notMatched**: 不一致

## GestureDetector: ジェスチャー検出エンジンの詳細

### GestureDetectorの概要

`GestureDetector`は、HandGestureKitの中核となるジェスチャー検出エンジンです。このクラスは、登録されたジェスチャーパターンを効率的に評価し、リアルタイムでジェスチャーを認識します。

### 基本的な使い方

```swift
// 1. GestureDetectorの初期化
let gestureDetector = GestureDetector()

// 2. 認識したいジェスチャーを登録
gestureDetector.registerGesture(ThumbsUpGesture())
gestureDetector.registerGesture(PeaceSignGesture())
gestureDetector.registerGesture(PrayerGesture())

// 3. 手のデータからジェスチャーを検出
let detectedGestures = gestureDetector.detect(from: handGestureData)

// 4. 検出結果の処理
for gesture in detectedGestures {
    print("検出されたジェスチャー: \(gesture.gestureName)")
}
```

### 内部実装と工夫ポイント

#### 1. 優先度ベースの評価システム

```swift
public class GestureDetector {
    private var gestures: [BaseGestureProtocol] = []
    
    public func detect(from handData: SingleHandGestureData) -> [BaseGestureProtocol] {
        // 優先度順にソート（数値が小さいほど高優先度）
        let sortedGestures = gestures.sorted { $0.priority < $1.priority }
        
        var detectedGestures: [BaseGestureProtocol] = []
        
        for gesture in sortedGestures {
            if let singleHandGesture = gesture as? SingleHandGestureProtocol {
                if singleHandGesture.matches(handData) {
                    detectedGestures.append(gesture)
                    
                    // 排他的なジェスチャーの場合は、ここで処理を終了
                    if gesture.isExclusive {
                        break
                    }
                }
            }
        }
        
        return detectedGestures
    }
}
```

**工夫ポイント**：
- 優先度順の評価により、より特殊なジェスチャーを先に検出
- 排他的フラグにより、特定のジェスチャー検出時に他の評価をスキップ
- 複数のジェスチャーが同時に成立する場合にも対応

#### 2. パフォーマンス最適化

```swift
// ジェスチャー登録時の最適化
public func registerGesture(_ gesture: BaseGestureProtocol) {
    // 重複チェック
    guard !gestures.contains(where: { $0.id == gesture.id }) else {
        return
    }
    
    gestures.append(gesture)
    
    // 優先度順に事前ソートしておくことで、検出時の処理を高速化
    gestures.sort { $0.priority < $1.priority }
}

// バッチ登録による最適化
public func registerGestures(_ newGestures: [BaseGestureProtocol]) {
    gestures.append(contentsOf: newGestures)
    gestures.sort { $0.priority < $1.priority }
}
```

#### 3. デバッグとロギング機能

```swift
extension GestureDetector {
    // デバッグモードでの詳細ログ出力
    public func detectWithDebugInfo(from handData: SingleHandGestureData) -> [(gesture: BaseGestureProtocol, confidence: Float)] {
        var results: [(BaseGestureProtocol, Float)] = []
        
        for gesture in gestures.sorted(by: { $0.priority < $1.priority }) {
            if let singleHandGesture = gesture as? SingleHandGestureProtocol {
                let confidence = singleHandGesture.confidenceScore(for: handData)
                
                if HandGestureLogger.isDebugEnabled {
                    HandGestureLogger.logDebug("Gesture: \(gesture.gestureName), Confidence: \(confidence)")
                }
                
                if singleHandGesture.matches(handData) {
                    results.append((gesture, Float(confidence)))
                }
            }
        }
        
        return results
    }
}
```

### visionOS 2.0でのAnchorEntity統合

visionOS 2.0で導入されたAnchorEntityを使用した実装：

```swift
import RealityKit
import ARKit

@MainActor
class GestureTrackingSystem: System {
    private let gestureDetector = GestureDetector()
    
    static let query = EntityQuery(where: .has(HandTrackingComponent.self))
    
    required init(scene: Scene) {
        // システム初期化時にジェスチャーを登録
        setupGestures()
    }
    
    private func setupGestures() {
        gestureDetector.registerGestures([
            ThumbsUpGesture(),
            PeaceSignGesture(),
            OKSignGesture(),
            PrayerGesture()
        ])
    }
    
    func update(context: SceneUpdateContext) {
        for entity in context.entities(matching: Self.query, updatingSystemWhen: .rendering) {
            guard let handComponent = entity.components[HandTrackingComponent.self] else {
                continue
            }
            
            // SingleHandGestureDataの作成
            let handData = SingleHandGestureData(
                handTrackingComponent: handComponent,
                handKind: .left // または .right
            )
            
            // ジェスチャー検出
            let detectedGestures = gestureDetector.detect(from: handData)
            
            // 検出結果の通知
            if !detectedGestures.isEmpty {
                notifyGestureDetection(detectedGestures)
            }
        }
    }
    
    private func notifyGestureDetection(_ gestures: [BaseGestureProtocol]) {
        let gestureNames = gestures.map { $0.gestureName }
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: .gestureDetected,
                object: gestureNames
            )
        }
    }
}
```

### HandGestureKit: OSSライブラリとしての提供

HandGestureKitは、オープンソースライブラリとして公開されており、誰でも自由に使用・改良できます。

#### インストール方法

**Swift Package Manager**:

```swift
dependencies: [
    .package(url: "https://github.com/your-username/HandGestureKit.git", from: "1.0.0")
]
```

#### 特徴

- **プロトコル指向設計**: 新しいジェスチャーの追加が簡単
- **パフォーマンス最適化済み**: 90Hzのリアルタイム処理に対応
- **豊富なドキュメント**: 詳細な使用例とAPIドキュメント
- **サンプルプロジェクト付属**: すぐに動作確認可能

#### コミュニティへの貢献

プルリクエストやイシューの報告を歓迎しています。特に以下の分野での貢献を求めています：

- 新しいジェスチャーパターンの追加
- パフォーマンスの改善
- ドキュメントの改善
- 多言語対応

## パフォーマンス最適化

### 1. 事前計算と値のキャッシング

頻繁に使用される値を事前計算してキャッシュ：

```swift
extension SingleHandGestureData {
    // 初期化時に値を計算
    init(handTrackingComponent: HandTrackingComponent, handKind: HandKind) {
        self.handTrackingComponent = handTrackingComponent
        self.handKind = handKind
        
        // 頻繁に使用される値を事前計算
        self.palmNormal = calculatePalmNormal(handTrackingComponent)
        self.forearmDirection = calculateForearmDirection(handTrackingComponent)
        self.wristPosition = handTrackingComponent.joint(.wrist)?.position ?? .zero
        self.isArmExtended = calculateArmExtension(handTrackingComponent)
    }
}
```

### 2. 早期リターンの最適化

最も選択的な条件を最初にチェック：

```swift
public func matchesWithOptimization(_ gestureData: SingleHandGestureData) -> Bool {
    // 1. 最も選択的な条件を最初に（指の構成）
    if requiresOnlyIndexAndMiddleStraight {
        guard validateOnlyTargetFingersStraight(gestureData, targetFingers: [.index, .middle]) 
        else { return false }
    }
    
    // 2. 方向チェック（中程度の選択性）
    for direction in GestureDetectionDirection.allCases {
        if requiresPalmFacing(direction) {
            guard gestureData.isPalmFacing(direction) else { return false }
        }
    }
    
    // 3. 個々の指の方向チェック（潜在的に高コスト）
    // ...その他のチェック
    
    return true
}
```

### 3. 優先度ベースの検出

優先度を使用して不要なチェックをスキップ：

```swift
public func detect(from handData: SingleHandGestureData) -> BaseGestureProtocol? {
    let sortedGestures = gestures.sorted { $0.priority < $1.priority }
    
    for gesture in sortedGestures {
        if let singleHandGesture = gesture as? SingleHandGestureProtocol,
           singleHandGesture.matches(handData) {
            return gesture // 最初のマッチで停止
        }
    }
    
    return nil
}
```

## 制限事項と課題

### 1. ハードウェアの制限

**トラッキング範囲**
- 有効範囲：ユーザーから約0.3m〜1.5m
- 最適範囲：0.5m〜1.0m
- 視野角：約120度の水平視野

**解決策**：
```swift
func validateTrackingDistance(_ position: SIMD3<Float>) -> Bool {
    let distance = length(position)
    return distance >= 0.3 && distance <= 1.5
}
```

### 2. オクルージョン処理

指が重なったり、手が部分的に隠れる場合の対処：

```swift
func handleOcclusion(_ handData: SingleHandGestureData) -> Bool {
    // 可視ジョイントの数をチェック
    let visibleJoints = handData.handTrackingComponent.allJoints
        .compactMap { $0 }
        .count
    
    // 最小限のジョイントが見えているか確認
    guard visibleJoints >= minimumRequiredJoints else {
        return false
    }
    
    // 信頼度スコアをチェック
    let confidenceScore = calculateConfidenceScore(handData)
    return confidenceScore >= confidenceThreshold
}
```

### 3. 座標系の課題

ウィンドウ移動時の座標系のずれへの対処：

```swift
// ImmersiveSpaceの再起動による座標系リセット
private func restartImmersiveSpace() async {
    if wasImmersiveSpaceOpen {
        await dismissImmersiveSpace()
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        switch await openImmersiveSpace(id: appModel.immersiveSpaceID) {
        case .opened:
            // 座標系がリセットされた
            break
        default:
            break
        }
    }
}
```

### 4. リアルタイム処理の課題

90Hzの更新レートでの処理：

```swift
class GestureProcessingQueue {
    private let queue = DispatchQueue(label: "gesture.processing", qos: .userInteractive)
    private var lastProcessedTime: TimeInterval = 0
    private let minimumInterval: TimeInterval = 1.0 / 30.0 // 30FPSに制限
    
    func process(_ handData: SingleHandGestureData) {
        let currentTime = CACurrentMediaTime()
        
        guard currentTime - lastProcessedTime >= minimumInterval else {
            return // フレームをスキップ
        }
        
        lastProcessedTime = currentTime
        
        queue.async { [weak self] in
            self?.performGestureDetection(handData)
        }
    }
}
```

## デモンストレーション

セッションでは以下のデモンストレーションを行います：

### 1. 基本ジェスチャー認識
- サムズアップ、ピースサイン、OKサインなどの認識
- リアルタイムフィードバックとビジュアライゼーション

### 2. 手話文字の認識
- 日本手話の指文字（あ、い、う、え、お）
- アメリカ手話（ASL）のアルファベット

### 3. 動的ジェスチャー
- スワイプ、回転などのモーションジェスチャー
- 時系列解析による複雑なジェスチャーパターン

### 4. 実用的なアプリケーション
- プレゼンテーションコントロール
- 3Dオブジェクト操作
- アクセシビリティ機能

## 限界と可能性

### Apple Vision Proでの手話検知の限界

#### 1. カメラの検知範囲の制限

visionOSのハンドトラッキングには物理的な制約があります：

- **体の後ろや横の手は検知不可**: カメラの視野外となる位置の手は追跡できません
- **顔の近くや頭の後ろも死角**: デバイスの構造上、これらの位置での検出が困難
- **手が重なると正確な検知が困難**: オクルージョンによりジョイントの位置推定精度が低下

#### 2. 複雑な手の形状の認識

- **指が絡み合うような形は誤認識しやすい**: 複雑な指の交差や組み合わせの正確な検出が困難
- **手の微妙な傾きや回転の検出精度**: 細かな角度の違いを区別することに限界

#### 3. 手話特有の要素

手話は単なる手の形だけでなく、複数の要素から成り立っています：

- **表情による意味の変化**: 手話では表情が文法的役割を持ちますが、現在のAPIでは検知困難
- **動きの速度や強弱の認識**: 手話の意味を変える重要な要素ですが、正確な検出が難しい

#### 4. 技術的な制約

- **認識パターンの登録が大変**: 手話の多様性に対応するには膨大なパターン定義が必要
- **パフォーマンスとのバランス**: リアルタイム処理と精度のトレードオフ
- **個人差への対応**: 手の大きさや柔軟性の違いによる認識精度の変動
- **相手の手は検知できない**: 装着者自身の手のみが検知対象（対話相手の手話は読み取れない）
  - Enterprise APIでメインカメラアクセスが可能な場合、Vision Frameworkを使用することで実現できる可能性はある
  - ただし、HandSkeletonのような3D情報の取得はできないため、2D画像解析に限定され、実装難易度は非常に高い

### それでも広がる可能性

#### 1. 基本的な手話単語の認識は可能！

現在の技術でも実用的なレベルで認識できるものがあります：

- **定型的な表現**: 「ありがとう」「お願いします」などの日常的な手話
- **数字や簡単な単語**: 指文字や数字表現は比較的高精度で認識可能

#### 2. アクセシビリティ向上への第一歩

完璧でなくても、大きな価値を提供できます：

- **聴覚障害者と健聴者のコミュニケーション支援**: 基本的な意思疎通のサポート
- **緊急時の簡単な意思疎通**: 重要な情報を素早く伝える手段として
- **手話への関心と理解の促進**: 手話学習アプリやインタラクティブな教材への応用

#### 3. 今後の技術発展への期待

- **ハードウェアの進化による精度向上**: より高解像度のカメラ、広い視野角、高速な処理
- **機械学習・AIとの組み合わせ**: パターン認識の精度向上と個人差への適応
- **EyeSightの活用**: Apple Vision ProのEyeSight機能により、装着者の表情が外部から見えるため、手話における表情の重要性に対応可能

## まとめ

visionOSのハンドトラッキング機能は、自然なユーザーインターフェースの新しい可能性を開きます。HandGestureKitのようなフレームワークを使用することで、開発者は複雑なジェスチャー認識システムを効率的に構築できます。

現在の技術には制限がありますが、適切な設計と最適化により、実用的で反応性の高いジェスチャーベースのアプリケーションを作成することが可能です。空間コンピューティングが進化し続ける中、これらの技術はより洗練され、アクセシブルになっていくでしょう。

### 重要なポイント

1. **プロトコル指向設計**により、拡張可能で保守しやすいジェスチャーシステムを構築
2. **パフォーマンス最適化**は、リアルタイムジェスチャー認識に不可欠
3. **制限事項の理解**と適切な回避策の実装が成功の鍵
4. **将来の拡張性**を考慮した設計により、新技術への適応が容易に

## リソース

- [HandGestureKit（GitHub）](https://github.com/your-username/HandGestureKit)
- [Apple Developer Documentation - Hand Tracking](https://developer.apple.com/documentation/arkit/hand_tracking)
- [visionOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/gestures)

## セッション情報

**タイトル**: 手話ジェスチャーの検知と翻訳 〜ハンドトラッキングの可能性と限界〜  
**発表者**: 杉山雄吾  
**日時**: 2025年8月（詳細は後日発表）  
**会場**: iOSDC Japan 2025

皆様のご参加をお待ちしております！質問やフィードバックは、セッション後のAsk the Speakerセッションやソーシャルメディアでお気軽にお寄せください。

---

*この記事は、iOSDC Japan 2025での発表内容を基に作成されました。実際のセッションでは、より詳細な技術解説とライブデモンストレーションを行います。*