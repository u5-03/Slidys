//
//  DuelDemoSlide.swift
//  iOSDC2026Slide
//
//  カードバトル体験のライブデモ起動スライド。
//  visionOS では YugiohDuelDiskPackage の ImmersiveSpace を直接開閉できる。
//  (シーン自体はアプリ側で YugiohDuelDiskScene として登録済み)
//

import SlideKit
import SlidesCore
import SwiftUI
#if canImport(YugiohDuelDiskPackage)
import YugiohDuelDiskPackage
#endif

@Slide
struct DuelDemoSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        VStack(spacing: 40) {
            Text("Demo")
                .font(.system(size: 120, weight: .heavy))
                .foregroundStyle(.themeColor)

            Text("カードを引いて、置いて、召喚する")
                .font(.system(size: 80, weight: .bold))
                .foregroundStyle(.defaultForegroundColor)

#if canImport(YugiohDuelDiskPackage)
            DemoImmersiveSpaceButton()
#else
            Text("visionOSでのみデモは開始できます")
                .font(.system(size: 40))
                .foregroundStyle(.gray)
#endif
        }
        .padding(.horizontal, 100)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(80)
        .background(.slideBackgroundColor)
        .foregroundColor(.defaultForegroundColor)
    }
}

#if canImport(YugiohDuelDiskPackage)
/// スライド内から ImmersiveSpace を開閉するボタン。
/// DuelAppModel は EnvironmentKey の defaultValue 経由で共有インスタンスが入る。
private struct DemoImmersiveSpaceButton: View {
    @Environment(\.duelAppModel) private var duelAppModel
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace

    var body: some View {
        switch duelAppModel.immersiveSpaceState {
        case .closed:
            Button(action: openSpace) {
                Text("デモを開始する")
                    .font(.system(size: 60, weight: .bold))
                    .padding(.horizontal, 40)
                    .padding(.vertical, 20)
            }
            .buttonStyle(.borderedProminent)
        case .inTransition:
            ProgressView()
                .scaleEffect(2)
        case .open:
            Button(role: .destructive, action: closeSpace) {
                Text("デモを終了する")
                    .font(.system(size: 60, weight: .bold))
                    .padding(.horizontal, 40)
                    .padding(.vertical, 20)
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

#Preview {
    SlidePreview {
        DuelDemoSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
