//
//  ImmersiveSpaceControlButton.swift
//  HandGesturePackage
//
//  Created by Claude on 2025/01/09.
//

import SwiftUI

/// ImmersiveSpaceの開始/停止を制御するボタン
public struct ImmersiveSpaceControlButton: View {
    @Environment(\.appModel) private var appModel
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    
    private let fontSize: CGFloat
    
    public init(fontSize: CGFloat = 18) {
        self.fontSize = fontSize
    }
    
    public var body: some View {
        Button(action: {
            Task {
                await toggleImmersiveSpace()
            }
        }) {
            HStack(spacing: fontSize * 0.5) {
                Image(systemName: buttonIcon)
                    .font(.system(size: fontSize, weight: .bold))
                Text(buttonTitle)
                    .font(.system(size: fontSize, weight: .bold))
                    .fontWeight(.semibold)
            }
            .foregroundStyle(.white)
            .padding(fontSize)
        }
        .buttonStyle(.borderedProminent)
        .disabled(appModel.immersiveSpaceState == .inTransition)
    }
    
    private var buttonIcon: String {
        switch appModel.immersiveSpaceState {
        case .closed: return "play.fill"
        case .open: return "stop.fill"
        case .inTransition: return "hourglass"
        }
    }
    
    private var buttonTitle: String {
        switch appModel.immersiveSpaceState {
        case .closed: return "体験を開始"
        case .open: return "体験を停止"
        case .inTransition: return "準備中..."
        }
    }
    
    @MainActor
    private func toggleImmersiveSpace() async {
        switch appModel.immersiveSpaceState {
        case .closed:
            await startImmersiveExperience()
        case .open:
            await stopImmersiveExperience()
        case .inTransition:
            // 遷移中は何もしない
            break
        }
    }
    
    @MainActor
    private func startImmersiveExperience() async {
        appModel.updateImmersiveSpaceState(.inTransition)
        
        switch await openImmersiveSpace(id: appModel.immersiveSpaceID) {
        case .opened:
            appModel.updateImmersiveSpaceState(.open)
            break
        case .userCancelled, .error:
            appModel.updateImmersiveSpaceState(.closed)
        @unknown default:
            appModel.updateImmersiveSpaceState(.closed)
        }
    }
    
    @MainActor
    private func stopImmersiveExperience() async {
        appModel.updateImmersiveSpaceState(.inTransition)
        
        await dismissImmersiveSpace()
        appModel.updateImmersiveSpaceState(.closed)
    }
}

#Preview {
    ImmersiveSpaceControlButton()
}
