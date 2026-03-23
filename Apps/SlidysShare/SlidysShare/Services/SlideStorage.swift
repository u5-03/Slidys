import Foundation
import SlidysShareCore

@Observable
final class SlideStorage {
    private(set) var decks: [SlideDeck] = []

    private var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("SlidysShare", isDirectory: true)
    }

    init() {
        ensureDirectoryExists()
        decks = loadAll()
    }

    private func ensureDirectoryExists() {
        try? FileManager.default.createDirectory(at: documentsDirectory, withIntermediateDirectories: true)
    }

    func save(deck: SlideDeck) {
        var updatedDeck = deck
        updatedDeck.updatedAt = Date()
        let url = documentsDirectory.appendingPathComponent("\(deck.id.uuidString).json")
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let data = try? encoder.encode(updatedDeck) {
            try? data.write(to: url)
        }
        if let index = decks.firstIndex(where: { $0.id == deck.id }) {
            decks[index] = updatedDeck
        } else {
            decks.append(updatedDeck)
        }
    }

    func loadAll() -> [SlideDeck] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let files = try? FileManager.default.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil) else {
            return []
        }
        return files
            .filter { $0.pathExtension == "json" }
            .compactMap { url in
                guard let data = try? Data(contentsOf: url) else { return nil }
                return try? decoder.decode(SlideDeck.self, from: data)
            }
            .sorted { $0.updatedAt > $1.updatedAt }
    }

    func delete(id: UUID) {
        let url = documentsDirectory.appendingPathComponent("\(id.uuidString).json")
        try? FileManager.default.removeItem(at: url)
        decks.removeAll { $0.id == id }
    }
}
