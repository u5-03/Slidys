import SlideKit
import SwiftUI

/// An in-app overview. Only the selected slide runs live media and RealityView.
public struct SlideDeckPreviewView: View {
    private let onClose: (() -> Void)?
    private let title: String
    private let theme: CustomSlideTheme
    private let slideSize: CGSize
    @StateObject private var controller: SlideIndexController
    @State private var showsSlide = false
    @Environment(\.dismiss) private var dismiss

    public init(
        title: String,
        slideIndexController: SlideIndexController,
        listTextStyle: ListTextStyle = .standard,
        slideSize: CGSize = SlideSize.standard16_9,
        onClose: (() -> Void)? = nil
    ) {
        self.onClose = onClose
        self.title = title
        self.theme = CustomSlideTheme(showSlideIndex: false, listTextStyle: listTextStyle)
        self.slideSize = slideSize
        _controller = StateObject(wrappedValue: slideIndexController)
    }

    public var body: some View {
        NavigationStack {
            Group {
                if showsSlide {
                    livePreview
                } else {
                    overview
                }
            }
            .navigationTitle(title)
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") {
                        if let onClose { onClose() } else { dismiss() }
                    }
                }
                if showsSlide {
                    ToolbarItem(placement: .primaryAction) {
                        Button("一覧", systemImage: "square.grid.3x3") { showsSlide = false }
                    }
                }
            }
        }
        .followsSlideLanguage()
    }

    private var overview: some View {
        GeometryReader { geometry in
            // Explicit flexible columns stay within the sheet on iPad and iPhone,
            // including when the window or device orientation changes.
            let count = max(1, min(5, Int((geometry.size.width - 24) / 180)))
            let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: count)
            ScrollViewReader { scroll in
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 18) {
                        ForEach(controller.slides.indices, id: \.self) { index in
                            Button {
                                controller.move(to: index)
                                showsSlide = true
                            } label: {
                                VStack(alignment: .leading, spacing: 6) {
                                    GeometryReader { tile in
                                        SlideThumbnailView(slide: controller.slides[index], theme: theme,
                                                           width: tile.size.width, slideSize: slideSize)
                                    }
                                    .aspectRatio(slideSize.width / slideSize.height, contentMode: .fit)
                                    Text("\(index + 1) / \(controller.slides.count)")
                                        .font(.system(.caption, design: .monospaced))
                                        .foregroundStyle(.secondary)
                                }
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("スライド\(index + 1)をプレビュー")
                            .id(index)
                        }
                    }
                    .padding(16)
                }
                .onAppear { scroll.scrollTo(controller.currentIndex, anchor: .center) }
            }
        }
    }

    private var livePreview: some View {
        VStack(spacing: 0) {
            GeometryReader { geometry in
                let width = min(geometry.size.width, geometry.size.height * slideSize.width / slideSize.height)
                SlideRouterView(slideIndexController: controller)
                    .slideTheme(theme)
                    .frame(width: slideSize.width, height: slideSize.height)
                    .scaleEffect(width / slideSize.width, anchor: .topLeading)
                    .frame(width: width, height: width * slideSize.height / slideSize.width, alignment: .topLeading)
                    .clipped()
                    .contentShape(Rectangle())
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            }
            // Clipping pixels alone leaves the original 1920×1080 hit region
            // active. Keep it inside the preview so it cannot cover navigation.
            .clipped()
            .contentShape(Rectangle())
            .background(.black)
            HStack {
                Button("前へ", systemImage: "chevron.left") { controller.back() }
                    .disabled(controller.currentIndex == 0)
                Spacer()
                Text("\(controller.currentIndex + 1) / \(controller.slides.count)")
                    .font(.system(.body, design: .monospaced))
                Spacer()
                Button("次へ", systemImage: "chevron.right") { controller.forward() }
                    .disabled(controller.currentIndex == controller.slides.count - 1)
            }
            .buttonStyle(.bordered)
            .padding(12)
        }
    }
}
