//
//  GestureDetectorLogicSlide.swift
//  iOSDC2025Slide
//
//  Created by Claude on 2025/01/09.
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct GestureDetectorLogicSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        HeaderSlide("GestureDetectorの処理ロジック") {
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    // 検出アーキテクチャ
                    VStack(alignment: .leading, spacing: 15) {
                        Text("1. 検出アーキテクチャ")
                            .font(.regularFont)

                        CodeBlockView(
                            """
                            class GestureDetector {
                                // 優先度順にソートされたジェスチャー配列
                                private var sortedGestures: [BaseGestureProtocol]
                                
                                // シリアルジェスチャー専用トラッカー
                                private let serialTracker = SerialGestureTracker()
                                
                                // カテゴリ別インデックス(高速検索用)
                                private var categoryIndex: [GestureCategory: [Int]]
                            }
                            """)
                    }

                    // 判定条件の種類
                    VStack(alignment: .leading, spacing: 15) {
                        Text("2. ジェスチャー判定条件")
                            .font(.regularFont)

                        HStack(spacing: 20) {
                            VStack(alignment: .leading, spacing: 12) {
                                ConditionItem(
                                    icon: "hand.raised", text: "指の状態", detail: "isExtended/isCurled"
                                )
                                ConditionItem(
                                    icon: "arrow.up.and.down", text: "手の向き", detail: "palmDirection"
                                )
                            }

                            VStack(alignment: .leading, spacing: 12) {
                                ConditionItem(
                                    icon: "angle", text: "関節角度", detail: "angleWithParent")
                                ConditionItem(
                                    icon: "ruler", text: "関節距離", detail: "jointToJointDistance")
                            }
                        }
                    }

                    // 検出フロー
                    VStack(alignment: .leading, spacing: 15) {
                        Text("3. 検出フロー")
                            .font(.regularFont)

                        CodeBlockView(
                            """
                            func detectGestures(from components: [HandTrackingComponent]) -> [String] {
                                // 1. シリアルジェスチャーのタイムアウトチェック
                                if serialTracker.isTimedOut() {
                                    serialTracker.reset()
                                }
                                
                                // 2. 優先度順に通常ジェスチャーを検出
                                for gesture in sortedGestures {
                                    if gesture.matches(handData) {
                                        return [gesture.gestureName]
                                    }
                                }
                                
                                // 3. シリアルジェスチャーの進行状態を更新
                                if let serial = checkSerialGesture() {
                                    return handleSerialResult(serial)
                                }
                            }
                            """)
                    }

                    // パフォーマンス最適化
                    VStack(alignment: .leading, spacing: 15) {
                        Text("4. パフォーマンス最適化")
                            .font(.regularFont)

                        VStack(alignment: .leading, spacing: 10) {
                            OptimizationItem(
                                icon: "bolt.fill",
                                title: "カテゴリインデックス",
                                description: "O(1)でカテゴリ別ジェスチャーを取得"
                            )

                            OptimizationItem(
                                icon: "chart.line.uptrend.xyaxis",
                                title: "優先度ソート",
                                description: "頻度の高いジェスチャーを優先的に判定"
                            )

                            OptimizationItem(
                                icon: "scissors",
                                title: "早期リターン",
                                description: "マッチした時点で即座に処理を終了"
                            )
                        }
                    }
                }
            }
        }
    }
}

struct ConditionItem: View {
    let icon: String
    let text: String
    let detail: String

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 35))
                .foregroundColor(.blue)
                .frame(width: 50)

            VStack(alignment: .leading, spacing: 5) {
                Text(text)
                    .font(.captionFont)
                    .fontWeight(.semibold)

                Text(detail)
                    .font(.system(size: 26, design: .monospaced))
                    .foregroundColor(.gray)
            }
        }
    }
}

struct OptimizationItem: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(.orange)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 30, weight: .semibold))

                Text(description)
                    .font(.system(size: 26))
                    .foregroundColor(.gray)
            }
        }
    }
}

#Preview {
    SlidePreview {
        GestureDetectorLogicSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
