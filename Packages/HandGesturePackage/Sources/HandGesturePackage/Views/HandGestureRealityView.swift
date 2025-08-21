import SwiftUI
import RealityKit
import ARKit
import HandGestureKit

public struct HandGestureRealityView: View {
    @Environment(\.gestureInfoStore) private var gestureInfoStore
    @State private var rootEntity = Entity()
    // SpatialTrackingSession関連
    @State private var spatialTrackingSession = SpatialTrackingSession()
    // 手のエンティティを管理するためのEntity
    @State private var handEntitiesContainerEntity = Entity()

    public init() {}

    public var body: some View {
        RealityView { content in
            // GestureInfoStoreをHandGestureTrackingSystemに設定
            HandGestureTrackingSystem.setGestureInfoStore(gestureInfoStore)
            
            // ルートエンティティをシーンに追加
            content.add(rootEntity)

            // 権限をリクエスト
            await requestHandTrackingAuthorization()

            // SpatialTrackingSessionベースの手のエンティティを作成
            createHandEntities()
            
            // 手のエンティティコンテナをルートに追加
            handEntitiesContainerEntity.name = "HandEntitiesContainer"
            handEntitiesContainerEntity.isEnabled = gestureInfoStore.showHandEntities
            rootEntity.addChild(handEntitiesContainerEntity)
            
            // HandGestureTrackingSystemがRealityKitに登録されている
            // システムは自動的にシーンで動作を開始する
            HandGestureLogger.logSystem("HandGestureTrackingSystem is active in the scene")

        }
        .upperLimbVisibility(.hidden)
        .onChange(of: gestureInfoStore.showHandEntities) { _, newValue in
            // トグルの状態に応じてエンティティの表示/非表示を切り替え
            handEntitiesContainerEntity.isEnabled = newValue
        }
        .onDisappear {
            HandGestureLogger.logUI("HandGestureRealityView disappeared")
            // SpatialTrackingSessionを停止
            Task {
                await spatialTrackingSession.stop()
            }
        }
    }

    @MainActor
    func createHandEntities() {
        HandGestureLogger.logSystem("Setting up hand tracking with SpatialTrackingSession")

        // SpatialTrackingSessionを開始
        Task {
            let configuration = SpatialTrackingSession.Configuration(tracking: [.hand])
            let result = await spatialTrackingSession.run(configuration)
            HandGestureLogger.logSystem(
                "SpatialTrackingSession started successfully with result: \(String(describing: result))"
            )

            // ハンドトラッキング処理を開始
            await processHandUpdates()
        }

        HandGestureLogger.logSystem("SpatialTrackingSession hand tracking setup completed")
    }

    private func processHandUpdates() async {
        // SpatialTrackingSessionでは、AnchorEntityが自動的に手の位置を追跡するため、
        // 手動でアップデートを処理する代わりに、AnchorEntityを作成して手の形検知を行う
        await setupHandAnchorEntities()
    }

