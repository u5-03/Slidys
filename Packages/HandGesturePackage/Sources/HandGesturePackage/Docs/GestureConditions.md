# ジェスチャー判定条件リファレンス

## 概要
このドキュメントでは、HandGesturePackageで利用可能なジェスチャー判定条件を整理して記載します。

## 1. ジェスチャーの種類

### 1.1 片手の条件

#### 1.1.1 指の状態判定
```swift
// 個別の指の状態
gestureData.isFingerStraight(_ finger: FingerType) -> Bool  // 指が伸びているか
gestureData.isFingerBent(_ finger: FingerType) -> Bool      // 指が曲がっているか

// 複数の指の状態
gestureData.areAllFingersExceptBent(_ exceptions: [FingerType]) -> Bool     // 指定以外が曲がっている
gestureData.areAllFingersExceptStraight(_ exceptions: [FingerType]) -> Bool // 指定以外が伸びている
```

**利用可能なFingerType:**
- `.thumb` - 親指
- `.index` - 人差し指
- `.middle` - 中指
- `.ring` - 薬指
- `.little` - 小指

#### 1.1.2 手のひらの向き判定
```swift
// 手のひらの方向チェック
gestureData.isPalmFacing(_ direction: GestureDetectionDirection) -> Bool
gestureData.palmDirection -> PalmDirection  // 現在の向きを取得
```

**利用可能な方向:**
- `.up` / `.down` - 上下
- `.forward` / `.backward` - 前後
- `.left` / `.right` - 左右

#### 1.1.3 指の方向判定
```swift
// 特定の指の向き
gestureData.isFingerPointing(_ finger: FingerType, direction: GestureDetectionDirection) -> Bool
gestureData.getFingerDirection(_ finger: FingerType) -> PalmDirection
```

#### 1.1.4 関節位置の取得
```swift
// 3D空間での関節位置
gestureData.getJointPosition(_ joint: HandSkeleton.JointName) -> SIMD3<Float>?
```

**主要な関節:**
- 手首: `.wrist`
- 指先: `.thumbTip`, `.indexFingerTip`, `.middleFingerTip`, `.ringFingerTip`, `.littleFingerTip`
- 指の付け根: `.thumbKnuckle`, `.indexFingerKnuckle`, 等

#### 1.1.5 手首の状態
```swift
gestureData.isWristBentOutward -> Bool   // 外側に曲がっている
gestureData.isWristBentInward -> Bool    // 内側に曲がっている
gestureData.isWristStraight -> Bool      // まっすぐ
```

#### 1.1.6 腕の状態
```swift
gestureData.armExtended -> Bool  // 腕が伸びている
gestureData.isArmExtendedInDirection(_ direction: GestureDetectionDirection) -> Bool
```

### 1.2 両手の条件

#### 1.2.1 両手間の距離
```swift
// 各種距離の取得
handsGestureData.palmCenterDistance -> Float     // 手のひら中心間
handsGestureData.palmDistance -> Float           // 手首間
handsGestureData.middleKnuckleDistance -> Float  // 中指付け根間

// 特定の指先間の距離
handsGestureData.fingerTipDistance(
    leftFinger: FingerType, 
    rightFinger: FingerType
) -> Float
```

#### 1.2.2 両手の向き関係
```swift
handsGestureData.arePalmsFacingEachOther -> Bool  // 向かい合っている
handsGestureData.areHandsParallel -> Bool         // 平行になっている
```

#### 1.2.3 両手の位置関係
```swift
handsGestureData.verticalOffset -> Float           // 垂直方向のズレ
handsGestureData.centerPosition -> SIMD3<Float>   // 両手の中心位置
```

#### 1.2.4 個別の手へのアクセス
```swift
// 左右それぞれの手のデータ
handsGestureData.leftHand: SingleHandGestureData
handsGestureData.rightHand: SingleHandGestureData

// 特定の手の関節位置
handsGestureData.getJointPosition(
    hand: HandKind,  // .left or .right
    joint: HandSkeleton.JointName
) -> SIMD3<Float>?
```

## 2. ジェスチャーの判定例

### 2.1 片手ジェスチャーの実装例

#### ピースサイン
```swift
public struct PeaceSignGesture: SingleHandGestureProtocol {
    public func matches(_ gestureData: SingleHandGestureData) -> Bool {
        // 人差し指と中指が伸びている
        guard gestureData.isFingerStraight(.index),
              gestureData.isFingerStraight(.middle) else {
            return false
        }
        
        // 他の指は曲がっている
        return gestureData.areAllFingersExceptBent([.index, .middle])
    }
}
```

