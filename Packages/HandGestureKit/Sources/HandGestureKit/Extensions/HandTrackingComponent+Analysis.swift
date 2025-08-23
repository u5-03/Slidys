import ARKit
import RealityKit
import simd

// ベクトルの正規化関数
func normalize(_ vector: SIMD3<Float>) -> SIMD3<Float> {
    let length = sqrt(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z)
    if length > 0 {
        return vector / length
    }
    return vector
}

// MARK: - HandTrackingComponent拡張
extension HandTrackingComponent {

    // MARK: - 1. 指が曲がっているかどうかの判定

    /// 指が真っ直ぐかどうかを判定
    /// - Parameters:
    ///   - finger: 判定したい指の種類
    ///   - tolerance: 許容角度(ラジアン)。デフォルトは45度
    /// - Returns: 指が真っ直ぐならtrue、曲がっていればfalse
    public func isFingerStraight(_ finger: FingerType, tolerance: Float = .pi / 4) -> Bool {
        let joints = getFingerJoints(finger)
        guard joints.count >= 3 else {
            if finger == .index {
                HandGestureLogger.logDebug(
                    "⚠️ \(finger.description)指: 関節数が不足しています (\(joints.count)個)")
            }
            return false
        }

        // 人差し指以外の場合は詳細ログを出力しない
        // 手話モードでは人差し指のログも抑制
        let shouldLogDetails = false  // finger == .index

        // 指の根本から先端までの関節を順番に取得
        var positions: [SIMD3<Float>] = []

        if shouldLogDetails {
            HandGestureLogger.logDebug("🔍 \(finger.description)指の関節座標:")
        }

        for (i, joint) in joints.enumerated() {
            guard let entity = fingers[joint] else {
                if shouldLogDetails {
                    HandGestureLogger.logDebug("⚠️ \(finger.description)指: 関節 \(joint) が見つかりません")
                }
                return false
            }
            let position = entity.position(relativeTo: nil)
            positions.append(position)

            if shouldLogDetails {
                HandGestureLogger.logDebug(
                    "  \(i): \(joint) = (\(String(format: "%.3f", position.x)), \(String(format: "%.3f", position.y)), \(String(format: "%.3f", position.z)))"
                )
            }
        }

        // 連続する3つの関節の角度をチェック
        var allAngles: [Float] = []
        var deviationCount = 0  // 許容範囲を超える角度の数

        for i in 0..<(positions.count - 2) {
            let angle = calculateAngleBetweenPoints(
                p1: positions[i],
                p2: positions[i + 1],
                p3: positions[i + 2]
            )
            allAngles.append(angle)

            if shouldLogDetails {
                let angleDegrees = angle * 180 / .pi
                // 180度からの差を計算
                let straightAngle: Float = .pi
                let deviation = abs(angle - straightAngle)
                let deviationDegrees = deviation * 180 / .pi

                HandGestureLogger.logDebug(
                    "  角度 \(i)-\(i+1)-\(i+2): \(String(format: "%.1f", angleDegrees))° (180°からの差: \(String(format: "%.1f", deviationDegrees))°, 許容: \(String(format: "%.1f", tolerance * 180 / .pi))°)"
                )
            }

            // 許容範囲を超える角度をカウント
            let straightAngle: Float = .pi
            let deviation = abs(angle - straightAngle)
            if deviation > tolerance {
                deviationCount += 1
                if shouldLogDetails {
                    HandGestureLogger.logDebug("  ⚠️ 関節 \(i)-\(i+1)-\(i+2) の角度が許容範囲を超えています")
                }
            }
        }

        // 複数の関節がある場合、1つだけ許容範囲を超えていても真っ直ぐと判定
        // (指の付け根部分は曲がっていることが多いため)
        let isStraight = allAngles.count > 2 ? deviationCount <= 1 : deviationCount == 0

        if shouldLogDetails {
            let averageAngle = allAngles.reduce(0, +) / Float(allAngles.count)
            let averageAngleDegrees = averageAngle * 180 / .pi

            if isStraight {
                HandGestureLogger.logDebug(
                    "📏 \(finger.description)指: 真っ直ぐ (平均角度: \(String(format: "%.1f", averageAngleDegrees))°)"
                )
            } else {
                HandGestureLogger.logDebug(
                    "📏 \(finger.description)指: 曲がっている (平均角度: \(String(format: "%.1f", averageAngleDegrees))°, 許容範囲外の関節数: \(deviationCount))"
                )
            }
        }

        return isStraight
    }

