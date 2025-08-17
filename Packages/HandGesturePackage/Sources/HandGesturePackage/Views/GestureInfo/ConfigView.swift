import SwiftUI
import HandGestureKit

/// 設定画面を表示するビュー
public struct ConfigView: View {
    @Environment(\.gestureInfoStore) private var gestureInfoStore

    public init() {}
    
    public var body: some View {
        Form {
            Section("デバッグ設定") {
                Toggle(
                    "手のトラッキングエンティティを表示",
                    isOn: .init(get: {
                        gestureInfoStore.showHandEntities
                    }, set: { value in
                        gestureInfoStore.showHandEntities = value
                    })
                )
                    .toggleStyle(.switch)
                Text("有効にすると、各関節の位置と座標軸が3D空間に表示されます")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Section("手話機能") {
                Toggle(
                    "手話検知を有効にする",
                    isOn: .init(get: {
                        gestureInfoStore.isHandLanguageDetectionEnabled
                    }, set: { value in
                        gestureInfoStore.isHandLanguageDetectionEnabled = value
                    })
                )
                    .toggleStyle(.switch)
                Text("手話ジェスチャーの認識機能を有効にします")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Section("ジェスチャー設定") {
                ForEach(AvailableGestures.allGestureInstances, id: \.id) { gesture in
                    Toggle(
                        gesture.displayName,
                        isOn: .init(get: {
                            gestureInfoStore.enabledGestureIds.contains(gesture.id)
                        }, set: { isEnabled in
                            if isEnabled {
                                gestureInfoStore.enabledGestureIds.insert(gesture.id)
                            } else {
                                gestureInfoStore.enabledGestureIds.remove(gesture.id)
                            }
                        })
                    )
                }
            }
        }
        .navigationTitle("設定")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ConfigView()
    }
}