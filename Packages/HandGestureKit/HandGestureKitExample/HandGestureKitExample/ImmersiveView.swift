//
//  ImmersiveView.swift
//  HandGestureKitExample
//
//  Created by HandGestureKit Contributors
//

import SwiftUI
import RealityKit
import ARKit
import HandGestureKit

struct ImmersiveView: View {
    @State private var rootEntity = Entity()
    @State private var handEntitiesContainer = Entity()
    @State private var spatialTrackingSession = SpatialTrackingSession()
    @Environment(AppModel.self) private var appModel
    
    // Gesture detector to use existing gesture implementations
    @State private var gestureDetector = GestureDetector()
    
    var body: some View {
        RealityView { content in
            // Register the gesture tracking system
            GestureTrackingSystem.registerSystem()
            
            // Add root entity to scene
            content.add(rootEntity)
            
            // Setup hand tracking
            await setupHandTracking()
            
            // Add hand entities container
            rootEntity.addChild(handEntitiesContainer)
            
            // Setup gesture detector with existing gestures
            setupGestureDetector()
        }
        .upperLimbVisibility(.hidden)
        .onDisappear {
            Task {
                await spatialTrackingSession.stop()
            }
        }
    }
    
    @MainActor
    private func setupHandTracking() async {
        // Request hand tracking authorization
        let session = ARKitSession()
        let authorizationResult = await session.requestAuthorization(for: [.handTracking])
        
        guard authorizationResult[.handTracking] == .allowed else {
            print("Hand tracking authorization denied")
            return
        }
        
        // Start spatial tracking session
        let configuration = SpatialTrackingSession.Configuration(tracking: [.hand])
        _ = await spatialTrackingSession.run(configuration)
        
        // Create hand anchor entities for visualization
        await createHandAnchors()
    }
    
    @MainActor
    private func createHandAnchors() async {
        // Create anchor entities for all necessary joints (matching HandGestureRealityView)
        let handJoints: [HandSkeleton.JointName] = [
            // Thumb (4 joints)
            .thumbKnuckle, .thumbIntermediateBase, .thumbIntermediateTip, .thumbTip,
            // Index finger (3 joints - excluding metacarpal)
            .indexFingerKnuckle, .indexFingerIntermediateTip, .indexFingerTip,
            // Middle finger (3 joints - excluding metacarpal)
            .middleFingerKnuckle, .middleFingerIntermediateTip, .middleFingerTip,
            // Ring finger (3 joints - excluding metacarpal)
            .ringFingerKnuckle, .ringFingerIntermediateTip, .ringFingerTip,
            // Little finger (3 joints - excluding metacarpal)
            .littleFingerKnuckle, .littleFingerIntermediateTip, .littleFingerTip,
            // Wrist
            .wrist
        ]
        
        for chirality in [AnchoringComponent.Target.Chirality.left, .right] {
            let handEntity = Entity()
            handEntity.name = "\(chirality == .left ? "Left" : "Right")_Hand"
            
            var handComponent = HandTrackingComponent(
                chirality: chirality == .left ? .left : .right
            )
            
            for joint in handJoints {
                // Create sphere for joint visualization (smaller for non-tip joints)
                let radius: Float = joint.description.contains("Tip") || joint == .wrist ? 0.005 : 0.003
                let sphere = ModelEntity(
                    mesh: .generateSphere(radius: radius),
                    materials: [SimpleMaterial(color: chirality == .left ? .blue : .green, isMetallic: false)]
                )
                
                // Create anchor entity for the joint
                guard let handJoint = convertToHandJoint(joint) else { continue }
                let location = AnchoringComponent.Target.HandLocation.joint(for: handJoint)
                let anchorEntity = AnchorEntity(
                    .hand(chirality, location: location),
                    trackingMode: .predicted
                )
                
                anchorEntity.addChild(sphere)
                handEntitiesContainer.addChild(anchorEntity)
                
                // Store in hand component for tracking
                handComponent.fingers[joint] = anchorEntity
            }
            
            handEntity.components.set(handComponent)
            rootEntity.addChild(handEntity)
        }
    }
    
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
    
    private func setupGestureDetector() {
        // Import gesture implementations from HandGesturePackage
        let gestures: [BaseGestureProtocol] = [
            ThumbsUpGesture(),
            ImprovedPeaceSignGesture(),
            PrayerGesture()
        ]
        
        gestureDetector.registerGestures(gestures)
    }
}

// Simple gesture tracking system that uses GestureDetector
struct GestureTrackingSystem: System {
    static let query = EntityQuery(where: .has(HandTrackingComponent.self))
    
    // Static gesture detector instance
    static private var gestureDetector: GestureDetector = {
        let detector = GestureDetector()
        let gestures: [BaseGestureProtocol] = [
            ThumbsUpGesture(),
            ImprovedPeaceSignGesture(),
            PrayerGesture()
        ]
        detector.registerGestures(gestures)
        return detector
    }()
    