    @MainActor
    private func setupHandAnchorEntities() async {
        HandGestureLogger.logSystem("Setting up hand AnchorEntities for SpatialTrackingSession")

        // 手の形検知に必要最小限の関節のみ（50個制限対応）
        let handJoints: [HandSkeleton.JointName] = [
            // 親指（4関節）
            .thumbKnuckle, .thumbIntermediateBase, .thumbIntermediateTip, .thumbTip,
            // 人差し指（3関節 - metacarpalを除外）
            .indexFingerKnuckle, .indexFingerIntermediateTip, .indexFingerTip,
            // 中指（3関節 - metacarpalを除外）
            .middleFingerKnuckle, .middleFingerIntermediateTip, .middleFingerTip,
            // 薬指（3関節 - metacarpalを除外）
            .ringFingerKnuckle, .ringFingerIntermediateTip, .ringFingerTip,
            // 小指（3関節 - metacarpalを除外）
            .littleFingerKnuckle, .littleFingerIntermediateTip, .littleFingerTip,
            // 手首
            .wrist
        ]

        // 左手と右手の両方に対してAnchorEntityを作成
        for chirality in [AnchoringComponent.Target.Chirality.left, .right] {
            // HandTrackingComponentを持つメインの手エンティティを作成
            let handEntity = Entity()
            handEntity.name = "\(chirality == .left ? "Left" : "Right")_Hand"
            var handComponent = HandTrackingComponent(chirality: chirality == .left ? .left : .right)

            // 各関節にAnchorEntityを作成
            for handJoint in handJoints {
                // 関節の球体エンティティを作成
                let jointSphere = createJointSphere(for: handJoint, chirality: chirality == .left ? .left : .right)

                // HandSkeleton.JointNameをHandJointに変換
                guard let handJointConverted = convertToHandJoint(handJoint) else {
                    HandGestureLogger.logDebug("Warning: Could not convert joint \(handJoint) to HandJoint")
                    continue
                }

                // 関節のAnchorEntityを作成
                let joint = AnchoringComponent.Target.HandLocation.joint(for: handJointConverted)
                let anchorEntity = AnchorEntity(.hand(chirality, location: joint), trackingMode: .predicted)
                anchorEntity.name = "\(chirality == .left ? "Left" : "Right")_\(handJoint)"

                // デバッグ: AnchorEntity作成確認
                HandGestureLogger.logDebug("🔗 AnchorEntity作成: \(anchorEntity.name) - \(joint)")

                // 球体をAnchorEntityに追加
                anchorEntity.addChild(jointSphere)

                // HandTrackingComponentの関節辞書に追加
                handComponent.fingers[handJoint] = anchorEntity

                // AnchorEntityを手のエンティティコンテナに追加
                handEntitiesContainerEntity.addChild(anchorEntity)

                // 作成直後の座標を確認
                HandGestureLogger.logDebug("  初期座標 transform.translation: (\(String(format: "%.3f", anchorEntity.transform.translation.x)), \(String(format: "%.3f", anchorEntity.transform.translation.y)), \(String(format: "%.3f", anchorEntity.transform.translation.z)))")
                HandGestureLogger.logDebug("  初期座標 position: (\(String(format: "%.3f", anchorEntity.position.x)), \(String(format: "%.3f", anchorEntity.position.y)), \(String(format: "%.3f", anchorEntity.position.z)))")

                // 座標系の軸方向を確認（手首と親指の場合）
                if joint == .wrist || joint == .thumbTip {
                    let transform = anchorEntity.transform
                    HandGestureLogger.logDebug("  🧭 \(chirality == .left ? "Left" : "Right") \(joint == .wrist ? "手首" : "親指先")の座標系:")
                    HandGestureLogger.logDebug("    X軸方向 (columns.0): (\(String(format: "%.3f", transform.matrix.columns.0.x)), \(String(format: "%.3f", transform.matrix.columns.0.y)), \(String(format: "%.3f", transform.matrix.columns.0.z)))")
                    HandGestureLogger.logDebug("    Y軸方向 (columns.1): (\(String(format: "%.3f", transform.matrix.columns.1.x)), \(String(format: "%.3f", transform.matrix.columns.1.y)), \(String(format: "%.3f", transform.matrix.columns.1.z)))")
                    HandGestureLogger.logDebug("    Z軸方向 (columns.2): (\(String(format: "%.3f", transform.matrix.columns.2.x)), \(String(format: "%.3f", transform.matrix.columns.2.y)), \(String(format: "%.3f", transform.matrix.columns.2.z)))")

                    // グローバル座標系との一致度を確認
                    let identityThreshold: Float = 0.1
                    let isXAligned = abs(transform.matrix.columns.0.x - 1.0) < identityThreshold && abs(transform.matrix.columns.0.y) < identityThreshold && abs(transform.matrix.columns.0.z) < identityThreshold
                    let isYAligned = abs(transform.matrix.columns.1.y - 1.0) < identityThreshold && abs(transform.matrix.columns.1.x) < identityThreshold && abs(transform.matrix.columns.1.z) < identityThreshold
                    let isZAligned = abs(transform.matrix.columns.2.z - 1.0) < identityThreshold && abs(transform.matrix.columns.2.x) < identityThreshold && abs(transform.matrix.columns.2.y) < identityThreshold

                    if isXAligned && isYAligned && isZAligned {
                        HandGestureLogger.logDebug("    ✅ グローバル座標系とほぼ一致しています！")
                        HandGestureLogger.logDebug("    📝 基準姿勢: 指先↑、手のひら→\(chirality == .left ? "右" : "左")、親指→前")
                    }
                }
            }

            // HandTrackingComponentを設定
            handEntity.components.set(handComponent)
            handEntitiesContainerEntity.addChild(handEntity)

            // デバッグ: HandTrackingComponentが正しく設定されたか確認
            HandGestureLogger.logDebug("✅ HandTrackingComponent set for \(chirality == .left ? "Left" : "Right") hand entity")
            HandGestureLogger.logDebug("   - Entity ID: \(handEntity.id)")
            HandGestureLogger.logDebug("   - Component fingers count: \(handComponent.fingers.count)")

            // 骨（関節間の接続）を作成
            createBones(for: chirality, handJoints: handJoints, handComponent: handComponent)
        }

        HandGestureLogger.logSystem("Hand AnchorEntities created for SpatialTrackingSession")
    }
    // MARK: - 型変換ヘルパー関数

