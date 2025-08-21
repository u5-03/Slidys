//
//  SerialGestureSystemSlide.swift
//  iOSDC2025Slide
//
//  Created by Claude on 2025/01/20.
//

import SwiftUI
import SlideKit
import SlidesCore

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
                        
                        CodeBlockView("""
                        protocol SerialGestureProtocol {
                            // 順番に検出すべきジェスチャーの配列
                            var gestures: [BaseGestureProtocol] { get }
                            
                            // ジェスチャー間の最大許容時間（秒）
                            var intervalSeconds: TimeInterval { get }
                            
                            // 各ステップの説明（UI表示用）
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
                                Text("完了後のクールダウン期間を管理")
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
                        
                        CodeBlockView("""
                        // 例：「ありがとう」の手話
                        let thankyouGesture = ThankYouSignGesture()
                        // gestures = [OpenHand, MoveDown, CloseHand]
                        
                        // Step 1: OpenHand検出 → progress(0)
                        // Step 2: MoveDown検出 → progress(1)  
                        // Step 3: CloseHand検出 → completed ✅
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
                .padding(.horizontal, 60)
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
                .foregroundColor(.gray)
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
}