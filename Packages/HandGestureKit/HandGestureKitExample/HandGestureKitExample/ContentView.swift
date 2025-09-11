//
//  ContentView.swift
//  HandGestureKitExample
//
//  Created by HandGestureKit Contributors
//

import SwiftUI
import HandGestureKit

struct ContentView: View {
    @Environment(AppModel.self) private var appModel
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @State private var detectedGestures: [String] = []
    @State private var showingSettings = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                // Title
                VStack(spacing: 10) {
                    Image(systemName: "hand.wave")
                        .font(.system(size: 60))
                        .foregroundStyle(.blue)
                    
                    Text("HandGestureKit Example")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Detect hand gestures using visionOS")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 20)
                
                // Status Card
                VStack(alignment: .leading, spacing: 15) {
                    Label("Detected Gestures", systemImage: "hand.raised")
                        .font(.headline)
                    
                    if detectedGestures.isEmpty {
                        Text("None")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.gray)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(Array(detectedGestures.enumerated()), id: \.offset) { _, gesture in
                                Text(gesture)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.blue)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(15)
                
                // Control Button
                Button(action: toggleImmersiveSpace) {
                    HStack {
                        Image(systemName: immersiveSpaceButtonIcon)
                        Text(immersiveSpaceButtonTitle)
                    }
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding()
                    .frame(width: 250)
                }
                .buttonStyle(.borderedProminent)
                .disabled(appModel.immersiveSpaceState == .inTransition)
                
                Spacer()
            }
            .padding()
            .frame(width: 500, height: 600)
            .toolbar(.hidden)
        }
        .onReceive(NotificationCenter.default.publisher(for: .gestureDetected)) { notification in
            if let gestures = notification.object as? [String] {
                detectedGestures = gestures
            }
        }
    }
    
    private var immersiveSpaceButtonIcon: String {
        switch appModel.immersiveSpaceState {
        case .closed: return "play.fill"
        case .open: return "stop.fill"
        case .inTransition: return "hourglass"
        }
    }
    
    private var immersiveSpaceButtonTitle: String {
        switch appModel.immersiveSpaceState {
        case .closed: return "Start Detection"
        case .open: return "Stop Detection"
        case .inTransition: return "Loading..."
        }
    }
    
    @MainActor
    private func toggleImmersiveSpace() {
        Task {
            switch appModel.immersiveSpaceState {
            case .closed:
                appModel.immersiveSpaceState = .inTransition
                switch await openImmersiveSpace(id: appModel.immersiveSpaceID) {
                case .opened:
                    appModel.immersiveSpaceState = .open
                case .userCancelled, .error:
                    appModel.immersiveSpaceState = .closed
                @unknown default:
                    appModel.immersiveSpaceState = .closed
                }
            case .open:
                appModel.immersiveSpaceState = .inTransition
                await dismissImmersiveSpace()
                appModel.immersiveSpaceState = .closed
                detectedGestures = []
            case .inTransition:
                break
            }
        }
    }
}

// Notification extension for gesture detection
extension Notification.Name {
    static let gestureDetected = Notification.Name("gestureDetected")
}

#Preview {
    ContentView()
        .environment(AppModel())
}