    private func convertToHandJoint(_ joint: HandSkeleton.JointName) -> AnchoringComponent.Target.HandLocation.HandJoint? {
        switch joint {
        case .thumbKnuckle: return .thumbKnuckle
        case .thumbIntermediateBase: return .thumbIntermediateBase
        case .thumbIntermediateTip: return .thumbIntermediateTip
        case .thumbTip: return .thumbTip
        case .indexFingerMetacarpal: return .indexFingerMetacarpal
        case .indexFingerKnuckle: return .indexFingerKnuckle
        case .indexFingerIntermediateBase: return .indexFingerIntermediateBase
        case .indexFingerIntermediateTip: return .indexFingerIntermediateTip
        case .indexFingerTip: return .indexFingerTip
        case .middleFingerMetacarpal: return .middleFingerMetacarpal
        case .middleFingerKnuckle: return .middleFingerKnuckle
        case .middleFingerIntermediateBase: return .middleFingerIntermediateBase
        case .middleFingerIntermediateTip: return .middleFingerIntermediateTip
        case .middleFingerTip: return .middleFingerTip
        case .ringFingerMetacarpal: return .ringFingerMetacarpal
        case .ringFingerKnuckle: return .ringFingerKnuckle
        case .ringFingerIntermediateBase: return .ringFingerIntermediateBase
        case .ringFingerIntermediateTip: return .ringFingerIntermediateTip
        case .ringFingerTip: return .ringFingerTip
        case .littleFingerMetacarpal: return .littleFingerMetacarpal
        case .littleFingerKnuckle: return .littleFingerKnuckle
        case .littleFingerIntermediateBase: return .littleFingerIntermediateBase
        case .littleFingerIntermediateTip: return .littleFingerIntermediateTip
        case .littleFingerTip: return .littleFingerTip
        case .wrist: return .wrist
        case .forearmWrist: return .wrist
        case .forearmArm: return .forearmArm
        @unknown default: return nil
        }
    }

    // MARK: - エンティティ作成