    /// 指が曲がっているかどうかを判定(isFingerStraightの逆)
    public func isFingerBent(_ finger: FingerType, tolerance: Float = .pi / 4) -> Bool {
        return !isFingerStraight(finger, tolerance: tolerance)
    }

    // MARK: - 2. 手のひらの向き判定

    /// 法線ベクトルから方向を判定する共通ロジック
    private func getDirectionFromNormal(_ normal: SIMD3<Float>) -> PalmDirection {
        // 左手と右手で異なる判定を行う
        let isLeftHand = chirality == .left

        // 各方向との角度を計算して最も近い方向を選択
        var closestDirection = PalmDirection.backward
        var smallestAngle: Float = .pi

        // 境界値の調整(45度から30度に変更)

        for direction in PalmDirection.allCases {
            var targetVector = direction.vector

            // 左手の場合、方向ベクトルを調整
            if isLeftHand {
                if direction == .forward || direction == .backward {
                    // 左手の場合、前後方向を反転
                    targetVector = -targetVector
                } else if direction == .up || direction == .down {
                    // 左手の場合、上下方向を反転
                    targetVector = -targetVector
                } else if direction == .left || direction == .right {
                    // 左手の場合、左右方向を反転
                    targetVector = -targetVector
                }
            }

            // 正規化したベクトル間の内積を計算(コサイン類似度)
            let dotProduct = simd_dot(normalize(normal), normalize(targetVector))
            // 内積からラジアン角度を計算
            let angle = acos(max(-1.0, min(1.0, dotProduct)))

            // 最小角度を更新
            if angle < smallestAngle {
                smallestAngle = angle
                closestDirection = direction
            }
        }

        return closestDirection
    }

    /// 手のひらが特定の方向を向いているかを角度で判定(より柔軟)
    /// - Parameters:
    ///   - direction: 判定したい方向
    ///   - tolerance: 許容角度(ラジアン)。デフォルトは30度
    /// - Returns: 指定した方向に向いていればtrue
    public func isPalmFacingDirection(_ direction: PalmDirection, tolerance: Float = .pi / 6)
        -> Bool
    {
        guard fingers[.wrist] != nil else { return false }

        // 左手と右手で異なる判定を行う
        let isLeftHand = chirality == .left

        // 手のひらの法線ベクトルを取得
        let palmNormalToUse = calculatePalmNormal()

        // 指定された方向のベクトル
        var targetVector = direction.vector

        // 左手の場合、方向ベクトルを調整
        if isLeftHand {
            if direction == .forward || direction == .backward {
                // 左手の場合、前後方向を反転
                targetVector = -targetVector
            } else if direction == .up || direction == .down {
                // 左手の場合、上下方向を反転
                targetVector = -targetVector
            } else if direction == .left || direction == .right {
                // 左手の場合、左右方向を反転
                targetVector = -targetVector
            }
        }

        // ベクトル間の角度を計算
        let dotProduct = simd_dot(normalize(palmNormalToUse), normalize(targetVector))
        let angle = acos(max(-1.0, min(1.0, dotProduct)))

        // 許容角度内かどうかを判定
        return angle <= tolerance
    }

