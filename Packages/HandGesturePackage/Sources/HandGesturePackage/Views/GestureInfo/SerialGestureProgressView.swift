//
//  SerialGestureProgressView.swift
//  HandGesturePackage
//
//  Created by Yugo Sugiyama on 2025/08/07.
//

import HandGestureKit
import SwiftUI

/// シリアルジェスチャーの進行状況を表示するビュー
public struct SerialGestureProgressView: View {
    let gestureStore: GestureInfoStore

    public init(gestureStore: GestureInfoStore) {
        self.gestureStore = gestureStore
    }

    public var body: some View {
        VStack(spacing: 16) {
            // ヘッダー
            HStack {
                Image(systemName: "hands.sparkles.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .symbolEffect(.pulse, isActive: true)

                Text(gestureStore.serialGestureName)
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()

                // ステップ表示(現在のステップは検出待ちを示す)
                Text(
                    "\(gestureStore.serialGestureCurrentStep)/\(gestureStore.serialGestureTotalSteps)"
                )
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
            }

            // タイムインジケーター
            TimeRemainingBar(timeRemaining: gestureStore.serialGestureTimeRemaining)

            // 進行状況バー
            ProgressBar(
                current: gestureStore.serialGestureCurrentStep,
                total: gestureStore.serialGestureTotalSteps
            )

            // ステップリスト
            StepsList(
                descriptions: gestureStore.serialGestureStepDescriptions,
                currentStep: gestureStore.serialGestureCurrentStep
            )
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - 残り時間バー
private struct TimeRemainingBar: View {
    let timeRemaining: TimeInterval

    private var timeColor: Color {
        if timeRemaining > 1.0 {
            return .green
        } else if timeRemaining > 0.5 {
            return .yellow
        } else {
            return .red
        }
    }

    private var progress: Double {
        // 3秒のタイムアウトに対する残り時間の割合
        min(1.0, max(0, timeRemaining / 3.0))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: "timer")
                    .font(.caption)
                    .foregroundColor(timeColor)

                Text("残り時間: \(String(format: "%.1f", timeRemaining))秒")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // 背景
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 6)

                    // 進行状況
                    RoundedRectangle(cornerRadius: 4)
                        .fill(timeColor)
                        .frame(width: geometry.size.width * progress, height: 6)
                        .animation(.linear(duration: 0.1), value: progress)
                }
            }
            .frame(height: 6)
        }
    }
}

// MARK: - 進行状況バー
private struct ProgressBar: View {
    let current: Int
    let total: Int

    private var progress: Double {
        guard total > 0 else { return 0 }
        return Double(current) / Double(total)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // 背景
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 12)

                // 進行状況
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * progress, height: 12)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: progress)
            }
        }
        .frame(height: 12)
    }
}

// MARK: - ステップリスト
private struct StepsList: View {
    let descriptions: [String]
    let currentStep: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(Array(descriptions.enumerated()), id: \.offset) { index, description in
                HStack(spacing: 12) {
                    // ステップインジケーター
                    StepIndicator(
                        stepIndex: index,
                        currentStep: currentStep,
                        isCompleted: index < currentStep,
                        isCurrent: index == currentStep
                    )

                    // 説明テキスト
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(index <= currentStep ? .primary : .secondary)
                        .strikethrough(index < currentStep)

                    Spacer()
                }
                .padding(.vertical, 4)
            }
        }
    }
}

// MARK: - ステップインジケーター
private struct StepIndicator: View {
    let stepIndex: Int
    let currentStep: Int
    let isCompleted: Bool
    let isCurrent: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(backgroundColor)
                .frame(width: 24, height: 24)

            if isCompleted {
                Image(systemName: "checkmark")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            } else if isCurrent {
                Circle()
                    .fill(Color.white)
                    .frame(width: 8, height: 8)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                            .frame(width: 16, height: 16)
                            .scaleEffect(isCurrent ? 1.2 : 1.0)
                            .animation(
                                .easeInOut(duration: 0.6)
                                    .repeatForever(autoreverses: true),
                                value: isCurrent
                            )
                    )
            } else {
                Text("\(stepIndex + 1)")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
            }
        }
    }

    private var backgroundColor: Color {
        if isCompleted {
            return .green
        } else if isCurrent {
            return .blue
        } else {
            return .gray.opacity(0.5)
        }
    }
}
