import SwiftUI
import UniformTypeIdentifiers
import SlidysShareCore

struct SlideListView: View {
    @Bindable var storage: SlideStorage
    let connection: any SlideConnectionProtocol
    @State private var showFileImporter = false
    #if canImport(FoundationModels)
    @State private var showMarkdownImporter = false
    @State private var isImporting = false
    @State private var importTask: Task<Void, Never>?
    #endif
    @State private var importError: String?
    @State private var showImportError = false

    var body: some View {
        List {
            ForEach(storage.decks) { deck in
                NavigationLink(destination: SlideDetailView(deck: deck, storage: storage, connection: connection)) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(deck.title)
                            .font(.headline)
                        Text("\(deck.pages.count)ページ")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .onDelete { indexSet in
                for index in indexSet {
                    storage.delete(id: storage.decks[index].id)
                }
            }
        }
        .navigationTitle("スライド一覧")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                HStack {
                    Menu {
                        Button {
                            showFileImporter = true
                        } label: {
                            Label("スライドファイルを読み込む", systemImage: "doc")
                        }
                        #if canImport(FoundationModels)
                        Button {
                            showMarkdownImporter = true
                        } label: {
                            Label("マークダウンファイルを読み込む", systemImage: "doc.plaintext")
                        }
                        #endif
                    } label: {
                        Image(systemName: "square.and.arrow.down.fill")
                    }
                    NavigationLink(destination: SlideEditView(deck: SlideDeck(title: String(localized: "新しいスライド")), storage: storage, isNew: true)) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .fileImporter(
            isPresented: $showFileImporter,
            allowedContentTypes: [.slidysShare],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                guard let url = urls.first else { return }
                if !storage.importDeck(from: url) {
                    importError = String(localized: "ファイルの読み込みに失敗しました")
                    showImportError = true
                }
            case .failure(let error):
                importError = error.localizedDescription
                showImportError = true
            }
        }
        #if canImport(FoundationModels)
        .fileImporter(
            isPresented: $showMarkdownImporter,
            allowedContentTypes: [.plainText],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                guard let url = urls.first else { return }
                isImporting = true
                importTask = Task { @MainActor in
                    do {
                        try await storage.importMarkdownDeck(from: url)
                    } catch {
                        if !Task.isCancelled {
                            importError = error.localizedDescription
                            showImportError = true
                        }
                    }
                    isImporting = false
                    importTask = nil
                }
            case .failure(let error):
                importError = error.localizedDescription
                showImportError = true
            }
        }
        #endif
        .alert("読み込みエラー", isPresented: $showImportError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(importError ?? "不明なエラー")
        }
        .overlay {
            if storage.decks.isEmpty {
                ContentUnavailableView("スライドがありません", systemImage: "rectangle.on.rectangle.slash", description: Text("右上の+ボタンからスライドを作成してください"))
            }
        }
        #if canImport(FoundationModels)
        .overlay {
            if isImporting {
                ZStack {
                    Color.black.opacity(0.3)
                    VStack(spacing: 12) {
                        ProgressView()
                        Text("マークダウンを解析中...")
                            .font(.caption)
                        Button(String(localized: "キャンセル"), role: .cancel) {
                            importTask?.cancel()
                            isImporting = false
                            importTask = nil
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        #endif
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        SlideListView(storage: PreviewSampleData.sampleStorage, connection: PreviewSampleData.sampleConnection)
    }
}
#endif
