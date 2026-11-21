#if DEBUG && os(iOS)
import SwiftUI
#Preview("Metal取得・表示・バッファ上限", traits: .fixedLayout(width: 860, height: 370)) {
    PresenterMetalCheck()
}
#Preview("取得方式の選択", traits: .fixedLayout(width: 440, height: 280)) {
    List {
        Section("スライドの出力方式") {
            ForEach(PresenterSlideOutput.allCases) { output in
                Text(output.title)
            }
        }
    }
}
#endif
