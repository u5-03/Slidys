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

    init(inMemoryDecks: [SlideDeck]) {
        self.decks = inMemoryDecks
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

    @discardableResult
    func importDeck(from url: URL) -> Bool {
        let accessing = url.startAccessingSecurityScopedResource()
        defer { if accessing { url.stopAccessingSecurityScopedResource() } }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let data = try? Data(contentsOf: url),
              let importedDeck = try? decoder.decode(SlideDeck.self, from: data) else { return false }
        let newDeck = SlideDeck(
            title: importedDeck.title,
            pages: importedDeck.pages,
            style: importedDeck.style
        )
        save(deck: newDeck)
        return true
    }

    #if canImport(FoundationModels)
    func importMarkdownDeck(from url: URL) async throws {
        let accessing = url.startAccessingSecurityScopedResource()
        defer { if accessing { url.stopAccessingSecurityScopedResource() } }
        let markdownString = try String(contentsOf: url, encoding: .utf8)
        let fileName = url.deletingPathExtension().lastPathComponent
        let parser = MarkdownSlideParser()
        let deck = try await parser.parse(markdown: markdownString, deckTitle: fileName)
        save(deck: deck)
    }
    #endif

    func delete(id: UUID) {
        let url = documentsDirectory.appendingPathComponent("\(id.uuidString).json")
        try? FileManager.default.removeItem(at: url)
        decks.removeAll { $0.id == id }
    }
}
