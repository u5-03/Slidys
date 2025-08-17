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
        VStack(spacing: 40) {
            Text("RealityKit vs ARKit")
                .font(.system(size: 100, weight: .heavy))
                .foregroundStyle(.themeColor)
            
            // 比較表
            VStack(spacing: 0) {
                // ヘッダー
                HStack(spacing: 0) {
                    Text("項目")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.3))
                        .font(.system(size: 45, weight: .bold))
                    
                    Text("RealityKit")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.3))
                        .font(.system(size: 45, weight: .bold))
                    
                    Text("ARKit")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green.opacity(0.3))
                        .font(.system(size: 45, weight: .bold))
                }
                
                // 実装難易度
                ComparisonRow(
                    item: "実装難易度",
                    realityKit: "簡単 👍",
                    arKit: "やや複雑"
                )
                
                // パフォーマンス
                ComparisonRow(
                    item: "パフォーマンス",
                    realityKit: "最適化済み ⚡",
                    arKit: "高速"
                )
                
                // 3D表現
                ComparisonRow(
                    item: "3D表現",
                    realityKit: "ネイティブ対応 ✨",
                    arKit: "別途実装必要"
                )
                
                // カスタマイズ性
                ComparisonRow(
                    item: "カスタマイズ",
                    realityKit: "制限あり",
                    arKit: "柔軟 🔧"
                )
                
                // Vision Pro対応
                ComparisonRow(
                    item: "Vision Pro",
                    realityKit: "完全対応 🥽",
                    arKit: "部分対応"
                )
            }
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 2)
            )
            .padding(.horizontal, 60)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(80)
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
                .padding()
                .font(.system(size: 40))
                .background(Color.gray.opacity(0.1))
            
            Text(realityKit)
                .frame(maxWidth: .infinity)
                .padding()
                .font(.system(size: 40))
                .background(Color.blue.opacity(0.1))
            
            Text(arKit)
                .frame(maxWidth: .infinity)
                .padding()
                .font(.system(size: 40))
                .background(Color.green.opacity(0.1))
        }
    }
}

#Preview {
    SlidePreview {
        FrameworkComparisonSlide()
    }
}