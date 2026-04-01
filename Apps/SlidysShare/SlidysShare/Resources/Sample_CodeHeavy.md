# コードサンプル集

---

## SwiftでのAPI呼び出し

```swift
func fetchUsers() async throws -> [User] {
    let url = URL(string: "https://api.example.com/users")!
    let (data, _) = try await URLSession.shared.data(from: url)
    return try JSONDecoder().decode([User].self, from: data)
}
```

---

## Pythonでのデータ処理

```python
import pandas as pd

def analyze_sales(filepath):
    df = pd.read_csv(filepath)
    return {"total": df["amount"].sum()}
```

---

## SQLクエリ

```
SELECT u.name, COUNT(o.id) as order_count
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
GROUP BY u.name
ORDER BY order_count DESC;
```