    @MainActor
    func createJointSphere(for joint: HandSkeleton.JointName, chirality: HandAnchor.Chirality) -> ModelEntity {
        // 関節の種類に応じてサイズと色を調整
        var radius: Float = 0.003
        var height: Float = 0.015
        var color: UIColor = .yellow

        // 手首は大きく表示
        if joint == .wrist {
            radius *= 2.0
            height *= 2.0
            color = chirality == .left ? .magenta : .purple
        } else {
            // 指の関節は小さく表示
            color = chirality == .left ? .systemPink : .systemTeal
        }

        // コンテナエンティティを作成
        let container = ModelEntity()
        container.name = "\(chirality == .left ? "Left" : "Right")_\(joint)_Container"

        // 円錐で方向を可視化（先端が指先方向を示す）
        let cone = ModelEntity(
            mesh: .generateCone(height: height, radius: radius),
            materials: [UnlitMaterial(color: color)]
        )

        // 関節の種類に応じて円錐の向きを設定
        let rotation = getConeRotationForJoint(joint, chirality: chirality == .left ? .left : .right)
        cone.transform.rotation = rotation
        cone.name = "\(chirality == .left ? "Left" : "Right")_\(joint)_Cone"

        // 座標軸を作成
        let axes = createCoordinateAxes(for: joint, chirality: chirality)

        // コンテナに円錐と座標軸を追加
        container.addChild(cone)
        for axis in axes {
            container.addChild(axis)
        }

        return container
    }

    private func getConeRotationForJoint(_ joint: HandSkeleton.JointName, chirality: AnchoringComponent.Target.Chirality) -> simd_quatf {
        // 実験結果に基づく正しい回転設定
        // 円錐のデフォルト向きはY軸上向き

        switch joint {
            // 手首: デフォルトのY軸上向きのまま
        case .wrist:
            return simd_quatf(ix: 0, iy: 0, iz: 0, r: 1)

            // 親指: 左右の手で回転方向を調整
        case .thumbTip, .thumbIntermediateTip, .thumbKnuckle, .thumbIntermediateBase:
            // 右手: Z軸周りに90度回転、左手: Z軸周りに-90度回転
            let angle: Float = chirality == .right ? .pi/2 : -.pi/2
            return simd_quatf(angle: angle, axis: [0, 0, 1])

            // 他の指: 左右の手で回転方向を逆にする
        case .indexFingerTip, .indexFingerIntermediateTip, .indexFingerKnuckle,
                .middleFingerTip, .middleFingerIntermediateTip, .middleFingerKnuckle,
                .ringFingerTip, .ringFingerIntermediateTip, .ringFingerKnuckle,
                .littleFingerTip, .littleFingerIntermediateTip, .littleFingerKnuckle:
            // 右手: Z軸周りに90度回転、左手: Z軸周りに-90度回転
            let angle: Float = chirality == .right ? .pi/2 : -.pi/2
            return simd_quatf(angle: angle, axis: [0, 0, 1])

        default:
            // デフォルトの向き（Y軸上向き）
            return simd_quatf(ix: 0, iy: 0, iz: 0, r: 1)
        }
    }

    @MainActor
    private func createCoordinateAxes(for joint: HandSkeleton.JointName, chirality: HandAnchor.Chirality) -> [ModelEntity] {
        var axes: [ModelEntity] = []

        // 軸の長さとシリンダーの半径を設定
        let axisLength: Float = 0.015  // 中間の長さに調整
        let axisRadius: Float = 0.0005

        // 手首の場合は軸を大きく表示
        let length = joint == .wrist ? axisLength * 1.3 : axisLength
        let radius = joint == .wrist ? axisRadius * 2.0 : axisRadius

        // X軸（赤色）
        let xAxis = ModelEntity(
            mesh: .generateCylinder(height: length, radius: radius),
            materials: [UnlitMaterial(color: .red)]
        )
        // X軸方向に向ける（Z軸周りに90度回転）
        xAxis.transform.rotation = simd_quatf(angle: .pi/2, axis: [0, 0, 1])
        // 0の座標からプラス方向に配置（シリンダーの中心をプラス方向にずらす）
        xAxis.transform.translation = [length/2, 0, 0]
        xAxis.name = "\(chirality == .left ? "Left" : "Right")_\(joint)_XAxis"
        axes.append(xAxis)

        // Y軸（緑色）
        let yAxis = ModelEntity(
            mesh: .generateCylinder(height: length, radius: radius),
            materials: [UnlitMaterial(color: .green)]
        )
        // Y軸方向はデフォルトのまま
        // 0の座標からプラス方向に配置
        yAxis.transform.translation = [0, length/2, 0]
        yAxis.name = "\(chirality == .left ? "Left" : "Right")_\(joint)_YAxis"
        axes.append(yAxis)

        // Z軸（青色）
        let zAxis = ModelEntity(
            mesh: .generateCylinder(height: length, radius: radius),
            materials: [UnlitMaterial(color: .blue)]
        )
        // Z軸方向に向ける（X軸周りに90度回転）
        zAxis.transform.rotation = simd_quatf(angle: .pi/2, axis: [1, 0, 0])
        // 0の座標からプラス方向に配置
        zAxis.transform.translation = [0, 0, length/2]
        zAxis.name = "\(chirality == .left ? "Left" : "Right")_\(joint)_ZAxis"
        axes.append(zAxis)

        return axes
    }

