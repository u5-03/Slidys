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
    /// 裏向きの魔法・トラップなど「オープン」できるカードのときだけ true。
    var canOpen: Bool = false
    var onOpen: () -> Void = {}
    let onDelete: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Text("カードを操作")
                .font(.headline)
            Text(contextDescription)
                .font(.caption)
                .foregroundStyle(.secondary)
            if canOpen {
                Button(action: onOpen) {
                    Label("オープン", systemImage: "eye")
                }
            }
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
        case .diskSlot(let i): return "ディスク・召喚スロット \(i + 1)"
        case .spellSlot(let i): return "ディスク・魔法/罠スロット \(i + 1)"
        case .fieldBack(let c): return "フィールド(奥) 列 \(c + 1)"
        case .fieldFront(let c): return "フィールド(前) 列 \(c + 1)"
        }
    }
}
