import SwiftUI
import SlideKit
import SlidesCore
import SlidysShareCore

struct SlideReceiverView: View {
    let connection: MultipeerManager
    @Environment(\.dismiss) private var dismiss
    @State private var showBrowser = false
    @State private var isReceiving = false
    @State private var store: DynamicSlideStore?
    @State private var currentIndex = 0
    @State private var pageCount = 0

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
                        DynamicSlideContentView(pageData: currentIndex < store.pages.count ? store.pages[currentIndex] : nil)
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
        .navigationTitle("スライド受信")
        .sheet(isPresented: $showBrowser) {
            browserContent
        }
        .onChange(of: connection.receivedEvent) { _, event in
            guard let event else { return }
            handleEvent(event)
        }
    }

    private func handleEvent(_ event: SlideEvent) {
        switch event {
        case .openSlide(let count):
            pageCount = count
            store = DynamicSlideStore(pageCount: count)
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
        }
    }
}
