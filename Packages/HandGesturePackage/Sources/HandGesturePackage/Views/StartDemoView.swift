//
//  WelcomeView.swift
//  HandGesturePackage
//
//  Created by yugo.sugiyama on 2025/06/05.
//

import SwiftUI
import HandGestureKit

/// 初回起動時に表示されるウェルカムビュー
public struct StartDemoView: View {


    public init() {}

    public var body: some View {
        VStack(spacing: 30) {
            // アプリタイトル
            VStack(spacing: 16) {
                Image(systemName: "hand.wave.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.blue.gradient)
                    .symbolRenderingMode(.hierarchical)
                
                Text("Hand Gesture Detection")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                
                Text("visionOS Hand Tracking Experience")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 20)
            
            // 説明文
            VStack(alignment: .leading, spacing: 20) {
                Text("このアプリで体験できること")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(alignment: .leading, spacing: 12) {
                    FeatureRow(icon: "hand.point.up.left.fill", text: "リアルタイム手のトラッキング")
                    FeatureRow(icon: "hand.thumbsup.fill", text: "片手ジェスチャー認識")
                    FeatureRow(icon: "hands.clap.fill", text: "両手ジェスチャー認識")
                    FeatureRow(icon: "hand.raised.fingers.spread.fill", text: "手話ジェスチャー認識 (B, G, I, L, O, W)")
                }
            }
            .padding(24)
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.regularMaterial)
                    .stroke(.separator, lineWidth: 1)
            }
            StartDemoButton()
            Spacer(minLength: 20)
        }
        .padding(40)
        .frame(width: 600)
        .preferredColorScheme(.dark)
    }
}

/// 機能説明行
private struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.blue.gradient)
                .frame(width: 30, height: 30)
                .background(.blue.opacity(0.1))
                .clipShape(Circle())
            
            Text(text)
                .font(.body)
                .foregroundStyle(.primary)
            
            Spacer()
        }
    }
}

#Preview {
    StartDemoView()
        .environment(\.appModel, AppModel())
} 