    /// 手のひらの法線ベクトルを計算する(複数の方法を試み、最も信頼性の高い結果を返す)
    private func calculatePalmNormal() -> SIMD3<Float> {
        guard let wrist = fingers[.wrist] else { return SIMD3<Float>(0, 0, 1) }

        // 方法1: 手首のAnchorEntityの向きを取得
        let wristTransform = wrist.transform
        let palmNormal1 = wristTransform.rotation.act(SIMD3<Float>(0, 0, 1))

        // 方法2: 手の関節を使って計算(より正確)
        var palmNormal2: SIMD3<Float>? = nil

        // 方法2a: 手のひらの平面を定義する3点を取得(メタカーパル関節)
        if let wristPos = fingers[.wrist]?.position(relativeTo: nil),
            let indexMCP = fingers[.indexFingerMetacarpal]?.position(relativeTo: nil),
            let littleMCP = fingers[.littleFingerMetacarpal]?.position(relativeTo: nil)
        {

            // 手のひらの平面を定義する2つのベクトル
            let v1 = indexMCP - wristPos
            let v2 = littleMCP - wristPos

            // 外積で法線ベクトルを計算
            let crossProduct = simd_cross(v1, v2)
            palmNormal2 = normalize(crossProduct)
        }
        // 方法2b: ナックル(指の付け根)を使用
        else if let wristPos = fingers[.wrist]?.position(relativeTo: nil),
            let indexKnuckle = fingers[.indexFingerKnuckle]?.position(relativeTo: nil),
            let littleKnuckle = fingers[.littleFingerKnuckle]?.position(relativeTo: nil)
        {

            // 手のひらの平面を定義する2つのベクトル
            let v1 = indexKnuckle - wristPos
            let v2 = littleKnuckle - wristPos

            // 外積で法線ベクトルを計算
            let crossProduct = simd_cross(v1, v2)
            palmNormal2 = normalize(crossProduct)
        }
        // 方法2c: 中指と親指のナックルを使用
        else if let wristPos = fingers[.wrist]?.position(relativeTo: nil),
            let middleKnuckle = fingers[.middleFingerKnuckle]?.position(relativeTo: nil),
            let thumbKnuckle = fingers[.thumbKnuckle]?.position(relativeTo: nil)
        {

            // 手のひらの平面を定義する2つのベクトル
            let v1 = middleKnuckle - wristPos
            let v2 = thumbKnuckle - wristPos

            // 外積で法線ベクトルを計算
            let crossProduct = simd_cross(v1, v2)
            palmNormal2 = normalize(crossProduct)
        }

        // 使用する法線ベクトルを決定
        let palmNormalToUse: SIMD3<Float>

        if palmNormal1.x == 0 && palmNormal1.y == 0 && palmNormal1.z == 1,
            let normal2 = palmNormal2
        {
            // 方法1の結果が固定値の場合、方法2を使用
            palmNormalToUse = normal2
        } else if let normal2 = palmNormal2 {
            // 両方の方法で計算できた場合、方法2を優先(より正確なため)
            palmNormalToUse = normal2
        } else {
            // 方法2が使えない場合、方法1を使用
            palmNormalToUse = palmNormal1
        }

        return palmNormalToUse
    }

    /// 手のひらが向いている方向を判定
    /// - Returns: 手のひらの向き
    public func getPalmDirection() -> PalmDirection {
        // 手のひらの法線ベクトルを計算
        let palmNormal = calculatePalmNormal()

        // 法線ベクトルから方向を判定
        return getDirectionFromNormal(palmNormal)
    }

    /// 手のひらが特定の方向を向いているかを判定
    public func isPalmFacing(_ direction: PalmDirection) -> Bool {
        return getPalmDirection() == direction
    }

    /// 手のひらが奥向きかどうかを角度で判定(より柔軟)
    /// - Parameter tolerance: 許容角度(ラジアン)。デフォルトは45度
    /// - Returns: 奥向きであればtrue
    public func isPalmFacingBackward(tolerance: Float = .pi / 4) -> Bool {
        return isPalmFacingDirection(.backward, tolerance: tolerance)
    }

    /// 手のひらが前向きかどうかを角度で判定(より柔軟)
    public func isPalmFacingForward(tolerance: Float = .pi / 6) -> Bool {
        return isPalmFacingDirection(.forward, tolerance: tolerance)
    }

    /// 手のひらが上向きかどうかを角度で判定(より柔軟)
    public func isPalmFacingUp(tolerance: Float = .pi / 6) -> Bool {
        return isPalmFacingDirection(.up, tolerance: tolerance)
    }

    /// 手のひらが下向きかどうかを角度で判定(より柔軟)
    public func isPalmFacingDown(tolerance: Float = .pi / 6) -> Bool {
        return isPalmFacingDirection(.down, tolerance: tolerance)
    }

    // MARK: - 3. 指先の接触判定

    /// 2つの指の先端が接触しているかを判定
    /// - Parameters:
    ///   - finger1: 1つ目の指
    ///   - finger2: 2つ目の指
    ///   - threshold: 接触判定の距離閾値(メートル)。デフォルトは2cm
    /// - Returns: 接触していればtrue
    public func areFingerTipsTouching(
        _ finger1: FingerType, _ finger2: FingerType, threshold: Float = 0.02
    ) -> Bool {
        let tip1Joint = getFingerTipJoint(finger1)
        let tip2Joint = getFingerTipJoint(finger2)

        guard let tip1Entity = fingers[tip1Joint],
            let tip2Entity = fingers[tip2Joint]
        else {
            return false
        }

        let tip1Pos = tip1Entity.position(relativeTo: nil)
        let tip2Pos = tip2Entity.position(relativeTo: nil)

        let distance = simd_distance(tip1Pos, tip2Pos)
        return distance <= threshold
    }

