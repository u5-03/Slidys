import HandGestureKit
import SwiftUI

/// ジェスチャー検出結果を表示するビュー
public struct GesturesView: View {
    @Environment(\.gestureInfoStore) private var gestureStore

    public init() {}

    public var body: some View {
        List {
            // シリアルジェスチャー進行状況(進行中の場合のみ表示)
            if gestureStore.serialGestureInProgress {
                Section {
                    SerialGestureProgressView(gestureStore: gestureStore)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }
            }

            // セクション1: 検出されたジェスチャー
            DetectedGesturesSection(detectedGestures: gestureStore.detectedGestures)

            // セクション2: 左右の手の詳細情報
            HandDetailsSection(gestureStore: gestureStore)

            // セクション3: デバッグ情報(開発時のみ表示)
            if HandGestureLogger.isDebugEnabled {
                DebugSection(gestureStore: gestureStore)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("ジェスチャー検出")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Text(formattedTimestamp)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }

    // タイムスタンプのフォーマット
    private var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: gestureStore.lastUpdateTimestamp)
    }
}

// MARK: - 検出されたジェスチャーセクション

private struct DetectedGesturesSection: View {
    let detectedGestures: [DetectedGesture]

    var body: some View {
        Section("検出中のジェスチャー") {
            if detectedGestures.isEmpty {
                HStack {
                    Image(systemName: "hand.raised.slash")
                        .foregroundColor(.secondary)
                    Text("ジェスチャーが検出されていません")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 8)
            } else {
                ForEach(Array(detectedGestures.enumerated()), id: \.offset) { _, detected in
                    DetectedGestureRow(detected: detected)
                }
            }
        }
    }
}

private struct DetectedGestureRow: View {
    let detected: DetectedGesture

