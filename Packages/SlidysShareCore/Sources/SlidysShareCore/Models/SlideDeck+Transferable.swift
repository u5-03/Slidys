import SwiftUI
import UniformTypeIdentifiers

extension SlideDeck: Transferable {
    public static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(exportedContentType: .slidysShare) { deck in
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(deck)
            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent("\(deck.title).slidysshare")
            try data.write(to: url)
            return SentTransferredFile(url)
        }
    }
}
