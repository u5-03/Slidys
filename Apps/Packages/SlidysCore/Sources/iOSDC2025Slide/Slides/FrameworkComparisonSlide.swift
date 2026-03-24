//
//  FrameworkComparisonSlide.swift
//  iOSDC2025Slide
//
//  Created by Claude on 2025/01/09.
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct FrameworkComparisonSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    private let itemColumnWidth: CGFloat = 264

    var body: some View {
        HeaderSlide("RealityKitとARKitのEntity配置の実装比較") {
            // 比較表
            VStack(spacing: 0) {
                // ヘッダー
                HStack(spacing: 0) {
                    Text("比較項目")
                        .padding(.vertical, 20)
                        .frame(width: itemColumnWidth)
                        .background(Color.gray.opacity(0.5))
                        .font(.system(size: 38, weight: .bold))

                    Text("RealityKit(AnchorEntity)")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(Color.blue.opacity(0.5))
                        .font(.system(size: 42, weight: .bold))

                    Text("ARKit(HandTrackingProvider)")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(Color.green.opacity(0.5))
                        .font(.system(size: 42, weight: .bold))
                }

                // 手の追従
                ComparisonRow(
                    item: "手の追従",
                    realityKit: "自動(AnchorEntity) ⚡",
                    arKit: "手動(毎フレーム更新)",
                    itemWidth: itemColumnWidth
                )

                // レイテンシ対策
                ComparisonRow(
                    item: "遅延対策",
                    realityKit: ".predicted モード ✨",
                    arKit: "自前で調整",
                    itemWidth: itemColumnWidth
                )

                // 更新ループ
                ComparisonRow(
                    item: "更新ループ",
                    realityKit: "ECS(描画同期)",
                    arKit: "イベントストリーム",
                    itemWidth: itemColumnWidth
                )

                // 適合用途
                ComparisonRow(
                    item: "用途・目的",
                    realityKit: "素早い開発 🚀",
                    arKit: "細かい制御が必要な場合 📊",
                    itemWidth: itemColumnWidth
                )

                // 実装難易度
                ComparisonRow(
                    item: "実装難易度",
                    realityKit: "簡単(高レベルAPIで、自前実装が少ない)",
                    arKit: "複雑(座標変換や自前実装が必要)",
                    itemWidth: itemColumnWidth
                )

                // 手追跡API
                ComparisonRow(
                    item: "手の追跡の実装",
                    realityKit: "visionOS 2.0〜 🆕",
                    arKit: "visionOS 1.0〜",
                    itemWidth: itemColumnWidth
                )
            }
            Text("今回: RealityKitを選択(モダンでシンプルなIF/パフォーマンスも安定)")
                .font(.smallFont)
                .lineLimit(2)
                .foregroundColor(.defaultForegroundColor)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct ComparisonRow: View {
    let item: String
    let realityKit: String
    let arKit: String
    var itemWidth: CGFloat = 220
    private let verticalPadding: CGFloat = 24

    var body: some View {
        HStack(spacing: 0) {
            Text(item)
                .padding(.horizontal, 10)
                .frame(width: itemWidth)
                .padding(.vertical, verticalPadding)
                .font(.system(size: 34, weight: .medium))
                .background(Color.gray.opacity(0.1))

            Text(realityKit)
                .frame(maxWidth: .infinity)
                .padding(.vertical, verticalPadding)
                .padding(.horizontal, 10)
                .font(.system(size: 36, weight: .bold))
                .foregroundStyle(.white)
                .background(Color.blue.opacity(0.3))

            Text(arKit)
                .frame(maxWidth: .infinity)
                .padding(.vertical, verticalPadding)
                .padding(.horizontal, 10)
                .font(.system(size: 36, weight: .bold))
                .foregroundStyle(.white)
                .background(Color.green.opacity(0.3))
        }
    }
}

#Preview {
    SlidePreview {
        FrameworkComparisonSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
