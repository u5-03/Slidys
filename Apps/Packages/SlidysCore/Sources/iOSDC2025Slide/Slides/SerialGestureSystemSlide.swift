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
                                Text("最初のジェスチャーを検知")
                                    .font(.tinyFont)
                                    .fontWeight(.regular)
                            }

                            HStack(spacing: 20) {
                                Image(systemName: "2.circle.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.green)
                                Text("ジェスチャー間のタイムアウトの待機")
                                    .font(.tinyFont)
                                    .fontWeight(.regular)
                            }

                            HStack(spacing: 20) {
                                Image(systemName: "3.circle.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.orange)
                                Text("最後までジェスチャーを検知するorタイムアウトで状態をリセット")
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
                            gestures = [
                                // Step 1: 初期位置検出
                                ArigatouInitialPositionGesture(),  // 両手を同じ高さに
                                // Step 2: 最終位置検出 or タイムアウト → completed ✅
                                ArigatouFinalPositionGesture()     // 上に移動した位置に右手を移動
                            ]

                            """)
                    }
                }
            }
        }
    }
}

#Preview {
    SlidePreview {
        SerialGestureSystemSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
