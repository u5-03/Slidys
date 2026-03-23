import SwiftUI
import PhotosUI
import SlidysShareCore

struct SlideEditView: View {
    @State var deck: SlideDeck
    let storage: SlideStorage
    let isNew: Bool
    @Environment(\.dismiss) private var dismiss
    @State private var showPreview = false

    var body: some View {
        Form {
            Section("デッキ情報") {
                TextField("タイトル", text: $deck.title)
            }

            Section("ページ") {
                ForEach($deck.pages) { $page in
                    SlidePageEditRow(page: $page)
                }
                .onDelete { indexSet in
                    deck.pages.remove(atOffsets: indexSet)
                }
                .onMove { from, to in
                    deck.pages.move(fromOffsets: from, toOffset: to)
                }

                Button("ページを追加") {
                    deck.pages.append(SlidePageData(type: .centerText(text: "")))
                }
            }
        }
        .navigationTitle(isNew ? "新規スライド" : "スライド編集")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                HStack {
                    Button("プレビュー") {
                        showPreview = true
                    }
                    .disabled(deck.pages.isEmpty)

                    Button("保存") {
                        storage.save(deck: deck)
                        dismiss()
                    }
                }
            }
        }
        #if os(macOS)
        .sheet(isPresented: $showPreview) {
            SlidePreviewView(deck: deck)
        }
        #else
        .fullScreenCover(isPresented: $showPreview) {
            SlidePreviewView(deck: deck)
        }
        #endif
    }
}

struct SlidePageEditRow: View {
    @Binding var page: SlidePageData
    @State private var selectedType: Int = 0
    @State private var centerText: String = ""
    @State private var titleText: String = ""
    @State private var listItems: [ListItem] = []
    @State private var imageData: Data = Data()
    @State private var selectedPhoto: PhotosPickerItem?

    var body: some View {
        DisclosureGroup {
            Picker("種別", selection: $selectedType) {
                Text("中央テキスト").tag(0)
                Text("タイトル+リスト").tag(1)
                Text("タイトル+画像").tag(2)
            }
            .onChange(of: selectedType) { _, newValue in
                updatePageType(newValue)
            }

            switch selectedType {
            case 0:
                TextField("テキスト", text: $centerText, axis: .vertical)
                    .onChange(of: centerText) { _, _ in syncToPage() }
            case 1:
                TextField("タイトル", text: $titleText)
                    .onChange(of: titleText) { _, _ in syncToPage() }
                ForEach($listItems) { $item in
                    HStack {
                        Toggle("インデント", isOn: $item.isIndented)
                            .labelsHidden()
                            .toggleStyle(.button)
                            .onChange(of: item.isIndented) { _, _ in syncToPage() }
                        TextField("項目", text: $item.text)
                            .onChange(of: item.text) { _, _ in syncToPage() }
                    }
                }
                Button("項目を追加") {
                    listItems.append(ListItem(text: ""))
                    syncToPage()
                }
            case 2:
                TextField("タイトル", text: $titleText)
                    .onChange(of: titleText) { _, _ in syncToPage() }
                PhotosPicker("画像を選択", selection: $selectedPhoto, matching: .images)
                    .onChange(of: selectedPhoto) { _, newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                imageData = data
                                syncToPage()
                            }
                        }
                    }
                #if canImport(UIKit)
                if !imageData.isEmpty, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100)
                }
                #elseif canImport(AppKit)
                if !imageData.isEmpty, let nsImage = NSImage(data: imageData) {
                    Image(nsImage: nsImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100)
                }
                #endif
            default:
                EmptyView()
            }
        } label: {
            Text(pageLabel)
        }
        .onAppear { loadFromPage() }
    }

    private var pageLabel: String {
        switch page.type {
        case .centerText(let text): return text.isEmpty ? "中央テキスト" : text
        case .titleList(let title, _): return title.isEmpty ? "タイトル+リスト" : title
        case .titleImage(let title, _): return title.isEmpty ? "タイトル+画像" : title
        }
    }

    private func loadFromPage() {
        switch page.type {
        case .centerText(let text):
            selectedType = 0
            centerText = text
        case .titleList(let title, let items):
            selectedType = 1
            titleText = title
            listItems = items
        case .titleImage(let title, let data):
            selectedType = 2
            titleText = title
            imageData = data
        }
    }

    private func updatePageType(_ type: Int) {
        switch type {
        case 0: page.type = .centerText(text: centerText)
        case 1: page.type = .titleList(title: titleText, items: listItems)
        case 2: page.type = .titleImage(title: titleText, imageData: imageData)
        default: break
        }
    }

    private func syncToPage() {
        updatePageType(selectedType)
    }
}
