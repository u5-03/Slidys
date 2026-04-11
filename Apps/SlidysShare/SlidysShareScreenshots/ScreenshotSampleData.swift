import Foundation
import SlidysShareCore

enum ScreenshotSampleData {
    static let samplePages: [SlidePageData] = [
        SlidePageData(type: .centerText(text: "Slidys Share")),
        SlidePageData(type: .titleList(title: "Agenda", items: [
            ListItem(text: "Introduction"),
            ListItem(text: "Key Features", isIndented: true),
            ListItem(text: "Live Demo"),
            ListItem(text: "Q & A", isIndented: true)
        ])),
        SlidePageData(type: .code(title: "Sample Code", code: """
let greeting = "Hello, World!"
print(greeting)

struct Slide {
    let title: String
    let pages: [Page]
}
""")),
        SlidePageData(type: .centerText(text: "Thank You!"))
    ]

    static let sampleDeck = SlideDeck(
        title: "Sample Presentation",
        pages: samplePages
    )

    static let editingDeck = SlideDeck(
        title: "My New Slide",
        pages: [
            SlidePageData(type: .centerText(text: "Welcome")),
            SlidePageData(type: .titleList(title: "Topics", items: [
                ListItem(text: "Idea"),
                ListItem(text: "Design", isIndented: true),
                ListItem(text: "Build")
            ])),
            SlidePageData(type: .code(title: "Snippet", code: "print(\"Hi\")"))
        ]
    )

    static var floatingReactions: [ReceivedReaction] {
        let now = Date()
        return [
            ReceivedReaction(type: .clap, timestamp: now.addingTimeInterval(-0.2)),
            ReceivedReaction(type: .heart, timestamp: now.addingTimeInterval(-0.5)),
            ReceivedReaction(type: .fire, timestamp: now.addingTimeInterval(-0.8)),
            ReceivedReaction(type: .thumbsUp, timestamp: now.addingTimeInterval(-1.1)),
            ReceivedReaction(type: .rocket, timestamp: now.addingTimeInterval(-1.4)),
            ReceivedReaction(type: .heart, timestamp: now.addingTimeInterval(-1.7)),
            ReceivedReaction(type: .clap, timestamp: now.addingTimeInterval(-2.0))
        ]
    }

    static let markdownImportedDecks: [SlideDeck] = [
        SlideDeck(
            title: "Introduction to Swift",
            pages: [
                SlidePageData(type: .centerText(text: "Introduction to Swift")),
                SlidePageData(type: .titleList(title: "What is Swift?", items: [
                    ListItem(text: "Modern language"),
                    ListItem(text: "Type-safe"),
                    ListItem(text: "Fast")
                ]))
            ]
        ),
        SlideDeck(
            title: "iOS Development Tips",
            pages: [
                SlidePageData(type: .centerText(text: "iOS Tips")),
                SlidePageData(type: .titleList(title: "Best Practices", items: [
                    ListItem(text: "SwiftUI First"),
                    ListItem(text: "Observation"),
                    ListItem(text: "Concurrency")
                ]))
            ]
        ),
        SlideDeck(
            title: "Design Systems",
            pages: [
                SlidePageData(type: .centerText(text: "Design Systems"))
            ]
        ),
        SlideDeck(
            title: "Team Meeting Notes",
            pages: [
                SlidePageData(type: .centerText(text: "Weekly Sync")),
                SlidePageData(type: .titleList(title: "Topics", items: [
                    ListItem(text: "Progress"),
                    ListItem(text: "Blockers"),
                    ListItem(text: "Next Steps")
                ]))
            ]
        )
    ]
}
