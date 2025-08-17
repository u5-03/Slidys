//
//  Created by yugo.a.sugiyama on 2025/08/17
//  Copyright ©Sugiy All rights reserved.
//

import SwiftUI

public struct StartDemoButton: View {
    @Environment(\.appModel) private var appModel
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    private let fontSize: CGFloat

    public init(fontSize: CGFloat = 18) {
        self.fontSize = fontSize
    }

    public var body: some View {
        Button(action: {
            Task {
                await startImmersiveExperience()
            }
        }) {
            HStack(spacing: fontSize) {
                Image(systemName: "play.fill")
                    .font(.system(size: fontSize, weight: .bold))
                Text(appModel.immersiveSpaceState == .inTransition ? "準備中..." : "体験を開始")
                    .font(.system(size: fontSize, weight: .bold))
                    .fontWeight(.semibold)
            }
            .foregroundStyle(.white)
            .padding(fontSize)
        }
        .buttonStyle(.borderedProminent)
        .disabled(appModel.immersiveSpaceState != .closed)
    }
}

private extension StartDemoButton {
    @MainActor
    func startImmersiveExperience() async {
        // 既に遷移中または開いている場合は何もしない
        guard appModel.immersiveSpaceState == .closed else {
            return
        }

        appModel.updateImmersiveSpaceState(.inTransition)

        switch await openImmersiveSpace(id: appModel.immersiveSpaceID) {
        case .opened:
            // ImmersiveViewのonAppearで.openに設定される
            break
        case .userCancelled, .error:
            appModel.updateImmersiveSpaceState(.closed)
        @unknown default:
            appModel.updateImmersiveSpaceState(.closed)
        }
    }
}

#Preview {
    StartDemoButton()
}
