import SwiftUI
import SlideKit
import SlidysShareCore

struct SlideDetailView: View {
    let deck: SlideDeck
    @Bindable var storage: SlideStorage
    let connection: any SlideConnectionProtocol
    @State private var showBrowser = false
    @State private var showBroadcast = false
    @State private var showNameInput = false
    @State private var hostName = String(localized: "スライド送信者")

    @ViewBuilder
    private var waitingForConnectionView: some View {
        VStack(spacing: 20) {
            Text("接続を待機中...")
                .font(.headline)
            ProgressView()
            Text("受信側のデバイスから接続してください")
                .foregroundStyle(.secondary)
            Button("キャンセル") {
                showBrowser = false
                connection.disconnect()
            }
        }
        .padding(40)
    }

    var body: some View {
        List {
            Section("スライド情報") {
                LabeledContent("タイトル", value: deck.title)
                LabeledContent("ページ数", value: "\(deck.pages.count)")
                LabeledContent("作成日", value: deck.createdAt.formatted(.dateTime.year().month().day().hour().minute()))
                LabeledContent("更新日", value: deck.updatedAt.formatted(.dateTime.year().month().day().hour().minute()))
            }

            Section("ページ一覧") {
                ForEach(Array(deck.pages.enumerated()), id: \.element.id) { index, page in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("\(index + 1)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(page.displayTitle)
                        }
                        PresentationView(slideSize: SlideSize.standard16_9) {
                            DynamicSlideContentView(pageData: page, style: deck.style)
                        }
                        .aspectRatio(16/9, contentMode: .fit)
                        .frame(height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        .allowsHitTesting(false)
                    }
                }
            }
        }
        .navigationTitle(deck.title)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                HStack {
                    Menu {
                        ShareLink(item: deck, preview: SharePreview(deck.title)) {
                            Label("スライドファイルとして共有", systemImage: "doc")
                        }
                        ShareLink(item: deck.toMarkdown(), preview: SharePreview("\(deck.title).md")) {
                            Label("マークダウンとして書き出し", systemImage: "doc.plaintext")
                        }
                    } label: {
                        Image(systemName: "square.and.arrow.up.fill")
                    }
                    NavigationLink(destination: SlideEditView(deck: deck, storage: storage, isNew: false)) {
                        Image(systemName: "pencil")
                    }
                    Button {
                        showNameInput = true
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
        .alert("配信者名", isPresented: $showNameInput) {
            TextField("名前", text: $hostName)
            Button("配信開始") {
                connection.startHosting(displayName: hostName)
                showBrowser = true
            }
            Button("キャンセル", role: .cancel) {}
        } message: {
            Text("受信側に表示される名前を入力してください")
        }
        .sheet(isPresented: $showBrowser) {
            waitingForConnectionView
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

#if DEBUG
#Preview {
    NavigationStack {
        SlideDetailView(deck: PreviewSampleData.sampleDeck, storage: PreviewSampleData.sampleStorage, connection: PreviewSampleData.sampleConnection)
    }
}
#endif