    /// 親指と他の指が接触しているかを判定(OKサインなどで使用)
    public func isThumbTouchingFinger(_ finger: FingerType, threshold: Float = 0.02) -> Bool {
        return areFingerTipsTouching(.thumb, finger, threshold: threshold)
    }

    // MARK: - 4. 指の向き判定

    /// 指が向いている方向を判定
    /// - Parameter finger: 判定したい指
    /// - Returns: 指の向き
    public func getFingerDirection(_ finger: FingerType) -> PalmDirection {
        let tipJoint = getFingerTipJoint(finger)
        guard let tipEntity = fingers[tipJoint] else { return .backward }

        // 指先のAnchorEntityの向きを取得
        let tipTransform = tipEntity.transform

        // 指の向きベクトルを計算(指先から見てZ軸の負の方向が指の向き)
        let fingerDirection = tipTransform.rotation.act(SIMD3<Float>(0, 0, -1))

        // 人差し指の場合のみデバッグ情報を表示
        if finger == .index {
            // デバッグ用に法線ベクトルの値を表示
            HandGestureLogger.logDebug(
                "👆 \(finger)の向きベクトル: (\(String(format: "%.3f", fingerDirection.x)), \(String(format: "%.3f", fingerDirection.y)), \(String(format: "%.3f", fingerDirection.z)))"
            )

            // 各軸成分の絶対値を取得
            let absX = abs(fingerDirection.x)
            let absY = abs(fingerDirection.y)
            let absZ = abs(fingerDirection.z)

            // デバッグ用に絶対値を表示
            HandGestureLogger.logDebug(
                "👆 \(finger)絶対値: X=\(String(format: "%.3f", absX)), Y=\(String(format: "%.3f", absY)), Z=\(String(format: "%.3f", absZ))"
            )
        }

        // 各軸成分の絶対値を取得
        let absX = abs(fingerDirection.x)
        let absY = abs(fingerDirection.y)
        let absZ = abs(fingerDirection.z)

        // 最も大きな成分で方向を決定
        let direction: PalmDirection
        if absY > absX && absY > absZ {
            direction = fingerDirection.y > 0 ? .up : .down
        } else if absZ > absX && absZ > absY {
            direction = fingerDirection.z > 0 ? .backward : .forward
        } else {
            direction = fingerDirection.x > 0 ? .right : .left
        }

        // 人差し指の場合のみ方向判定結果を表示
        if finger == .index {
            HandGestureLogger.logDebug("👆 \(finger)方向判定結果: \(direction)")
        }

        return direction
    }

    /// 指が特定の方向を向いているかを判定
    /// - Parameters:
    ///   - finger: 判定したい指
    ///   - direction: 期待する方向
    /// - Returns: 指定した方向を向いていればtrue
    public func isFingerPointing(_ finger: FingerType, direction: PalmDirection) -> Bool {
        return getFingerDirection(finger) == direction
    }

    /// 指が上方向を向いているかを判定
    /// - Parameter finger: 判定したい指
    /// - Returns: 上方向を向いていればtrue
    public func isFingerPointingUp(_ finger: FingerType) -> Bool {
        return isFingerPointing(finger, direction: .up)
    }

    /// 指が下方向を向いているかを判定
    /// - Parameter finger: 判定したい指
    /// - Returns: 下方向を向いていればtrue
    public func isFingerPointingDown(_ finger: FingerType) -> Bool {
        return isFingerPointing(finger, direction: .down)
    }

    /// 指が前方向を向いているかを判定
    /// - Parameter finger: 判定したい指
    /// - Returns: 前方向を向いていればtrue
    public func isFingerPointingForward(_ finger: FingerType) -> Bool {
        return isFingerPointing(finger, direction: .forward)
    }

    /// 指が後方向を向いているかを判定
    /// - Parameter finger: 判定したい指
    /// - Returns: 後方向を向いていればtrue
    public func isFingerPointingBackward(_ finger: FingerType) -> Bool {
        return isFingerPointing(finger, direction: .backward)
    }

    /// 指が左方向を向いているかを判定
    /// - Parameter finger: 判定したい指
    /// - Returns: 左方向を向いていればtrue
    public func isFingerPointingLeft(_ finger: FingerType) -> Bool {
        return isFingerPointing(finger, direction: .left)
    }

    /// 指が右方向を向いているかを判定
    /// - Parameter finger: 判定したい指
    /// - Returns: 右方向を向いていればtrue
    public func isFingerPointingRight(_ finger: FingerType) -> Bool {
        return isFingerPointing(finger, direction: .right)
    }

    // MARK: - ヘルパー関数

