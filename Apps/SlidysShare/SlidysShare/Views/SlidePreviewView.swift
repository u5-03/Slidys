import SwiftUI
import SlideKit
import SlidysShareCore

struct SlidePreviewView: View {
    let deck: SlideDeck
    @Environment(\.dismiss) private var dismiss
    @State private var currentIndex = 0

    var body: some View {
        NavigationStack {
            ZStack {
                if !deck.pages.isEmpty, deck.pages.indices.contains(currentIndex) {
                    PresentationView(slideSize: SlideSize.standard16_9) {
                        DynamicSlideContentView(pageData: deck.pages[currentIndex], style: deck.style)
                    }

                    HStack {
                        Color.clear
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if currentIndex > 0 { currentIndex -= 1 }
                            }
                        Color.clear
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if currentIndex < deck.pages.count - 1 { currentIndex += 1 }
                            }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") { dismiss() }
                }
                ToolbarItem(placement: .principal) {
                    Text("\(currentIndex + 1) / \(deck.pages.count)")
                }
            }
        }
    }
}

#if DEBUG
#Preview {
    SlidePreviewView(deck: PreviewSampleData.sampleDeck)
}
#endif
