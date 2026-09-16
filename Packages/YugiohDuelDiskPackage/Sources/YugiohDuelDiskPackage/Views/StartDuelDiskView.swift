//
//  StartDuelDiskView.swift
//  YugiohDuelDiskPackage
//
//  ImmersiveSpace を開始/停止するためのスタート画面。
//  SamplePages から開かれる Window 内に表示される。
//  対戦(2 人モード)の開始/停止と接続状態の表示もここで行う。
//

#if os(visionOS)
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

public struct StartDuelDiskView: View {
    @Environment(\.duelAppModel) private var duelAppModel
    @Environment(\.duelSessionStore) private var sessionStore
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace

    /// 対戦モードの選択肢(Picker 用)。`DuelMultiplayerController.Mode` は Hashable でないためここで写像する。
    private enum MatchModeOption: String, CaseIterable, Identifiable {
        case off
        case loopbackDemo
        case host
        case guest

        var id: String { rawValue }

        var title: String {
            switch self {
            case .off: "オフ"
            case .loopbackDemo: "1台デモ"
            case .host: "ホスト"
            case .guest: "ゲスト"
            }
        }

        var mode: DuelMultiplayerController.Mode {
            switch self {
            case .off: .off
            case .loopbackDemo: .loopbackDemo
            case .host: .multipeer(.host)
            case .guest: .multipeer(.guest)
            }
        }
    }

    @State private var selectedMatchMode: MatchModeOption = .loopbackDemo
    /// ペア名。同じ部屋に多数のデバイスがいても、同じペア名を入力した相手とだけ接続する(空 = ペア名なし)。
    @AppStorage("duelPairName") private var pairName: String = ""

    public init() {}

    public var body: some View {
        VStack(spacing: 24) {
            Text("Card Battle Demo")
                .font(.system(size: 36, weight: .bold))
            Text("左腕にディスクが装着されます。\n右腕でデッキからドローし、左腕に手札を集めましょう。")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            toggleButton
                .padding(.top, 12)

            Divider()
                .padding(.horizontal, 40)

            matchSection
        }
        .padding(40)
        .frame(maxWidth: 720, maxHeight: 640)
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

    // MARK: - 対戦

    private var multiplayer: DuelMultiplayerController { DuelSharedStore.multiplayer }

    /// 対戦中(モードがオフ以外)かどうか。
    private var isMatchRunning: Bool { multiplayer.mode != .off }

    /// Picker で Multipeer モード(ホスト / ゲスト)が選ばれているか。ペア名欄の表示条件。
    private var isMultipeerModeSelected: Bool {
        selectedMatchMode == .host || selectedMatchMode == .guest
    }

    /// 状態行に出すペア名("" は「なし」)。
    private var activePairNameText: String {
        multiplayer.pairName.isEmpty ? "なし" : multiplayer.pairName
    }

    @ViewBuilder
    private var matchSection: some View {
        VStack(spacing: 16) {
            Text("対戦")
                .font(.title3.weight(.semibold))

            Picker("対戦モード", selection: $selectedMatchMode) {
                ForEach(MatchModeOption.allCases) { option in
                    Text(option.title).tag(option)
                }
            }
            .pickerStyle(.segmented)
            .disabled(isMatchRunning)

            // ペア名は Multipeer モードでだけ意味を持つので、オフ / 1 台デモでは出さない。
            if isMultipeerModeSelected {
                TextField("ペア名(同じ名前同士が接続)", text: $pairName)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .submitLabel(.done)
                    .disabled(isMatchRunning)
                    .frame(maxWidth: 360)
            }

            HStack(spacing: 16) {
                Button(action: startMatch) {
                    Label("開始", systemImage: "play.fill")
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
                .disabled(isMatchRunning || selectedMatchMode == .off)

                Button(role: .destructive, action: stopMatch) {
                    Label("停止", systemImage: "stop.fill")
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.bordered)
                .disabled(!isMatchRunning)
            }

            Text(matchStatusText)
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            // 受信データの解釈失敗(バージョン不一致など)や探索開始失敗は、黙って捨てると
            // 「接続中なのに何も起きない」状態になるため、ここで見えるようにする。
            if let lastError = multiplayer.lastError {
                Text("通信エラー: \(lastError)")
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }
        }
    }

    /// 接続状態 + 相手の名前(+ Multipeer ならペア名)を 1 行にまとめる。
    private var matchStatusText: String {
        let state: String
        switch multiplayer.connectionState {
        case .idle:
            state = isMatchRunning ? "準備中" : "未接続"
        case .waiting:
            switch multiplayer.mode {
            case .multipeer(.host): state = "ゲストを待機中 (ペア: \(activePairNameText))…"
            case .multipeer(.guest): state = "ホストを探索中 (ペア: \(activePairNameText))…"
            default: state = "相手を待っています…"
            }
        case .connected(let peerName):
            state = "接続中: \(peerName)"
        case .disconnected:
            // 一度も `.hello` を受け取っていなければ「接続失敗」、受け取っていれば「切断」。
            // 切断後は Transport が探索を再開するので、相手が戻れば自動で再接続される。
            state = sessionStore.opponentInfo == nil ? "接続できませんでした(相手を再探索中)" : "切断されました(相手を再探索中)"
        }
        var text = state
        if let opponent = sessionStore.opponentInfo {
            text += "  /  相手: \(opponent.displayName) (\(opponent.deviceKind))"
        }
        if case .multipeer = multiplayer.mode, multiplayer.connectionState != .waiting {
            text += "  /  ペア: \(activePairNameText)"
        }
        return text
    }

    /// このデバイスの表示名(相手側に `.hello` で送られる)。
    private var localDisplayName: String {
#if canImport(UIKit)
        let name = UIDevice.current.name
        return name.isEmpty ? "Vision Pro" : name
#else
        return "Vision Pro"
#endif
    }

    private func startMatch() {
        multiplayer.start(mode: selectedMatchMode.mode, displayName: localDisplayName, pairName: pairName)
    }

    private func stopMatch() {
        multiplayer.stop()
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
