//
//  YugiohDuelDiskSampleEntryView.swift
//  SlidysCore
//
//  SamplePages から「Yugioh Duel Disk」を開いたときのエントリ View。
//  visionOS 以外では利用不可メッセージを表示する。
//

import SwiftUI
#if os(visionOS)
import YugiohDuelDiskPackage
#endif

struct YugiohDuelDiskSampleEntryView: View {
    var body: some View {
#if os(visionOS)
        StartDuelDiskView()
#else
        VStack(spacing: 12) {
            Image(systemName: "visionpro")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("このサンプルは visionOS でのみ利用可能です")
                .foregroundStyle(.secondary)
        }
        .padding(40)
#endif
    }
}

#Preview {
    YugiohDuelDiskSampleEntryView()
}
