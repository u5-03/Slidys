//
//  YugiohDuelMatchSampleEntryView.swift
//  SlidysCore
//
//  SamplePages から「Yugioh Duel 対戦(2人)」を開いたときのエントリ View。
//  - visionOS: 対戦セクション(1台デモ / ホスト / ゲスト)付きのデュエルディスク開始画面。
//              ここで対戦を開始してから ImmersiveSpace に入ると、奥に相手のフィールドが出る。
//  - iOS:      対戦モードの 2D 盤面(DuelBoardView)。iPhone を相手役にして動作確認できる。
//  - それ以外: 利用不可メッセージ。
//

import SwiftUI
#if os(visionOS) || os(iOS)
import YugiohDuelDiskPackage
#endif

struct YugiohDuelMatchSampleEntryView: View {
    var body: some View {
#if os(visionOS)
        StartDuelDiskView()
#elseif os(iOS)
        DuelBoardView()
#else
        VStack(spacing: 12) {
            Image(systemName: "person.2.fill")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("このサンプルは visionOS / iOS でのみ利用可能です")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
#endif
    }
}

#Preview {
    YugiohDuelMatchSampleEntryView()
}