    var body: some View {
        HStack {
            // アイコン
            Image(
                systemName: detected.gesture.gestureType == .singleHand
                    ? "hand.raised.fill" : "hands.clap.fill"
            )
            .foregroundColor(.green)
            .font(.title2)

            // ジェスチャー情報
            VStack(alignment: .leading, spacing: 4) {
                Text(detected.gesture.gestureName)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(gestureTypeDescription(for: detected))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // 信頼度
            VStack(alignment: .trailing) {
                Text("\(Int(detected.confidence * 100))%")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(confidenceColor(detected.confidence))

                Text("信頼度")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private func gestureTypeDescription(for detected: DetectedGesture) -> String {
        switch detected.gesture.gestureType {
        case .singleHand:
            if let hand = detected.metadata["detectedHand"] as? String {
                return hand == "left" ? "左手" : "右手"
            }
            return "片手"
        case .twoHand:
            if let distance = detected.metadata["palmDistance"] as? Float {
                return "両手 (距離: \(String(format: "%.1f", distance * 100))cm)"
            }
            return "両手"
        }
    }

    private func confidenceColor(_ confidence: Float) -> Color {
        if confidence > 0.8 {
            return .green
        } else if confidence > 0.5 {
            return .orange
        } else {
            return .red
        }
    }
}

// MARK: - 手の詳細情報セクション

private struct HandDetailsSection: View {
    let gestureStore: GestureInfoStore

    var body: some View {
        Section("手の状態") {
            // 左手
            HandDetailRow(
                hand: "左手",
                icon: "hand.raised.fill",
                palmDirection: gestureStore.leftPalmDirection,
                fingerStates: gestureStore.leftFingerStates,
                fingerBendLevels: gestureStore.leftFingerBendLevels,
                fingerDirections: gestureStore.leftFingerDirections,
                chirality: .left
            )

            // 右手
            HandDetailRow(
                hand: "右手",
                icon: "hand.raised.fill",
                palmDirection: gestureStore.rightPalmDirection,
                fingerStates: gestureStore.rightFingerStates,
                fingerBendLevels: gestureStore.rightFingerBendLevels,
                fingerDirections: gestureStore.rightFingerDirections,
                chirality: .right
            )

            // 両手の関係
            if gestureStore.twoHandPalmDistance > 0 {
                TwoHandsRelationRow(
                    distance: gestureStore.twoHandPalmDistance,
                    areFacing: gestureStore.twoHandsAreFacingEachOther
                )
            }
        }
    }
}

private struct HandDetailRow: View {
    let hand: String
    let icon: String
    let palmDirection: PalmDirection
    let fingerStates: [FingerType: Bool]
    let fingerBendLevels: [FingerType: SingleHandGestureData.FingerBendLevel]
    let fingerDirections: [FingerType: GestureDetectionDirection]
    let chirality: HandKind

    @State private var isExpanded = true

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            VStack(alignment: .leading, spacing: 8) {
                // 手のひらの向き
                HStack {
                    Label("手のひらの向き", systemImage: "hand.point.up")
                        .font(.caption)
                    Spacer()
                    Text(palmDirection.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Divider()

                // 指の状態
                VStack(alignment: .leading, spacing: 4) {
                    Text("指の状態")
                        .font(.caption)
                        .fontWeight(.medium)

                    ForEach([FingerType.thumb, .index, .middle, .ring, .little], id: \.self) {
                        finger in
                        if let bendLevel = fingerBendLevels[finger] {
                            VStack(alignment: .leading, spacing: 2) {
                                HStack {
                                    Text(finger.description)
                                        .font(.caption)
                                        .frame(width: 60, alignment: .leading)

                                    // 曲がり具合レベル
                                    HStack(spacing: 4) {
                                        Image(systemName: bendLevelIcon(bendLevel))
                                            .foregroundColor(bendLevelColor(bendLevel))
                                            .font(.caption)

                                        Text(bendLevelDescription(bendLevel))
                                            .font(.caption)
                                            .foregroundColor(bendLevelColor(bendLevel))
                                    }

                                    Spacer()

                                    // 指の向き
                                    if let direction = fingerDirections[finger] {
                                        HStack(spacing: 2) {
                                            Image(systemName: directionIcon(direction))
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                            Text(directionShortDescription(direction))
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding(.vertical, 4)
        } label: {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(hand == "左手" ? .orange : .blue)
                Text(hand)
                    .font(.body)
            }
        }
    }

    // MARK: - Helper Functions

    private func bendLevelIcon(_ level: SingleHandGestureData.FingerBendLevel) -> String {
        switch level {
        case .straight:
            return "line.diagonal"
        case .slightlyBent:
            return "chevron.compact.up"
        case .moderatelyBent:
            return "chevron.up"
        case .heavilyBent:
            return "chevron.up.2"
        case .fullyBent:
            return "circle.fill"
        }
    }

    private func bendLevelColor(_ level: SingleHandGestureData.FingerBendLevel) -> Color {
        switch level {
        case .straight:
            return .green
        case .slightlyBent:
            return .mint
        case .moderatelyBent:
            return .orange
        case .heavilyBent:
            return .red
        case .fullyBent:
            return .purple
        }
    }

    private func bendLevelDescription(_ level: SingleHandGestureData.FingerBendLevel) -> String {
        switch level {
        case .straight:
            return "まっすぐ"
        case .slightlyBent:
            return "少し曲がる"
        case .moderatelyBent:
            return "中程度"
        case .heavilyBent:
            return "かなり曲がる"
        case .fullyBent:
            return "完全に曲がる"
        }
    }

    private func directionIcon(_ direction: GestureDetectionDirection) -> String {
        switch direction {
        case .top:
            return "arrow.up"
        case .bottom:
            return "arrow.down"
        case .forward:
            return "arrow.right"
        case .backward:
            return "arrow.left"
        case .right:
            return "arrow.turn.up.right"
        case .left:
            return "arrow.turn.up.left"
        }
    }

    private func directionShortDescription(_ direction: GestureDetectionDirection) -> String {
        switch direction {
        case .top:
            return "上"
        case .bottom:
            return "下"
        case .forward:
            return "前"
        case .backward:
            return "後"
        case .right:
            return "右"
        case .left:
            return "左"
        }
    }
}

private struct TwoHandsRelationRow: View {
    let distance: Float
    let areFacing: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "hands.clap.fill")
                    .foregroundColor(.purple)
                Text("両手の関係")
                    .font(.body)
            }

            HStack {
                Label("距離", systemImage: "ruler")
                    .font(.caption)
                Spacer()
                Text("\(String(format: "%.1f", distance * 100))cm")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            HStack {
                Label("向かい合い", systemImage: "arrow.left.and.right")
                    .font(.caption)
                Spacer()
                Image(systemName: areFacing ? "checkmark.circle.fill" : "xmark.circle")
                    .foregroundColor(areFacing ? .green : .secondary)
                    .font(.caption)
                Text(areFacing ? "はい" : "いいえ")
                    .font(.caption)
                    .foregroundColor(areFacing ? .green : .secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - デバッグセクション

private struct DebugSection: View {
    let gestureStore: GestureInfoStore

    var body: some View {
        Section("デバッグ情報") {
            // デバッグメッセージ
            if !gestureStore.debugInfo.isEmpty {
                VStack(alignment: .leading) {
                    Text("ログ")
                        .font(.caption)
                        .fontWeight(.medium)
                    Text(gestureStore.debugInfo)
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.vertical, 4)
            }

            // パフォーマンス統計
            if let stats = gestureStore.performanceStats, stats.searchCount > 0 {
                PerformanceStatsRow(stats: stats)
            }

            // 指同士の距離(重要なもののみ表示)
            if !gestureStore.fingerDistances.isEmpty {
                FingerDistancesRow(distances: gestureStore.fingerDistances)
            }
        }
    }
}

private struct PerformanceStatsRow: View {
    let stats: SearchStats

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("パフォーマンス")
                .font(.caption)
                .fontWeight(.medium)

            HStack(spacing: 16) {
                StatItem(label: "検索回数", value: "\(stats.searchCount)")
                StatItem(
                    label: "平均時間", value: String(format: "%.1fms", stats.averageSearchTime * 1000))
                StatItem(label: "マッチ率", value: String(format: "%.0f%%", stats.matchRate * 100))
            }
        }
        .padding(.vertical, 4)
    }
}

private struct StatItem: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
            Text(value)
                .font(.system(.caption, design: .monospaced))
                .fontWeight(.medium)
        }
    }
}

private struct FingerDistancesRow: View {
    let distances: [(finger1: FingerType, finger2: FingerType, distance: Float, hand: HandKind)]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("指同士の距離")
                .font(.caption)
                .fontWeight(.medium)

            // 重要な距離のみ表示(親指と他の指、隣接する指)
            let importantDistances = distances.filter { distance in
                // 親指との距離
                if distance.finger1 == .thumb || distance.finger2 == .thumb {
                    return true
                }
                // 隣接する指の組み合わせ
                let adjacentPairs: [(FingerType, FingerType)] = [
                    (.index, .middle),
                    (.middle, .ring),
                    (.ring, .little),
                ]
                return adjacentPairs.contains { pair in
                    (distance.finger1 == pair.0 && distance.finger2 == pair.1)
                        || (distance.finger1 == pair.1 && distance.finger2 == pair.0)
                }
            }

            ForEach(Array(importantDistances.enumerated()), id: \.offset) { _, distance in
                HStack {
                    Image(systemName: distance.hand == .left ? "l.circle" : "r.circle")
                        .font(.caption2)
                        .foregroundColor(distance.hand == .left ? .orange : .blue)

                    Text(
                        "\(distance.finger1.shortDescription)-\(distance.finger2.shortDescription)"
                    )
                    .font(.caption2)
                    .frame(width: 50, alignment: .leading)

                    // 距離を視覚的に表示
                    let distanceInCm = distance.distance * 100
                    let isClose = distanceInCm < 2.0
                    let isMedium = distanceInCm >= 2.0 && distanceInCm < 5.0

                    HStack(spacing: 2) {
                        Image(
                            systemName: isClose
                                ? "arrow.left.and.right.circle.fill"
                                : isMedium ? "arrow.left.and.right.circle" : "arrow.left.and.right"
                        )
                        .font(.caption2)
                        .foregroundColor(isClose ? .green : isMedium ? .orange : .secondary)

                        Text("\(String(format: "%.1f", distanceInCm))cm")
                            .font(.caption2)
                            .foregroundColor(isClose ? .green : isMedium ? .orange : .secondary)
                    }

                    Spacer()
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    GesturesView()
        .environment(\.gestureInfoStore, GestureInfoStore())
}
