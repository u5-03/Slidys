# SwiftUIで始めるアプリ開発

---

## SwiftUIで始めるアプリ開発入門

---

## 今日のアジェンダ

- SwiftUIの基本概念
- 宣言的UIの特徴
  - データ駆動の設計
  - プレビュー機能の活用
- 実践的なサンプルコード

---

## SwiftUIのメリット

- コードが簡潔で読みやすい
  - 少ないコード量でUIを構築
- クロスプラットフォーム対応
  - iOS, macOS, visionOS
- リアルタイムプレビュー

---

## Hello Worldの例

```swift
struct ContentView: View {
    var body: some View {
        VStack {
            Text("Hello, World!")
            Image(systemName: "swift")
        }
    }
}
```

---

## まとめ

SwiftUIを使えば、少ないコードで
美しいUIを実現できます。
