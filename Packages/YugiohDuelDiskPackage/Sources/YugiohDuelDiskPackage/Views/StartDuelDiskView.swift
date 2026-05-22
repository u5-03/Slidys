//
//  StartDuelDiskView.swift
//  YugiohDuelDiskPackage
//
//  ImmersiveSpace を開始/停止するためのスタート画面。
//  SamplePages から開かれる Window 内に表示される。
//

#if os(visionOS)
import SwiftUI

public struct StartDuelDiskView: View {
    @Environment(\.duelAppModel) private var duelAppModel
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace

    public init() {}

    public var body: some View {
        VStack(spacing: 24) {
            Text("Yu-Gi-Oh Duel Disk")
                .font(.system(size: 36, weight: .bold))
            Text("左腕にディスクが装着されます。\n右腕でデッキからドローし、左腕に手札を集めましょう。")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            toggleButton
                .padding(.top, 12)
        }
        .padding(40)
        .frame(maxWidth: 720, maxHeight: 480)
    }

    @ViewBuilder
    private var toggleButton: some View {
        switch duelAppModel.immersiveSpaceState {
        case .closed:
            Button(action: openSpace) {
                Text("ImmersiveSpace を開く")
                    .font(.title2)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
        case .inTransition:
            ProgressView()
        case .open:
            Button(role: .destructive, action: closeSpace) {
                Text("ImmersiveSpace を閉じる")
                    .font(.title2)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.bordered)
        }
    }

    private func openSpace() {
        Task { @MainActor in
            duelAppModel.updateImmersiveSpaceState(.inTransition)
            switch await openImmersiveSpace(id: duelAppModel.immersiveSpaceID) {
            case .opened:
                duelAppModel.updateImmersiveSpaceState(.open)
            case .userCancelled, .error:
                duelAppModel.updateImmersiveSpaceState(.closed)
            @unknown default:
                duelAppModel.updateImmersiveSpaceState(.closed)
            }
        }
    }

    private func closeSpace() {
        Task { @MainActor in
            duelAppModel.updateImmersiveSpaceState(.inTransition)
            await dismissImmersiveSpace()
            duelAppModel.updateImmersiveSpaceState(.closed)
        }
    }
}
#endif
