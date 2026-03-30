import SwiftUI
import PhotosUI
import SlideKit
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

            Section("スタイル") {
                ColorPicker("テキストの色", selection: Binding(
                    get: { deck.style.textColor.color },
                    set: { deck.style.textColor = CodableColor(color: $0) }
                ))
                ColorPicker("背景の色", selection: Binding(
                    get: { deck.style.backgroundColor.color },
                    set: { deck.style.backgroundColor = CodableColor(color: $0) }
                ))
                ColorPicker("アクセントカラー", selection: Binding(
                    get: { deck.style.accentColor.color },
                    set: { deck.style.accentColor = CodableColor(color: $0) }
                ))
            }

            Section("ページ") {
                ForEach($deck.pages) { $page in
                    SlidePageEditRow(page: $page, style: deck.style)
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
        .formStyle(.grouped)
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

#if DEBUG
#Preview {
    NavigationStack {
        SlideEditView(deck: PreviewSampleData.sampleDeck, storage: PreviewSampleData.sampleStorage, isNew: true)
    }
}
#endif

struct SlidePageEditRow: View {
    @Binding var page: SlidePageData
    let style: SlideStyle
    @State private var selectedType: Int = 0
    @State private var centerText: String = ""
    @State private var titleText: String = ""
    @State private var listItems: [ListItem] = []
    @State private var imageData: Data = Data()
    @State private var originalImageData: Data?
    @State private var imageQuality: ImageQuality = .low
    @State private var codeText: String = ""
    @State private var selectedPhoto: PhotosPickerItem?

    var body: some View {
        DisclosureGroup {
            Picker("種別", selection: $selectedType) {
                Text("中央テキスト").tag(0)
                Text("タイトル+リスト").tag(1)
                Text("タイトル+画像").tag(2)
                Text("画像のみ").tag(3)
                Text("コード").tag(4)
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
                imagePickerSection
            case 3:
                imagePickerSection
            case 4:
                TextField("タイトル", text: $titleText)
                    .onChange(of: titleText) { _, _ in syncToPage() }
                TextField("コード", text: $codeText, axis: .vertical)
                    .font(.system(.body, design: .monospaced))
                    .lineLimit(3...10)
                    .onChange(of: codeText) { _, _ in syncToPage() }
            default:
                EmptyView()
            }
        } label: {
            HStack(spacing: 8) {
                PresentationView(slideSize: SlideSize.standard16_9) {
                    DynamicSlideContentView(pageData: page, style: style)
                }
                .aspectRatio(16/9, contentMode: .fit)
                .frame(width: 120, height: 67.5)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .allowsHitTesting(false)

                Text(pageLabel)
                    .lineLimit(1)
            }
        }
        .onAppear { loadFromPage() }
    }

    @ViewBuilder
    private var imagePickerSection: some View {
        PhotosPicker("画像を選択", selection: $selectedPhoto, matching: .images)
            .onChange(of: selectedPhoto) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        originalImageData = data
                        imageData = Self.compressImage(data: data, quality: imageQuality)
                        selectedPhoto = nil
                        syncToPage()
                    }
                }
            }
        Picker("画質", selection: $imageQuality) {
            ForEach(ImageQuality.allCases, id: \.self) { quality in
                Text(quality.displayName).tag(quality)
            }
        }
        .onChange(of: imageQuality) { _, newQuality in
            if let original = originalImageData {
                imageData = Self.compressImage(data: original, quality: newQuality)
            } else if !imageData.isEmpty {
                imageData = Self.compressImage(data: imageData, quality: newQuality)
            }
            syncToPage()
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
    }

    private var pageLabel: String {
        switch page.type {
        case .centerText(let text): return text.isEmpty ? "中央テキスト" : text
        case .titleList(let title, _): return title.isEmpty ? "タイトル+リスト" : title
        case .titleImage(let title, _): return title.isEmpty ? "タイトル+画像" : title
        case .centerImage: return "画像のみ"
        case .code(let title, _): return title.isEmpty ? "コード" : title
        }
    }

    private func loadFromPage() {
        imageQuality = page.imageQuality
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
        case .centerImage(let data):
            selectedType = 3
            imageData = data
        case .code(let title, let code):
            selectedType = 4
            titleText = title
            codeText = code
        }
    }

    private func updatePageType(_ type: Int) {
        switch type {
        case 0: page.type = .centerText(text: centerText)
        case 1: page.type = .titleList(title: titleText, items: listItems)
        case 2: page.type = .titleImage(title: titleText, imageData: imageData)
        case 3: page.type = .centerImage(imageData: imageData)
        case 4: page.type = .code(title: titleText, code: codeText)
        default: break
        }
    }

    private func syncToPage() {
        updatePageType(selectedType)
        page.imageQuality = imageQuality
    }

    private static func compressImage(data: Data, quality imageQuality: ImageQuality) -> Data {
        let maxImageBytes = imageQuality.maxBytes
        let dimensionSteps = imageQuality.maxDimensionSteps
        let initialQuality = imageQuality.initialQuality

        #if canImport(UIKit)
        guard let original = UIImage(data: data) else { return data }
        for maxDim in dimensionSteps {
            let resized = resizeUIImage(original, maxDimension: maxDim)
            var quality: CGFloat = initialQuality
            while quality >= 0.1 {
                if let jpeg = resized.jpegData(compressionQuality: quality),
                   jpeg.count <= maxImageBytes {
                    return jpeg
                }
                quality -= 0.1
            }
        }
        let smallest = resizeUIImage(original, maxDimension: dimensionSteps.last ?? 320)
        return smallest.jpegData(compressionQuality: 0.1) ?? data
        #elseif canImport(AppKit)
        guard let original = NSImage(data: data) else { return data }
        for maxDim in dimensionSteps {
            let resized = resizeNSImage(original, maxDimension: maxDim)
            guard let tiffData = resized.tiffRepresentation,
                  let bitmap = NSBitmapImageRep(data: tiffData) else { continue }
            var quality: CGFloat = initialQuality
            while quality >= 0.1 {
                if let jpeg = bitmap.representation(using: .jpeg, properties: [.compressionFactor: quality]),
                   jpeg.count <= maxImageBytes {
                    return jpeg
                }
                quality -= 0.1
            }
        }
        let smallest = resizeNSImage(original, maxDimension: dimensionSteps.last ?? 320)
        if let tiffData = smallest.tiffRepresentation,
           let bitmap = NSBitmapImageRep(data: tiffData) {
            return bitmap.representation(using: .jpeg, properties: [.compressionFactor: 0.1]) ?? data
        }
        return data
        #endif
    }

    #if canImport(UIKit)
    private static func resizeUIImage(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
        let size = image.size
        guard size.width > maxDimension || size.height > maxDimension else { return image }
        let scale = maxDimension / max(size.width, size.height)
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in image.draw(in: CGRect(origin: .zero, size: newSize)) }
    }
    #elseif canImport(AppKit)
    private static func resizeNSImage(_ image: NSImage, maxDimension: CGFloat) -> NSImage {
        let size = image.size
        guard size.width > maxDimension || size.height > maxDimension else { return image }
        let scale = maxDimension / max(size.width, size.height)
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let resized = NSImage(size: newSize)
        resized.lockFocus()
        image.draw(in: CGRect(origin: .zero, size: newSize))
        resized.unlockFocus()
        return resized
    }
    #endif
}
