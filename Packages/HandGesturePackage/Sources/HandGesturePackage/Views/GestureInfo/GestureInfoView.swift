import SwiftUI
import HandGestureKit

/// メニュー項目を定義
enum MenuItem: String, CaseIterable, Identifiable {
    case config = "設定"
    case gestures = "ジェスチャー"
    case handLanguage = "手話"
    
    var id: String { rawValue }
    
    var systemImage: String {
        switch self {
        case .config:
            return "gearshape.2"
        case .gestures:
            return "hand.raised.fill"
        case .handLanguage:
            return "hands.sparkles"
        }
    }
}

/// ジェスチャー検出結果を表示するウィンドウ
public struct GestureInfoView: View {
    @State private var selectedMenuItem: MenuItem? = .gestures
    
    public init() {}
    
    public var body: some View {
        NavigationSplitView {
            // サイドバー
            List(MenuItem.allCases, selection: $selectedMenuItem) { item in
                Label(item.rawValue, systemImage: item.systemImage)
                    .tag(item)
            }
            .navigationTitle("メニュー")
        } detail: {
            // 詳細ビュー
            NavigationStack {
                if let selectedMenuItem = selectedMenuItem {
                    switch selectedMenuItem {
                    case .config:
                        ConfigView()
                    case .gestures:
                        GesturesView()
                    case .handLanguage:
                        SignLanguageView()
                    }
                } else {
                    Text("メニューを選択してください")
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(minWidth: 700, idealWidth: 800, minHeight: 400, idealHeight: 600)
    }
}

#Preview {
    GestureInfoView()
        .environment(\.gestureInfoStore, GestureInfoStore())
}
