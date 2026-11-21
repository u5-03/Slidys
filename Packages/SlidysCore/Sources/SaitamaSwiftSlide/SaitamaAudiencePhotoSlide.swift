import SlideKit
import SlidesCore
import SwiftUI
#if os(iOS)
import UIKit

/// Keeps the newest audience photo available across independently rendered slide windows.
final class AudiencePhotoStore: ObservableObject {
    static let shared = AudiencePhotoStore()
    @Published var photo: UIImage?

    private init() {
        guard let directory = try? FileManager.default.url(
            for: .applicationSupportDirectory, in: .userDomainMask,
            appropriateFor: nil, create: false
        ).appendingPathComponent("SaitamaAudiencePhotos", isDirectory: true),
        let files = try? FileManager.default.contentsOfDirectory(
            at: directory, includingPropertiesForKeys: [.contentModificationDateKey]
        ) else { return }
        let latest = files.filter { $0.pathExtension == "jpg" }.max {
            let lhs = (try? $0.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? .distantPast
            let rhs = (try? $1.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? .distantPast
            return lhs < rhs
        }
        if let latest { photo = UIImage(contentsOfFile: latest.path)?.audienceWidePhoto() }
    }
}
extension UIImage {
    /// Match the wide viewfinder, normalizing image orientation while cropping.
    func audienceWidePhoto() -> UIImage {
        let ratio: CGFloat = 2
        let target = size.width / size.height > ratio
            ? CGSize(width: size.height * ratio, height: size.height)
            : CGSize(width: size.width, height: size.width / ratio)
        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        format.opaque = true
        return UIGraphicsImageRenderer(size: target, format: format).image { _ in
            draw(in: CGRect(x: (target.width - size.width) / 2,
                            y: (target.height - size.height) / 2,
                            width: size.width, height: size.height))
        }
    }
}
#endif

@Slide struct SaitamaAudiencePhotoSlide: View {
    var script: String { "回答者はこちらの方々です！" }
    var transition: AnyTransition { SlideTransition.defaultTransition }
#if os(iOS)
    @ObservedObject private var photos = AudiencePhotoStore.shared
#endif
    var body: some View {
        AudiencePhotoContent(photo: audienceImage)
    }

    private var audienceImage: Image? {
#if os(iOS)
        photos.photo.map { Image(uiImage: $0) }
#else
        nil
#endif
    }
}

private struct AudiencePhotoContent: View {
    let photo: Image?
    var body: some View {
        VStack(spacing: 36) {
            Text("回答者はこちらの方々！")
                .font(.system(size: 80, weight: .bold))
                .foregroundStyle(.white)
            if let photo {
                GeometryReader { proxy in
                    photo.resizable().scaledToFill()
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .clipped()
                }
                .aspectRatio(2, contentMode: .fit)
            } else {
                Color.clear.frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 48)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.slideBackgroundColor)
    }
}

@Slide private struct AudiencePhotoLayoutPreview: View {
    var body: some View {
        AudiencePhotoContent(photo: Image("OpeningPhoto", bundle: .module))
    }
}

#Preview("回答者の写真（レイアウト確認）") {
    SlidePreview { AudiencePhotoLayoutPreview() }.slideTheme(CustomSlideTheme(showSlideIndex: false, listTextStyle: .large))
}
