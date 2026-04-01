# Introduction to Swift Concurrency

---

## Introduction to Swift Concurrency

Modern asynchronous programming
for iOS developers

---

## What We Will Cover

- async/await basics
  - How it replaces completion handlers
  - Error handling with throws
- Structured concurrency
  - Task groups

---

## async/await Example

```swift
func fetchUser(id: Int) async throws -> User {
    let url = URL(string: "https://api.example.com/users/\(id)")!
    let (data, _) = try await URLSession.shared.data(from: url)
    return try JSONDecoder().decode(User.self, from: data)
}
```

---

## Thank You!

Questions?