    init(scene: RealityFoundation.Scene) {}
    
    func update(context: SceneUpdateContext) {
        // Collect all hand entities
        let handEntities = context.entities(matching: Self.query, updatingSystemWhen: .rendering)
        
        // Detect gestures using the GestureDetector
        let result = Self.gestureDetector.detectGestures(from: Array(handEntities))
        
        // Process detected gestures
        switch result {
        case .success(let detectedGestures):
            var gestureDescriptions: [String] = []
            
            for detected in detectedGestures {
                // Create gesture description
                var gestureDescription = detected.gesture.gestureName
                
                // Add hand information if available
                if let hand = detected.metadata["detectedHand"] as? String {
                    gestureDescription = "\(hand.capitalized) Hand: \(gestureDescription)"
                }
                
                // Add emoji based on gesture name
                if detected.gesture.gestureName.contains("サムズアップ") || 
                   detected.gesture.gestureName.contains("Thumbs") {
                    gestureDescription += " 👍"
                } else if detected.gesture.gestureName.contains("ピース") || 
                          detected.gesture.gestureName.contains("Peace") {
                    gestureDescription += " ✌️"
                } else if detected.gesture.gestureName.contains("Prayer") || 
                          detected.gesture.gestureName.contains("祈") {
                    gestureDescription += " 🙏"
                }
                
                gestureDescriptions.append(gestureDescription)
            }
            
            // Send notification with detected gestures (empty array if none detected)
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: .gestureDetected,
                    object: gestureDescriptions
                )
            }
            
        case .failure(_):
            // Send empty array when no hand data is available
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: .gestureDetected,
                    object: [] as [String]
                )
            }
        }
    }
}

// Import gesture implementations from HandGesturePackage
struct ThumbsUpGesture: SingleHandGestureProtocol {
    var gestureName: String { "Thumbs Up" }
    var priority: Int { 15 }
    
    func matches(_ gestureData: SingleHandGestureData) -> Bool {
        // Check if only thumb is extended
        guard gestureData.isFingerStraight(.thumb) else { return false }
        
        // Check if all other fingers are bent
        let otherFingers: [FingerType] = [.index, .middle, .ring, .little]
        for finger in otherFingers {
            if !gestureData.isFingerBent(finger) {
                return false
            }
        }
        
        // Check if thumb is pointing up
        return gestureData.fingerDirection(for: .thumb) == .top
    }
}

struct ImprovedPeaceSignGesture: SingleHandGestureProtocol {
    var gestureName: String { "Peace Sign" }
    var priority: Int { 9 }
    
    func matches(_ gestureData: SingleHandGestureData) -> Bool {
        // Check if index and middle fingers are extended
        guard gestureData.isFingerStraight(.index) && 
              gestureData.isFingerStraight(.middle) else { return false }
        
        // Check if other fingers are bent
        guard gestureData.isFingerBent(.ring) && 
              gestureData.isFingerBent(.little) else { return false }
        
        // Check if palm is facing forward
        return gestureData.isPalmFacing(.forward)
    }
}

struct PrayerGesture: TwoHandsGestureProtocol {
    var gestureName: String { "Prayer" }
    var priority: Int { 10 }
    
    func matches(_ gestureData: HandsGestureData) -> Bool {
        // Check if palms are close together
        let palmDistance = gestureData.palmCenterDistance
        guard palmDistance < 0.05 else { return false } // 5cm threshold
        
        // Check if hands are at similar height
        let verticalOffset = gestureData.verticalOffset
        guard verticalOffset < 0.08 else { return false } // 8cm threshold
        
        // Check if all fingers are extended (relaxed prayer pose)
        let fingers: [FingerType] = [.thumb, .index, .middle, .ring, .little]
        for finger in fingers {
            // Use relaxed tolerance for prayer pose (70 degrees)
            let leftStraight = gestureData.leftHand.handTrackingComponent.isFingerStraight(
                finger, tolerance: .pi * 70 / 180)
            let rightStraight = gestureData.rightHand.handTrackingComponent.isFingerStraight(
                finger, tolerance: .pi * 70 / 180)
            
            if !leftStraight || !rightStraight {
                return false
            }
        }
        
        // Check if palms are facing each other
        let leftPalmFacingRight = gestureData.leftHand.handTrackingComponent.isPalmFacingDirection(
            .right, tolerance: .pi / 4)
        let rightPalmFacingLeft = gestureData.rightHand.handTrackingComponent.isPalmFacingDirection(
            .left, tolerance: .pi / 4)
        
        return leftPalmFacingRight && rightPalmFacingLeft
    }
}

#Preview {
    ImmersiveView()
        .environment(AppModel())
}
