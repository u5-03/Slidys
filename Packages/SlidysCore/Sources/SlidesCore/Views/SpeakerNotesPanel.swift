//
//  SpeakerNotesPanel.swift
//  SlidesCore
//
//  スライドと同一画面に並べて表示する簡易スピーカーノートパネル(主にiPadの原稿確認用)。
//  macOSの別Window(SpeakerNotesWindow)と同じく、各スライドの script プロパティを表示する。
//

import SlideKit
import SwiftUI

public struct SpeakerNotesPanel: View {
    @ObservedObject var slideIndexController: SlideIndexController

    public init(slideIndexController: SlideIndexController) {
        self.slideIndexController = slideIndexController
    }

    private var currentIndex: Int { slideIndexController.currentIndex }

    private var currentNote: String {
        // 連続する改行(空行)は表示上1つにまとめる
        let script = slideIndexController.currentSlide.script
            .replacingOccurrences(of: "\n{2,}", with: "\n", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return script.isEmpty ? "(このスライドのノートはありません)" : script
    }

    private var nextNoteHeadline: String? {
        let next = currentIndex + 1
        guard slideIndexController.slides.indices.contains(next) else { return nil }
        return slideIndexController.slides[next].script
            .split(separator: "\n", omittingEmptySubsequences: true)
            .first
            .map(String.init)
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Text("\(currentIndex + 1) / \(slideIndexController.slides.count)")
                    .font(.system(size: 22, weight: .heavy, design: .monospaced))
                Text(String(describing: type(of: slideIndexController.currentSlide)))
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                Spacer()
            }

            ScrollView {
                Text(currentNote)
                    .font(.system(size: 21, weight: .medium))
                    .lineSpacing(7)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)
            }
            .id(currentIndex) // ページが変わったらスクロール位置を先頭へ戻す

            if let nextNoteHeadline {
                Divider()
                Text("次: \(nextNoteHeadline)")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.black.opacity(0.92))
        .foregroundStyle(.white)
        .colorScheme(.dark)
        // ページ送り時のクロスフェードを無効化(controller側のwithAnimationを打ち消す)
        .transaction { transaction in
            transaction.animation = nil
            transaction.disablesAnimations = true
        }
    }
}
