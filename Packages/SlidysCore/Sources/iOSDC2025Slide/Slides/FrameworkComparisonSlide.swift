//
//  FrameworkComparisonSlide.swift
//  iOSDC2025Slide
//
//  Created by Claude on 2025/01/09.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct FrameworkComparisonSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        VStack(spacing: 35) {
            Text("手のトラッキング: RealityKit vs ARKit")
                .font(.system(size: 80, weight: .heavy))
                .foregroundStyle(.themeColor)
            
            // 比較表
            VStack(spacing: 0) {
                // ヘッダー
                HStack(spacing: 0) {
                    Text("比較項目")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(Color.gray.opacity(0.3))
                        .font(.system(size: 42, weight: .bold))
                    
                    Text("RealityKit + ECS")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(Color.blue.opacity(0.3))
                        .font(.system(size: 42, weight: .bold))
                    
                    Text("ARKit + AVP")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(Color.green.opacity(0.3))
                        .font(.system(size: 42, weight: .bold))
                }
                
                // 実装アプローチ
                ComparisonRow(
                    item: "実装方法",
                    realityKit: "AnchorEntity自動追跡",
                    arKit: "手動座標変換"
                )
                
                // 3D表現
                ComparisonRow(
                    item: "3D表現",
                    realityKit: "Entity/ModelEntity直接配置 ✨",
                    arKit: "SceneKitなど別途必要"
                )
                
                // トラッキング精度
                ComparisonRow(
                    item: "トラッキング",
                    realityKit: "予測モード対応 ⚡",
                    arKit: "リアルタイムのみ"
                )
                
                // システム統合
                ComparisonRow(
                    item: "システム統合",
                    realityKit: "ECSパターン採用 🏗️",
                    arKit: "デリゲートパターン"
                )
                
                // パフォーマンス
                ComparisonRow(
                    item: "パフォーマンス",
                    realityKit: "GPU最適化済み",
                    arKit: "CPU処理中心"
                )
                
                // visionOS対応
                ComparisonRow(
                    item: "visionOS",
                    realityKit: "フル機能対応 🥽",
                    arKit: "基本機能のみ"
                )
                
                // 学習コスト
                ComparisonRow(
                    item: "学習コスト",
                    realityKit: "宣言的で直感的",
                    arKit: "詳細な理解が必要 📚"
                )
            }
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 2)
            )
            .padding(.horizontal, 50)
            
            Text("💡 今回はRealityKit + ECSパターンを選択")
                .font(.system(size: 38, weight: .semibold))
                .foregroundColor(.orange)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(60)
        .background(.slideBackgroundColor)
        .foregroundColor(.defaultForegroundColor)
    }
}

struct ComparisonRow: View {
    let item: String
    let realityKit: String
    let arKit: String
    
    var body: some View {
        HStack(spacing: 0) {
            Text(item)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .padding(.horizontal, 10)
                .font(.system(size: 36, weight: .medium))
                .background(Color.gray.opacity(0.1))
            
            Text(realityKit)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .padding(.horizontal, 10)
                .font(.system(size: 36))
                .background(Color.blue.opacity(0.1))
            
            Text(arKit)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .padding(.horizontal, 10)
                .font(.system(size: 36))
                .background(Color.green.opacity(0.1))
        }
    }
}

#Preview {
    SlidePreview {
        FrameworkComparisonSlide()
    }
}