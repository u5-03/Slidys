import SwiftUI

/// 手話関連の画面を表示するビュー
public struct SignLanguageView: View {
    @Environment(\.gestureInfoStore) private var gestureStore
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 20) {
            // 手話検知が無効な場合の表示
            if !gestureStore.isHandLanguageDetectionEnabled {
                VStack(spacing: 20) {
                    Image(systemName: "hand.raised.slash")
                        .font(.system(size: 64))
                        .foregroundColor(.secondary)
                    
                    Text("手話検知が無効です")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    Text("設定から手話検知を有効にしてください")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // 手話検知が有効な場合の表示
                VStack(spacing: 16) {
                    // 検出した手話テキスト表示エリア
                    GroupBox {
                        ScrollView {
                            if gestureStore.detectedSignLanguageText.isEmpty {
                                Text("手話を検出していません")
                                    .foregroundColor(.secondary)
                                    .font(.body)
                                    .frame(maxWidth: .infinity, minHeight: 100)
                            } else {
                                Text(gestureStore.detectedSignLanguageText)
                                    .font(.title)
                                    .fontWeight(.medium)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                            }
                        }
                        .frame(maxHeight: 300)
                    } label: {
                        Label("検出したテキスト", systemImage: "text.quote")
                            .font(.headline)
                    }
                    
                    // 操作ボタン
                    HStack(spacing: 20) {
                        // 1文字削除ボタン
                        Button(action: {
                            deleteLastCharacter()
                        }) {
                            Label("削除", systemImage: "delete.left")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.large)
                        .disabled(gestureStore.detectedSignLanguageText.isEmpty)
                        
                        // クリアボタン
                        Button(action: {
                            gestureStore.clearSignLanguageText()
                        }) {
                            Label("クリア", systemImage: "xmark.circle.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .disabled(gestureStore.detectedSignLanguageText.isEmpty)
                    }
                    .padding(.horizontal)
                    
                    // 説明テキスト
                    VStack(spacing: 8) {
                        Label("使い方", systemImage: "info.circle")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("• 手話ジェスチャーが認識されると自動的に文字が入力されます")
                        Text("• 現在対応: B, G, I, L, O, W")
                        Text("• 次の文字は1秒後に入力可能になります")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding()
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(10)
                    
                    Spacer()
                }
                .padding()
            }
        }
        .navigationTitle("手話")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Private Methods
    
    /// 最後の1文字を削除
    private func deleteLastCharacter() {
        guard !gestureStore.detectedSignLanguageText.isEmpty else { return }
        gestureStore.detectedSignLanguageText.removeLast()
    }
}

#Preview {
    NavigationStack {
        SignLanguageView()
            .environment(\.gestureInfoStore, GestureInfoStore())
    }
}