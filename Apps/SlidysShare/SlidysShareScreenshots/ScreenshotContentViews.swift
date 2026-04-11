import SwiftUI
import SlidysShareCore
import AppStoreScreenshotTestCore

@MainActor
@ViewBuilder
func screenshotScene(for state: String) -> some View {
    switch state {
    case "createSlide":
        NavigationStack {
            SlideEditView(
                deck: ScreenshotSampleData.editingDeck,
                storage: SlideStorage(inMemoryDecks: []),
                isNew: false
            )
        }
        .contentMargins(.horizontal, 4, for: .scrollContent)
        .padding(.horizontal, 6)
    case "presentAnywhere":
        SlideBroadcastView(
            deck: ScreenshotSampleData.sampleDeck,
            connection: FakeSlideConnection()
        )
    case "liveReactions":
        liveReactionsScene()
    case "markdownImport":
        NavigationStack {
            SlideListView(
                storage: SlideStorage(inMemoryDecks: ScreenshotSampleData.markdownImportedDecks),
                connection: FakeSlideConnection()
            )
        }
        .contentMargins(.horizontal, 4, for: .scrollContent)
        .padding(.horizontal, 6)
    default:
        EmptyView()
    }
}

@MainActor
private func liveReactionsScene() -> some View {
    let fake = FakeSlideConnection()
    fake.receivedReactions = ScreenshotSampleData.floatingReactions
    let deck = ScreenshotSampleData.sampleDeck
    return SlideReceiverView(
        connection: fake,
        initialIsReceiving: true,
        initialPages: deck.pages,
        initialStyle: deck.style,
        initialIndex: 1
    )
}

// MARK: - Previews

#if DEBUG && canImport(UIKit)
#Preview("iOS - CreateSlide") {
    AppStorePreviewView(
        config: AppStoreScreenshotConfig(
            headline: "Simple Slide Creation",
            subheadline: "Just a title and text — done",
            backgroundColor: Color.blue.gradient,
            targetPlatform: .iOS,
            statusBarBackgroundColor: Color(.systemGroupedBackground)
        )
    ) {
        screenshotScene(for: "createSlide")
    }
    .statusBarHidden()
}

#Preview("iOS - PresentAnywhere") {
    AppStorePreviewView(
        config: AppStoreScreenshotConfig(
            headline: "Share Between Your Devices",
            subheadline: "No cables, no external screen",
            backgroundColor: Color.purple.gradient,
            targetPlatform: .iOS,
            statusBarBackgroundColor: .black
        )
    ) {
        screenshotScene(for: "presentAnywhere")
    }
    .statusBarHidden()
}

#Preview("iOS - LiveReactions") {
    AppStorePreviewView(
        config: AppStoreScreenshotConfig(
            headline: "Live Reactions",
            subheadline: "Cheer with reactions in real-time",
            backgroundColor: Color.pink.gradient,
            targetPlatform: .iOS,
            statusBarBackgroundColor: .black
        )
    ) {
        screenshotScene(for: "liveReactions")
    }
    .statusBarHidden()
}

#Preview("iOS - MarkdownImport") {
    AppStorePreviewView(
        config: AppStoreScreenshotConfig(
            headline: "From Markdown to Slides",
            subheadline: "Your Markdown, beautifully presented",
            backgroundColor: Color.teal.gradient,
            targetPlatform: .iOS,
            statusBarBackgroundColor: Color(.systemGroupedBackground)
        )
    ) {
        screenshotScene(for: "markdownImport")
    }
    .statusBarHidden()
}
#endif