    @MainActor
    private func createBones(for chirality: AnchoringComponent.Target.Chirality, handJoints: [HandSkeleton.JointName], handComponent: HandTrackingComponent) {
        // 骨の接続定義（簡略化）
        let boneConnections: [(parent: HandSkeleton.JointName, child: HandSkeleton.JointName)] = [
            // 親指
            (.thumbKnuckle, .thumbIntermediateBase),
            (.thumbIntermediateBase, .thumbIntermediateTip),
            (.thumbIntermediateTip, .thumbTip),

            // 人差し指（簡略化）
            (.indexFingerKnuckle, .indexFingerIntermediateTip),
            (.indexFingerIntermediateTip, .indexFingerTip),

            // 中指（簡略化）
            (.middleFingerKnuckle, .middleFingerIntermediateTip),
            (.middleFingerIntermediateTip, .middleFingerTip),

            // 薬指（簡略化）
            (.ringFingerKnuckle, .ringFingerIntermediateTip),
            (.ringFingerIntermediateTip, .ringFingerTip),

            // 小指（簡略化）
            (.littleFingerKnuckle, .littleFingerIntermediateTip),
            (.littleFingerIntermediateTip, .littleFingerTip)
        ]

        // 各骨に対してコンテナエンティティを作成
        for (parentJoint, childJoint) in boneConnections {
            let boneContainer = Entity()
            boneContainer.name = "\(chirality == .left ? "Left" : "Right")_Bone_\(parentJoint)_to_\(childJoint)"

            // 骨の円柱を作成
            let cylinder = ModelEntity(
                mesh: .generateCylinder(height: 0.02, radius: 0.002),
                materials: [UnlitMaterial(color: chirality == .left ? .systemRed : .systemBlue)]
            )

            boneContainer.addChild(cylinder)
            handEntitiesContainerEntity.addChild(boneContainer)
        }
    }



    // MARK: - ヘルパー関数

    @MainActor
    private func findEntity(named name: String) -> Entity? {
        return findEntityRecursive(in: rootEntity, named: name)
    }

    @MainActor
    private func findEntityRecursive(in entity: Entity, named name: String) -> Entity? {
        if entity.name == name {
            return entity
        }

        for child in entity.children {
            if let found = findEntityRecursive(in: child, named: name) {
                return found
            }
        }

        return nil
    }

    func requestHandTrackingAuthorization() async {
        // SpatialTrackingSessionでも、ARKitSessionと同様の権限リクエストが必要
        let session = ARKitSession()

        let authorizationResult = await session.requestAuthorization(for: [ARKitSession.AuthorizationType.handTracking])

        switch authorizationResult[ARKitSession.AuthorizationType.handTracking] {
        case .allowed:
            HandGestureLogger.logSystem("Hand tracking authorization granted for SpatialTrackingSession")
        case .denied:
            HandGestureLogger.logError("Hand tracking authorization denied")
        case .notDetermined:
            HandGestureLogger.logSystem("Hand tracking authorization not determined")
        case .none:
            HandGestureLogger.logSystem("Hand tracking authorization unknown")
        @unknown default:
            HandGestureLogger.logSystem("Unknown hand tracking authorization status")
        }
    }
}

#Preview {
    HandGestureRealityView()
}
