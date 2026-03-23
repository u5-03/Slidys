import SwiftUI
import MultipeerConnectivity
import SlidysShareCore

struct SlideDetailView: View {
    let deck: SlideDeck
    @Bindable var storage: SlideStorage
    let connection: MultipeerManager
    @State private var showBrowser = false
    @State private var showBroadcast = false

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
        List {
            Section("スライド情報") {
                LabeledContent("タイトル", value: deck.title)
                LabeledContent("ページ数", value: "\(deck.pages.count)")
                LabeledContent("作成日", value: deck.createdAt.formatted(date: .abbreviated, time: .shortened))
                LabeledContent("更新日", value: deck.updatedAt.formatted(date: .abbreviated, time: .shortened))
            }

            Section("ページ一覧") {
                ForEach(Array(deck.pages.enumerated()), id: \.element.id) { index, page in
                    HStack {
                        Text("\(index + 1)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(page.displayTitle)
                    }
                }
            }
        }
        .navigationTitle(deck.title)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                HStack {
                    NavigationLink(destination: SlideEditView(deck: deck, storage: storage, isNew: false)) {
                        Image(systemName: "pencil")
                    }
                    Button {
                        connection.startHosting()
                        showBrowser = true
                    } label: {
                        Image(systemName: "antenna.radiowaves.left.and.right")
                    }
                    .disabled(deck.pages.isEmpty)
                }
            }
        }
        .onChange(of: connection.connectionState) { _, newState in
            if newState == .connected {
                showBrowser = false
                showBroadcast = true
            }
        }
        .sheet(isPresented: $showBrowser) {
            browserContent
        }
        #if os(macOS)
        .sheet(isPresented: $showBroadcast) {
            SlideBroadcastView(deck: deck, connection: connection)
        }
        #else
        .fullScreenCover(isPresented: $showBroadcast) {
            SlideBroadcastView(deck: deck, connection: connection)
        }
        #endif
    }
}
