//
//  SerialGestureSystemSlide.swift
//  iOSDC2025Slide
//
//  Created by Claude on 2025/01/20.
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct SerialGestureSystemSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        HeaderSlide("連続ジェスチャーの追跡システム") {
            ScrollView {
                VStack(alignment: .leading, spacing: 35) {
                    // SerialGestureProtocol
                    VStack(alignment: .leading, spacing: 15) {
                        Text("1. SerialGestureProtocol")
                            .font(.regularFont)

                        CodeBlockView(
                            """
                            protocol SerialGestureProtocol {
                                // 順番に検出すべきジェスチャーの配列
                                var gestures: [BaseGestureProtocol] { get }
                                
                                // ジェスチャー間の最大許容時間(秒)
                                var intervalSeconds: TimeInterval { get }
                                
                                // 各ステップの説明(UI表示用)
                                var stepDescriptions: [String] { get }
                            }
                            """)
                    }

                    // SerialGestureTracker
                    VStack(alignment: .leading, spacing: 15) {
                        Text("2. SerialGestureTracker - 状態管理")
                            .font(.regularFont)

                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 20) {
                                Image(systemName: "1.circle.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.blue)
                                Text("現在のジェスチャーインデックスを追跡")
                                    .font(.tinyFont)
                                    .fontWeight(.regular)
                            }

                            HStack(spacing: 20) {
                                Image(systemName: "2.circle.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.green)
                                Text("各ジェスチャー間のタイムアウトを監視")
                                    .font(.tinyFont)
                                    .fontWeight(.regular)
                            }

                            HStack(spacing: 20) {
                                Image(systemName: "3.circle.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.orange)
                                Text("タイムアウトor完了後に状態をリセット")
                                    .font(.tinyFont)
                                    .fontWeight(.regular)
                            }
                        }
                        .padding(.leading, 20)
                    }

                    // 検出フロー
                    VStack(alignment: .leading, spacing: 15) {
                        Text("3. 検出フロー")
                            .font(.regularFont)

                        CodeBlockView(
                            """
                            // 例：「ありがとう」の手話
                            let arigatouGesture = SignLanguageArigatouGesture()
                            // gestures = [
                            //   ArigatouInitialPositionGesture(),  // 両手を同じ高さに
                            //   ArigatouFinalPositionGesture()     // 上に移動した位置に右手を移動
                            // ]

                            // Step 1: 初期位置検出
                            // Step 2: 最終位置検出 → completed ✅
                            """)
                    }

                    // 状態遷移
                    VStack(alignment: .leading, spacing: 15) {
                        Text("4. SerialGestureDetectionResult")
                            .font(.regularFont)

                        HStack(spacing: 30) {
                            StatusCard(
                                title: "progress",
                                color: .blue,
                                description: "次のステップへ進行"
                            )

                            StatusCard(
                                title: "completed",
                                color: .green,
                                description: "全ステップ完了"
                            )

                            StatusCard(
                                title: "timeout",
                                color: .orange,
                                description: "時間切れ"
                            )

                            StatusCard(
                                title: "notMatched",
                                color: .red,
                                description: "不一致"
                            )
                        }
                    }
                }
            }
        }
    }
}

struct StatusCard: View {
    let title: String
    let color: Color
    let description: String

    var body: some View {
        VStack(spacing: 10) {
            Text(title)
                .font(.system(size: 28, weight: .bold, design: .monospaced))
                .foregroundColor(color)

            Text(description)
                .font(.system(size: 22))
                .foregroundColor(.white)
        }
        .padding(15)
        .frame(maxWidth: .infinity)
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}

#Preview {
    SlidePreview {
        SerialGestureSystemSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
