# モバイルアプリ設計パターン

---

## モバイルアプリ設計パターン入門

よりよいアプリを作るために
知っておきたい設計の考え方

---

## 今日話すこと

- MVVMパターン
  - ViewModelの役割
  - データバインディング
- Repositoryパターン

---

## MVVMの基本構造

```swift
@Observable
class UserListViewModel {
    private let repository: UserRepository
    var users: [User] = []

    func loadUsers() async {
        users = await repository.fetchAll()
    }
}
```

---

## まとめ

設計パターンを適切に使うことで
保守性と拡張性の高いアプリを実現できます