#### サムズアップ
```swift
public struct ThumbsUpGesture: SingleHandGestureProtocol {
    public func matches(_ gestureData: SingleHandGestureData) -> Bool {
        // 親指が伸びて上を向いている
        guard gestureData.isFingerStraight(.thumb),
              gestureData.isFingerPointing(.thumb, direction: .up) else {
            return false
        }
        
        // 他の指は曲がっている
        return gestureData.areAllFingersExceptBent([.thumb])
    }
}
```

#### OKサイン
```swift
public struct OKSignGesture: SingleHandGestureProtocol {
    public func matches(_ gestureData: SingleHandGestureData) -> Bool {
        // 親指と人差し指の先端の距離を計算
        guard let thumbTip = gestureData.getJointPosition(.thumbTip),
              let indexTip = gestureData.getJointPosition(.indexFingerTip) else {
            return false
        }
        
        let distance = simd_distance(thumbTip, indexTip)
        
        // 3cm以内で輪を作っている
        guard distance < 0.03 else { return false }
        
        // 他の3本の指は伸びている
        return gestureData.isFingerStraight(.middle) &&
               gestureData.isFingerStraight(.ring) &&
               gestureData.isFingerStraight(.little)
    }
}
```

### 2.2 両手ジェスチャーの実装例

#### ハートジェスチャー
```swift
public struct HeartGesture: TwoHandGestureProtocol {
    public func matches(_ gestureData: HandsGestureData) -> Bool {
        // 両手の親指と人差し指が伸びている
        guard gestureData.leftHand.isFingerStraight(.thumb),
              gestureData.leftHand.isFingerStraight(.index),
              gestureData.rightHand.isFingerStraight(.thumb),
              gestureData.rightHand.isFingerStraight(.index) else {
            return false
        }
        
        // 他の指が曲がっている
        guard gestureData.leftHand.areAllFingersExceptBent([.thumb, .index]),
              gestureData.rightHand.areAllFingersExceptBent([.thumb, .index]) else {
            return false
        }
        
        // 親指同士、人差し指同士が近い（5cm以内）
        let thumbDistance = gestureData.fingerTipDistance(leftFinger: .thumb, rightFinger: .thumb)
        let indexDistance = gestureData.fingerTipDistance(leftFinger: .index, rightFinger: .index)
        
        guard thumbDistance < 0.05, indexDistance < 0.05 else {
            return false
        }
        
        // 手が向かい合っている
        return gestureData.arePalmsFacingEachOther
    }
}
```

#### 祈りのジェスチャー
```swift
public struct PrayerGesture: TwoHandGestureProtocol {
    public func matches(_ gestureData: HandsGestureData) -> Bool {
        // 両手が向かい合っている
        guard gestureData.arePalmsFacingEachOther else { return false }
        
        // 手のひらの距離が近い（2-8cm）
        let distance = gestureData.palmCenterDistance
        guard distance > 0.02 && distance < 0.08 else { return false }
        
        // すべての指が伸びている
        let leftFingers: [FingerType] = [.thumb, .index, .middle, .ring, .little]
        let rightFingers = leftFingers
        
        for finger in leftFingers {
            guard gestureData.leftHand.isFingerStraight(finger),
                  gestureData.rightHand.isFingerStraight(finger) else {
                return false
            }
        }
        
        // 垂直方向のズレが小さい（3cm以内）
        return gestureData.verticalOffset < 0.03
    }
}
```

#### タイムアウトサイン（T字）
```swift
public struct TimeoutGesture: TwoHandGestureProtocol {
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
        
        // 水平の手が垂直の手の上にある
        guard let verticalPos = gestureData.getJointPosition(hand: .left, joint: .wrist),
              let horizontalPos = gestureData.getJointPosition(hand: .right, joint: .wrist) else {
            return false
        }
        
        return horizontalPos.y > verticalPos.y
    }
}
```

### 2.3 判定のベストプラクティス

#### 効率的な条件チェック
```swift
public func matches(_ gestureData: SingleHandGestureData) -> Bool {
    // 1. 計算コストの低い条件から先にチェック
    guard gestureData.isFingerStraight(.index) else { return false }
    
    // 2. 早期リターンで不要な計算を回避
    guard gestureData.isFingerStraight(.middle) else { return false }
    
    // 3. 複雑な計算は最後に
    guard let indexTip = gestureData.getJointPosition(.indexFingerTip) else {
        return false
    }
    // 距離計算など
    
    return true
}
```

#### 適切な閾値
- **指先の距離**: 3-5cm (0.03-0.05)
- **手のひらの距離**: 10-20cm (0.10-0.20)
- **角度の許容範囲**: π/4 (45度)
- **垂直オフセット**: 3cm以内 (0.03)