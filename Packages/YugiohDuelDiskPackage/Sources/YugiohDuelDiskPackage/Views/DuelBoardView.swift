//
//  DuelBoardView.swift
//  YugiohDuelDiskPackage
//
//  iPhone 用の 2D デュエルボード。
//  対戦モード(Multiplayer/)の iPhone 側 UI として、相手(Vision Pro)のフィールドを
//  読み取り専用で表示しつつ、自分の手札からモンスター召喚 / 魔法・トラップ設置を行う。
//  盤面の変更は `DuelSessionStore` の既存操作を呼ぶだけで、送信は Store の eventSink が担う。
//
//  縦画面レイアウト(上 → 下):
//    対戦バー(モード選択 / 開始・停止 / 接続状態)
//    相手フィールド(手前列 = 魔法・トラップ, 奥列 = モンスター)   ※180° 回転した盤面のミラー
//    センターライン(VS / 名前)
//    自分フィールド(奥列 = モンスター, 手前列 = 魔法・トラップ)
//    手札(横スクロール)+ ドロー / 新しいデュエル
//

#if os(iOS)
import SwiftUI
import UIKit
import YugiohCardEffect

public struct DuelBoardView: View {
    /// 対戦バーのモード選択肢。`DuelMultiplayerController.Mode` への薄いラッパー。
    private enum MatchModeOption: String, CaseIterable, Identifiable {
        case loopbackDemo
        case host
        case guest

        var id: String { rawValue }

        var displayName: String {
            switch self {
            case .loopbackDemo: return "1台デモ"
            case .host: return "ホスト"
            case .guest: return "ゲスト"
            }
        }

        var controllerMode: DuelMultiplayerController.Mode {
            switch self {
            case .loopbackDemo: return .loopbackDemo
            case .host: return .multipeer(.host)
            case .guest: return .multipeer(.guest)
            }
        }
    }

    @Environment(\.duelSessionStore) private var store
    private let multiplayer = DuelSharedStore.multiplayer

    @State private var selectedMode: MatchModeOption = .loopbackDemo
    /// 配置済みカードをタップしたときの確認ダイアログ用コンテキスト。
    @State private var tappedContext: PlacedCardContext?
    /// 種類不一致など、操作を拒否したときに一時表示するメッセージ。
    @State private var feedbackMessage: String?
    @State private var feedbackTask: Task<Void, Never>?
    /// 拡大表示シートに出すカード。`nil` でシートを閉じる。
    @State private var previewCard: DuelCard?
    /// 相手に見せる表示名。`UIDevice.current.name` は特別な entitlement なしでは "iPhone" 固定になるため、
    /// 初回に "iPhone-XXXX" を生成して永続化し、ユーザーが自由に変更できるようにする。
    @AppStorage("duelDisplayName") private var displayName: String = ""
    @State private var isEditingDisplayName = false
    @State private var draftDisplayName = ""
    /// Multipeer で探索が長引いたときにヒントを出すためのタイマー。
    @State private var searchTimeoutTask: Task<Void, Never>?
    @State private var showsSearchHint = false

    private let columnSpacing: CGFloat = 6
    private let rowSpacing: CGFloat = 8

    public init() {}

