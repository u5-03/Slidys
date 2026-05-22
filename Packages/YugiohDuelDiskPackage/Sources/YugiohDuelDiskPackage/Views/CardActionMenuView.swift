//
//  CardActionMenuView.swift
//  YugiohDuelDiskPackage
//
//  配置済みカードをタップしたときに表示する SwiftUI のメニュー。
//  ImmersiveView の RealityView の attachment として埋め込む。
//

import SwiftUI

struct CardActionMenuView: View {
    let context: PlacedCardContext
    let onDelete: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Text("カードを操作")
                .font(.headline)
            Text(contextDescription)
                .font(.caption)
                .foregroundStyle(.secondary)
            Button(role: .destructive, action: onDelete) {
                Label("削除", systemImage: "trash")
            }
            Button("キャンセル", action: onCancel)
        }
        .padding()
        .frame(width: 220)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private var contextDescription: String {
        switch context {
        case .diskSlot(let i): return "ディスク・スロット \(i + 1)"
        case .arenaBack(let c): return "召喚エリア(奥) 列 \(c + 1)"
        case .arenaFront(let c): return "召喚エリア(前) 列 \(c + 1)"
        }
    }
}