    /// 指の関節のリストを取得
    private func getFingerJoints(_ finger: FingerType) -> [HandSkeleton.JointName] {
        switch finger {
        case .thumb:
            // 親指は関節が少ないので、ナックルから先端までを使用
            return [.thumbKnuckle, .thumbIntermediateTip, .thumbTip]
        case .index:
            // 人差し指はナックルから先端までを使用(中間関節を減らして安定化)
            return [.indexFingerKnuckle, .indexFingerIntermediateTip, .indexFingerTip]
        case .middle:
            // 中指はナックルから先端までを使用(中間関節を減らして安定化)
            return [.middleFingerKnuckle, .middleFingerIntermediateTip, .middleFingerTip]
        case .ring:
            // 薬指はナックルから先端までを使用(中間関節を減らして安定化)
            return [.ringFingerKnuckle, .ringFingerIntermediateTip, .ringFingerTip]
        case .little:
            // 小指はナックルから先端までを使用(中間関節を減らして安定化)
            return [.littleFingerKnuckle, .littleFingerIntermediateTip, .littleFingerTip]
        }
    }

    /// 指の先端関節を取得
    private func getFingerTipJoint(_ finger: FingerType) -> HandSkeleton.JointName {
        switch finger {
        case .thumb: return .thumbTip
        case .index: return .indexFingerTip
        case .middle: return .middleFingerTip
        case .ring: return .ringFingerTip
        case .little: return .littleFingerTip
        }
    }

    /// 3点間の角度を計算(ラジアン)
    private func calculateAngleBetweenPoints(p1: SIMD3<Float>, p2: SIMD3<Float>, p3: SIMD3<Float>)
        -> Float
    {
        // 2つのベクトルを計算
        let v1 = normalize(p1 - p2)
        let v2 = normalize(p3 - p2)

        // 内積からコサインを計算
        let cosine = simd_dot(v1, v2)

        // アークコサインで角度(ラジアン)を取得
        // 数値誤差対策で-1.0〜1.0の範囲に制限
        return acos(max(-1.0, min(1.0, cosine)))
    }

    /// 特定の指が指している方向を取得
    /// - Parameter finger: 方向を取得したい指
    /// - Returns: 指の方向
    public func getPointingDirection(for finger: FingerType) -> PalmDirection {
        // 指の先端と関節の位置を取得
        let tipJoint: HandSkeleton.JointName
        let middleJoint: HandSkeleton.JointName

        switch finger {
        case .thumb:
            tipJoint = .thumbTip
            middleJoint = .thumbIntermediateTip
        case .index:
            tipJoint = .indexFingerTip
            middleJoint = .indexFingerIntermediateTip
        case .middle:
            tipJoint = .middleFingerTip
            middleJoint = .middleFingerIntermediateTip
        case .ring:
            tipJoint = .ringFingerTip
            middleJoint = .ringFingerIntermediateTip
        case .little:
            tipJoint = .littleFingerTip
            middleJoint = .littleFingerIntermediateTip
        }

        // 指の先端と関節の位置を取得
        guard let tipEntity = fingers[tipJoint] else { return .backward }
        guard let middleEntity = fingers[middleJoint] else { return .backward }

        // 指の方向ベクトルを計算
        let tipPosition = tipEntity.position(relativeTo: nil)
        let middlePosition = middleEntity.position(relativeTo: nil)
        let directionVector = normalize(tipPosition - middlePosition)

        // 方向ベクトルから最も近い方向を判定
        return getDirectionFromNormal(directionVector)
    }

    // MARK: - 5. 指先の距離判定

    /// 2つの指先が十分に離れているかを判定
    /// - Parameters:
    ///   - fingerA: 1つ目の指
    ///   - fingerB: 2つ目の指
    ///   - minSpacing: 最小間隔(メートル)。デフォルトは1.5cm
    /// - Returns: 指先が最小間隔以上離れていればtrue
    public func areTwoFingersSeparated(
        _ fingerA: FingerType, _ fingerB: FingerType, minSpacing: Float = 0.03
    ) -> Bool {
        let tipJointA = getFingerTipJoint(fingerA)
        let tipJointB = getFingerTipJoint(fingerB)

        guard let tipEntityA = fingers[tipJointA],
            let tipEntityB = fingers[tipJointB]
        else {
            return false
        }

        let tipPosA = tipEntityA.position(relativeTo: nil)
        let tipPosB = tipEntityB.position(relativeTo: nil)

        let distance = simd_distance(tipPosA, tipPosB)
        return distance >= minSpacing
    }
}