    public var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 14) {
                matchBar
                opponentField
                centerDivider
                myField
                handSection
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .background(Color(.systemGroupedBackground))
        .onAppear {
            if displayName.isEmpty {
                displayName = Self.makeDefaultDisplayName()
            }
            // 固定配布は 6 枚(手札上限 10 枚)なので、普通に対戦していれば手札は空になる。
            // 「手札が空」だけを条件にすると、閉じて開き直しただけで自分のフィールドが消え、
            // 相手にも `.newDuel` が送られてしまう。盤面が一度も始まっていないときだけ配る。
            if isDuelUntouched {
                store.startNewDuel()
            }
        }
        .onDisappear {
            searchTimeoutTask?.cancel()
        }
        .onChange(of: multiplayer.connectionState) { _, state in
            if state != .waiting {
                cancelSearchTimeout()
            }
        }
        .confirmationDialog(
            tappedCardTitle,
            isPresented: Binding(
                get: { tappedContext != nil },
                set: { if !$0 { tappedContext = nil } }
            ),
            titleVisibility: .visible,
            presenting: tappedContext
        ) { context in
            Button("拡大表示") { previewCard = placedCard(at: context) }
            if store.canOpenCard(at: context) {
                Button("オープン") { store.openPlacedCard(at: context) }
            }
            Button("削除", role: .destructive) { store.removePlacedCard(at: context) }
            Button("キャンセル", role: .cancel) { tappedContext = nil }
        }
        .sheet(item: $previewCard) { card in
            DuelCardPreviewSheet(card: card)
        }
        .alert("表示名を変更", isPresented: $isEditingDisplayName) {
            TextField("表示名", text: $draftDisplayName)
            Button("保存") {
                let trimmed = draftDisplayName.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty {
                    displayName = trimmed
                }
            }
            Button("キャンセル", role: .cancel) {}
        } message: {
            Text("相手に表示される名前です。次回の開始から反映されます。")
        }
    }

    /// 手札もフィールドもすべて空 = まだ一度もデュエルを始めていない状態。
    private var isDuelUntouched: Bool {
        store.hand.isEmpty
            && store.fieldBackRow.allSatisfy { $0 == nil }
            && store.fieldFrontRow.allSatisfy { $0 == nil }
            && store.diskSlots.allSatisfy { $0 == nil }
            && store.spellSlots.allSatisfy { $0 == nil }
    }

    /// 初回起動時の表示名。"iPhone-" + 英数字 4 文字。
    private static func makeDefaultDisplayName() -> String {
        let alphabet = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
        let suffix = String((0..<4).map { _ in alphabet.randomElement()! })
        return "iPhone-" + suffix
    }

    /// 相手陣の表示位置(左→右)を、相手側の列番号に変換する(左右反転)。
    /// 向かい合っているので、相手の列 0(相手の左端)はこちらの右端に表示する。
    static func mirroredColumn(_ displayIndex: Int) -> Int {
        DuelSessionStore.diskSlotCount - 1 - displayIndex
    }

    // MARK: - 対戦バー

    private var matchBar: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("デュエルボード")
                    .font(.headline)
                Spacer()
                // 右上は SamplePageView の閉じるボタンと重なるため空けておく。
                Color.clear.frame(width: 40, height: 1)
            }
            HStack(spacing: 8) {
                Picker("モード", selection: $selectedMode) {
                    ForEach(MatchModeOption.allCases) { option in
                        Text(option.displayName).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .disabled(isMatchRunning)

                if isMatchRunning {
                    Button("停止", role: .destructive) {
                        stopMatch()
                    }
                    .buttonStyle(.bordered)
                } else {
                    Button("開始") {
                        startMatch(mode: selectedMode.controllerMode)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            HStack(spacing: 6) {
                Circle()
                    .fill(connectionColor)
                    .frame(width: 8, height: 8)
                Text(connectionStatusText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                if multiplayer.connectionState == .disconnected {
                    Button("再接続") {
                        reconnect()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            }
            if showsSearchHint, multiplayer.connectionState == .waiting {
                Text("相手が見つかりません。相手側で開始しているか、設定 > プライバシーとセキュリティ > ローカルネットワーク で Slidys が許可されているか確認してください")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            // 受信データの解釈失敗(バージョン不一致など)や探索開始失敗は、黙って捨てると
            // 「接続中なのに何も起きない」状態になるため、ここで見えるようにする。
            if let lastError = multiplayer.lastError {
                Text("通信エラー: \(lastError)")
                    .font(.caption2)
                    .foregroundStyle(.red)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
    }

    private var isMatchRunning: Bool {
        multiplayer.mode != .off
    }

    private func startMatch(mode: DuelMultiplayerController.Mode) {
        multiplayer.start(mode: mode, displayName: displayName)
        scheduleSearchTimeout()
    }

    private func stopMatch() {
        cancelSearchTimeout()
        multiplayer.stop()
    }

    /// 切断後に同じモードで接続をやり直す。`stop()` で mode が `.off` に戻るため先に控えておく。
    private func reconnect() {
        let mode = multiplayer.mode
        stopMatch()
        startMatch(mode: mode)
    }

    /// Multipeer モードで開始後 20 秒たっても `.waiting` のままなら、ローカルネットワーク許可などのヒントを出す。
    /// ローカルネットワークが拒否されていたり相手がいない場合、`connectionState` は永遠に `.waiting` のままになるため。
    private func scheduleSearchTimeout() {
        cancelSearchTimeout()
        guard case .multipeer = multiplayer.mode else { return }
        searchTimeoutTask = Task {
            try? await Task.sleep(for: .seconds(20))
            guard !Task.isCancelled else { return }
            if multiplayer.connectionState == .waiting {
                showsSearchHint = true
            }
        }
    }

    private func cancelSearchTimeout() {
        searchTimeoutTask?.cancel()
        searchTimeoutTask = nil
        showsSearchHint = false
    }

    private var connectionColor: Color {
        switch multiplayer.connectionState {
        case .idle: return .gray
        case .waiting: return .yellow
        case .connected: return .green
        case .disconnected: return .red
        }
    }

    private var connectionStatusText: String {
        switch multiplayer.connectionState {
        case .idle:
            return "未接続(モードを選んで開始)"
        case .waiting:
            switch multiplayer.mode {
            case .multipeer(.host): return "ゲストを待機中…"
            case .multipeer(.guest): return "ホストを探索中…"
            default: return "接続中…"
            }
        case .connected(let peerName):
            if let info = store.opponentInfo {
                return "接続中: \(info.displayName) (\(info.deviceKind))"
            }
            return "接続中: \(peerName)"
        case .disconnected:
            // `.hello` を受け取る前に切れた = 一度も繋がっていない。
            return store.opponentInfo == nil ? "接続できませんでした" : "切断されました"
        }
    }

    // MARK: - 相手フィールド

    private var opponentField: some View {
        VStack(spacing: rowSpacing) {
            fieldHeader(
                title: store.opponentInfo?.displayName ?? "相手",
                subtitle: "相手フィールド",
                alignment: .leading
            )
            // 相手の盤面は 180° 回転して向かい合っている(visionOS 側の相手陣と同じ)。
            // 相手から見た列 0(相手の左端)は、こちらから見ると右端に来るので、
            // 表示位置 → 列番号 を左右反転して参照する。
            // 相手の手前列(魔法・トラップ)。相手側から見て手前 = こちらから見て奥。
            cardRow(count: DuelSessionStore.diskSlotCount) { displayIndex in
                let index = Self.mirroredColumn(displayIndex)
                DuelCardCellView(
                    card: store.opponentFieldFrontRow[index],
                    isFaceDown: store.opponentFieldFrontRevealed[index] == false,
                    placeholderSymbol: "sparkles"
                )
            }
            // 相手の奥列(モンスター)。センターラインに最も近い列。
            cardRow(count: DuelSessionStore.diskSlotCount) { displayIndex in
                let index = Self.mirroredColumn(displayIndex)
                DuelCardCellView(
                    card: store.opponentFieldBackRow[index],
                    isFaceDown: false,
                    placeholderSymbol: "pawprint"
                )
            }
        }
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
        .overlay {
            if !store.isMultiplayerActive {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        Text("対戦を開始すると相手のフィールドが表示されます")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                    .allowsHitTesting(false)
            }
        }
    }

    // MARK: - センターライン

    private var centerDivider: some View {
        HStack(spacing: 12) {
            Rectangle()
                .fill(.secondary.opacity(0.4))
                .frame(height: 1)
            Text("VS")
                .font(.caption.bold())
                .foregroundStyle(.secondary)
            Rectangle()
                .fill(.secondary.opacity(0.4))
                .frame(height: 1)
        }
    }

    // MARK: - 自分フィールド

    private var myField: some View {
        VStack(spacing: rowSpacing) {
            fieldHeader(
                title: displayName,
                subtitle: "自分フィールド",
                alignment: .leading,
                onEditTitle: {
                    draftDisplayName = displayName
                    isEditingDisplayName = true
                }
            )
            // 奥列(モンスター)。センターラインに最も近い列。
            cardRow(count: DuelSessionStore.diskSlotCount) { index in
                myFieldCell(context: .fieldBack(index), card: store.fieldBackRow[index], isFaceDown: false)
            }
            // 手前列(魔法・トラップ)。
            cardRow(count: DuelSessionStore.diskSlotCount) { index in
                myFieldCell(
                    context: .fieldFront(index),
                    card: store.fieldFrontRow[index],
                    isFaceDown: store.fieldFrontRevealed[index] == false
                )
            }
            if let feedbackMessage {
                Text(feedbackMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .transition(.opacity)
            }
        }
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
        .animation(.easeInOut(duration: 0.2), value: feedbackMessage)
    }

    /// 自分フィールドの 1 マス。空マスは選択中カードの種類に応じて配置可否を見た目で示す。
    private func myFieldCell(context: PlacedCardContext, card: DuelCard?, isFaceDown: Bool) -> some View {
        let acceptsKind = Self.acceptedKind(for: context)
        let selectedKind = store.selectedCardKind
        let isDropTarget = card == nil && selectedKind != nil && Self.matches(kind: selectedKind, accepted: acceptsKind)
        let isDimmed = card == nil && selectedKind != nil && !Self.matches(kind: selectedKind, accepted: acceptsKind)

        return DuelCardCellView(
            card: card,
            isFaceDown: isFaceDown,
            placeholderSymbol: acceptsKind == .monster ? "pawprint" : "sparkles",
            isHighlighted: isDropTarget,
            isDimmed: isDimmed
        )
        // 自分がセットした裏側カードは、持ち主だけが分かるようにカード名を小さく添える(相手側には出さない)。
        .overlay(alignment: .bottom) {
            if let card, isFaceDown {
                Text(Self.cardName(card))
                    .font(.caption2)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(.ultraThinMaterial, in: Capsule())
                    .padding(.bottom, 4)
                    .padding(.horizontal, 2)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            handleMyFieldTap(context: context, card: card)
        }
    }

    private func handleMyFieldTap(context: PlacedCardContext, card: DuelCard?) {
        if card != nil {
            tappedContext = context
            return
        }
        guard let selected = store.selectedCard else {
            showFeedback("手札からカードを選んでください")
            return
        }
        switch context {
        case .fieldBack(let index), .diskSlot(let index):
            guard selected.kind == .monster else {
                showFeedback("奥列にはモンスターのみ配置できます")
                return
            }
            store.placeSelectedCardToDiskSlot(index: index)
        case .fieldFront(let index), .spellSlot(let index):
            guard selected.isSpellOrTrap else {
                showFeedback("手前列には魔法・トラップのみ配置できます")
                return
            }
            store.placeSelectedCardToSpellSlot(index: index)
        }
    }

    private func showFeedback(_ message: String) {
        feedbackTask?.cancel()
        feedbackMessage = message
        feedbackTask = Task {
            try? await Task.sleep(for: .seconds(1.5))
            guard !Task.isCancelled else { return }
            feedbackMessage = nil
        }
    }

    /// 自分フィールドの各列が受け付けるカード種別(奥列 = モンスター / 手前列 = 魔法・トラップ)。
    private enum AcceptedKind {
        case monster
        case spellOrTrap
    }

    private static func acceptedKind(for context: PlacedCardContext) -> AcceptedKind {
        switch context {
        case .fieldBack, .diskSlot: return .monster
        case .fieldFront, .spellSlot: return .spellOrTrap
        }
    }

    private static func matches(kind: DuelCard.Kind?, accepted: AcceptedKind) -> Bool {
        guard let kind else { return false }
        switch accepted {
        case .monster: return kind == .monster
        case .spellOrTrap: return kind == .spell || kind == .trap
        }
    }

    private var tappedCardTitle: String {
        guard let context = tappedContext else { return "" }
        return placedCard(at: context).map(Self.cardName) ?? "カードを操作"
    }

    /// 自分フィールドの指定マスに置かれているカード。
    private func placedCard(at context: PlacedCardContext) -> DuelCard? {
        switch context {
        case .fieldBack(let i), .diskSlot(let i):
            return store.fieldBackRow[i]
        case .fieldFront(let i), .spellSlot(let i):
            return store.fieldFrontRow[i]
        }
    }

    // MARK: - 手札

    private var handSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("手札 \(store.hand.count)/\(DuelSessionStore.handCapacity)")
                    .font(.subheadline.bold())
                Spacer()
                Button {
                    store.drawCard()
                    store.addRightHandCardToFan()
                } label: {
                    Label("ドロー", systemImage: "rectangle.stack.badge.plus")
                }
                .buttonStyle(.bordered)
                .disabled(store.hand.count >= DuelSessionStore.handCapacity)
                Button {
                    store.startNewDuel()
                } label: {
                    Label("新しいデュエル", systemImage: "arrow.counterclockwise")
                }
                .buttonStyle(.bordered)
            }
            if store.hand.isEmpty {
                Text("手札がありません。ドローしてください。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 80)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(store.hand) { card in
                            DuelCardCellView(
                                card: card,
                                isFaceDown: false,
                                placeholderSymbol: "",
                                isHighlighted: store.selectedHandCardId == card.id
                            )
                            // 実カードの UI をそのまま使うため、文字が読める程度に盤面のマスより大きく表示する。
                            .frame(width: 112)
                            .offset(y: store.selectedHandCardId == card.id ? -8 : 0)
                            .onTapGesture {
                                store.selectHandCard(id: card.id)
                            }
                            // 長押しで拡大表示(タップは選択のまま)。
                            .onLongPressGesture {
                                previewCard = card
                            }
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 2)
                }
                .animation(.spring(duration: 0.25), value: store.selectedHandCardId)
            }
        }
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - 共通部品

    /// フィールド見出し。`onEditTitle` を渡すと名前部分がタップ可能になり、鉛筆アイコンを添える。
    private func fieldHeader(
        title: String,
        subtitle: String,
        alignment: HorizontalAlignment,
        onEditTitle: (() -> Void)? = nil
    ) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            if let onEditTitle {
                Button(action: onEditTitle) {
                    HStack(spacing: 4) {
                        Text(title)
                            .font(.subheadline.bold())
                            .lineLimit(1)
                        Image(systemName: "pencil")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .buttonStyle(.plain)
            } else {
                Text(title)
                    .font(.subheadline.bold())
                    .lineLimit(1)
            }
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
        }
    }

    private func cardRow<Cell: View>(count: Int, @ViewBuilder cell: @escaping (Int) -> Cell) -> some View {
        HStack(spacing: columnSpacing) {
            ForEach(0..<count, id: \.self) { index in
                cell(index)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    static func cardName(_ card: DuelCard) -> String {
        switch card {
        case .monster(let m): return m.name
        case .spell(let s): return s.name
        case .trap(let t): return t.name
        }
    }
}

// MARK: - カード 1 枚分のセル

/// 盤面 / 手札で使うカード表示。
/// visionOS デモと同じ `YugiohCardEffect` の `CardView` / `CardBackView` をそのまま使い、
/// 見た目を実カードと一致させる(`CardView` は親サイズに合わせて自動でスケールする)。
/// - `card == nil`: 空マス(点線枠 + プレースホルダーシンボル)
/// - `isFaceDown`: 裏面(`CardBackView`)
/// - それ以外: 表面(`CardView`)
struct DuelCardCellView: View {
    /// カードの縦横比。`CardView` のデザインサイズ(590 × 860)に合わせる。
    static let aspectRatio: CGFloat = CGFloat(DuelCardVisualFactory.designWidth / DuelCardVisualFactory.designHeight)

    let card: DuelCard?
    var isFaceDown: Bool = false
    var placeholderSymbol: String = ""
    var isHighlighted: Bool = false
    var isDimmed: Bool = false

    var body: some View {
        ZStack {
            if let card {
                Group {
                    if isFaceDown {
                        CardBackView()
                    } else {
                        CardView(card: DuelCardVisualFactory.visualModel(for: card))
                    }
                }
                // カード絵は表示専用にして当たり判定から外す。
                // `CardView` は内部で 590×860 の固定フレームを作ってから scaleEffect で縮めるため、
                // 縮小前の領域が隣のセルまではみ出してヒット判定に残り、HStack で後ろ(=上)に並ぶ
                // カードが手前のカードへのタップを横取りしていた(左端を押すと真ん中が選ばれる)。
                .allowsHitTesting(false)
            } else {
                emptySlot
            }
        }
        .aspectRatio(Self.aspectRatio, contentMode: .fit)
        // `CardView` は角が直角なので、ハイライト枠と同じ角丸で切り抜いてシルエットを揃える。
        .clipShape(RoundedRectangle(cornerRadius: 6))
        // 当たり判定はセルの見た目の範囲(角丸の矩形)に限定する。
        .contentShape(RoundedRectangle(cornerRadius: 6))
        .overlay {
            RoundedRectangle(cornerRadius: 6)
                .strokeBorder(isHighlighted ? Color.accentColor : .clear, lineWidth: 3)
        }
        .opacity(isDimmed ? 0.35 : 1)
        .animation(.easeInOut(duration: 0.15), value: isHighlighted)
        .animation(.easeInOut(duration: 0.15), value: isDimmed)
    }

    // MARK: 空マス

    private var emptySlot: some View {
        RoundedRectangle(cornerRadius: 6)
            .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
            .foregroundStyle(.secondary.opacity(0.5))
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(.tertiarySystemGroupedBackground))
            )
            .overlay {
                if !placeholderSymbol.isEmpty {
                    Image(systemName: placeholderSymbol)
                        .font(.caption)
                        .foregroundStyle(.secondary.opacity(0.4))
                }
            }
    }
}

// MARK: - カード拡大表示シート

/// 盤面のマス(約 62pt)や手札(112pt)では文字が読めないため、実カードの `CardView` を
/// 画面幅の約 90% に拡大して表示するシート。
private struct DuelCardPreviewSheet: View {
    @Environment(\.dismiss) private var dismiss
    let card: DuelCard

    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                // 幅 90% を基準にしつつ、横向きなどで高さが足りない場合は高さに合わせる。
                let width = min(
                    proxy.size.width * 0.9,
                    proxy.size.height * 0.9 * DuelCardCellView.aspectRatio
                )
                CardView(card: DuelCardVisualFactory.visualModel(for: card))
                    .frame(width: width, height: width / DuelCardCellView.aspectRatio)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(DuelBoardView.cardName(card))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("閉じる") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    DuelBoardView()
}
#endif
