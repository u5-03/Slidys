import Foundation
import SlidysShareCore

#if DEBUG
enum PreviewSampleData {
    static let samplePages: [SlidePageData] = [
        SlidePageData(type: .centerText(text: "Welcome to Slidys Share")),
        SlidePageData(type: .titleList(title: "Agenda", items: [
            ListItem(text: "Introduction"),
            ListItem(text: "Features", isIndented: true),
            ListItem(text: "Demo"),
        ])),
        SlidePageData(type: .code(title: "Sample Code", code: "let greeting = \"Hello, World!\"\nprint(greeting)")),
    ]

    static let sampleDeck = SlideDeck(
        title: "Sample Presentation",
        pages: samplePages
    )

    static let sampleReactions: [ReceivedReaction] = [
        ReceivedReaction(id: UUID(), type: .thumbsUp, timestamp: Date()),
        ReceivedReaction(id: UUID(), type: .heart, timestamp: Date()),
        ReceivedReaction(id: UUID(), type: .fire, timestamp: Date()),
    ]

    @MainActor
    static let sampleStorage = SlideStorage()

    @MainActor
    static let sampleConnection = MultipeerManager()
}
#endif
