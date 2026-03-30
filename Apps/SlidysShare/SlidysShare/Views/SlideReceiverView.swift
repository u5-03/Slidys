import SwiftUI
import SlideKit
import SlidysShareCore

struct SlideReceiverView: View {
    let connection: MultipeerManager
    @Environment(\.dismiss) private var dismiss
    @State private var showBrowser = false
    @State private var isReceiving = false
    @State private var showCloseConfirmation = false
    @State private var showDisconnectedAlert = false
    @State private var store: DynamicSlideStore?
    @State private var currentIndex = 0
    @State private var slideStyle: SlideStyle = .default

    @ViewBuilder
    private var browserContent: some View {
        #if os(iOS) || os(visionOS)
        if let browser = connection.makeBrowserViewController() {
            MultipeerBrowserView(browser: browser, onFinished: {
                showBrowser = false
            }, onCancelled: {
                showBrowser = false
                connection.disconnect()
            })
        }
        #elseif os(macOS)
        MultipeerBrowserView(manager: connection, onFinished: {
            showBrowser = false
        }, onCancelled: {
            showBrowser = false
            connection.disconnect()
        })
        #endif
    }

    var body: some View {
        Group {
            if isReceiving, let store {
                ZStack {
                    PresentationView(slideSize: SlideSize.standard16_9) {
                        DynamicSlideContentView(pageData: currentIndex < store.pages.count ? store.pages[currentIndex] : nil, style: slideStyle)
                    }

                    ReactionOverlayView(reactions: connection.receivedReactions) { id in
                        connection.removeReaction(id: id)
                    }

                    VStack {
                        HStack {
                            Spacer()
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
                        ReactionPickerView { type in
                            try? connection.send(event: .reaction(type))
                            connection.addLocalReaction(type)
                        }
                        .padding(.bottom, 16)
                    }
                }
            } else {
                VStack(spacing: 20) {
                    if connection.connectionState == .connected {
                        Text("接続済み - スライド待機中...")
                            .font(.headline)
                        ProgressView()
                    } else {
                        Text("ホストに接続してください")
                            .font(.headline)
                        Button("接続する") {
                            connection.startBrowsing()
                            showBrowser = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
        }
        .confirmationDialog("受信を終了しますか？", isPresented: $showCloseConfirmation) {
            Button("終了する", role: .destructive) {
                isReceiving = false
                store = nil
                connection.disconnect()
                dismiss()
            }
            Button("キャンセル", role: .cancel) {}
        }
        .sheet(isPresented: $showBrowser) {
            browserContent
        }
        .onChange(of: connection.receivedEvent) { _, event in
            guard let event else { return }
            handleEvent(event)
        }
        .onChange(of: connection.connectionState) { _, newState in
            if newState == .disconnected && isReceiving {
                isReceiving = false
                store = nil
                showDisconnectedAlert = true
            }
        }
        .alert("接続が切断されました", isPresented: $showDisconnectedAlert) {
            Button("OK") {}
        }
    }

    private func handleEvent(_ event: SlideEvent) {
        switch event {
        case .openSlide(let count, let style):
            store = DynamicSlideStore(pageCount: count)
            slideStyle = style
            currentIndex = 0
            isReceiving = true
        case .showPage(let index, let page):
            store?.update(page: page, at: index)
            currentIndex = index
        case .closeSlide:
            isReceiving = false
            store = nil
            connection.disconnect()
            dismiss()
        case .reaction:
            // Reactions are handled directly in MultipeerManager
            break
        }
        connection.clearReceivedEvent()
    }
}

#if DEBUG
#Preview {
    SlideReceiverView(connection: PreviewSampleData.sampleConnection)
}
#endif
