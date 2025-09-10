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
                    // プロトコル階層
                    VStack(alignment: .leading, spacing: 15) {
                        Text("1. プロトコル階層")
                            .font(.regularFont)

                        CodeBlockView(
                            """
                            protocol BaseGestureProtocol {
                                var gestureName: String { get }
                                var priority: Int { get }
                                var gestureType: GestureType { get }
                            }

                            protocol SingleHandGestureProtocol: BaseGestureProtocol {
                                func matches(_ gestureData: SingleHandGestureData) -> Bool
                            }

                            protocol TwoHandsGestureProtocol: BaseGestureProtocol {
                                func matches(_ gestureData: HandsGestureData) -> Bool
                            }
                            """)
                    }

                    // 検出アーキテクチャ
                    VStack(alignment: .leading, spacing: 15) {
                        Text("2. 検出アーキテクチャ")
                            .font(.regularFont)

                        CodeBlockView(
                            """
                            class GestureDetector {
                                // 優先度順にソートされたジェスチャー配列
                                private var sortedGestures: [BaseGestureProtocol]
                                
                                // シリアルジェスチャー専用トラッカー
                                private let serialTracker = SerialGestureTracker()
                                
                                // タイプ別インデックス(高速検索用)
                                private var typeIndex: [GestureType: [Int]]
                            }
                            """)
                    }

                    // 便利な判定メソッド
                    VStack(alignment: .leading, spacing: 15) {
                        Text("3. 便利な判定メソッド")
                            .font(.regularFont)

                        CodeBlockView(
                            """
                            // SingleHandGestureDataで提供される便利メソッド
                            gestureData.isFingerStraight(.index)     // 人差し指が伸びているか
                            gestureData.isFingerBent(.thumb)         // 親指が曲がっているか  
                            gestureData.isPalmFacing(.forward)       // 手のひらが前向きか
                            gestureData.areAllFingersExtended()      // 全指が伸びているか
                            gestureData.isAllFingersBent             // 握り拳状態か

                            // 複数条件の組み合わせ例
                            guard gestureData.isFingerStraight(.index),
                                  gestureData.isFingerStraight(.middle),
                                  gestureData.areAllFingersBentExcept([.index, .middle])
                            else { return false }
                            """)
                    }

                    // 判定条件の種類
                    VStack(alignment: .leading, spacing: 15) {
                        Text("4. ジェスチャー判定条件")
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
                        Text("5. 検出フロー")
                            .font(.regularFont)

                        CodeBlockView(
                            """
                            func detectGestures(from components: [HandTrackingComponent]) -> GestureDetectionResult {
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
