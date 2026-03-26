import SwiftUI
import SlideKit
import SlidysShareCore

struct SlideBroadcastView: View {
    let deck: SlideDeck
    let connection: MultipeerManager
    @Environment(\.dismiss) private var dismiss
    @State private var currentIndex = 0
    @State private var showCloseConfirmation = false

    var body: some View {
        ZStack {
            if !deck.pages.isEmpty, deck.pages.indices.contains(currentIndex) {
                PresentationView(slideSize: SlideSize.standard16_9) {
                    DynamicSlideContentView(pageData: deck.pages[currentIndex])
                }

                HStack {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            guard currentIndex > 0 else { return }
                            currentIndex -= 1
                            sendCurrentPage()
                        }
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            guard currentIndex < deck.pages.count - 1 else { return }
                            currentIndex += 1
                            sendCurrentPage()
                        }
                }
            }

            VStack {
                HStack {
                    Spacer()
                    Text("\(currentIndex + 1) / \(deck.pages.count)")
                        .font(.callout.monospacedDigit())
                        .foregroundStyle(.white.opacity(0.7))
                        .shadow(radius: 4)
                    Button {
                        showCloseConfirmation = true
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundStyle(.white.opacity(0.7))
                            .shadow(radius: 4)
                    }
                    .padding()
                }
                Spacer()
            }
        }
        .confirmationDialog("配信を停止しますか？", isPresented: $showCloseConfirmation) {
            Button("停止する", role: .destructive) {
                try? connection.send(event: .closeSlide)
                connection.disconnect()
                dismiss()
            }
            Button("キャンセル", role: .cancel) {}
        }
        .onAppear {
            guard !deck.pages.isEmpty else { return }
            try? connection.send(event: .openSlide(pageCount: deck.pages.count))
            sendCurrentPage()
        }
    }

    private func sendCurrentPage() {
        guard currentIndex < deck.pages.count else { return }
        try? connection.send(event: .showPage(index: currentIndex, page: deck.pages[currentIndex]))
    }
}
