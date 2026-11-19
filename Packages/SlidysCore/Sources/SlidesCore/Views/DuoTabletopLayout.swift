import SwiftUI
import SlideKit

/// The division frame is supplied by the system in this view's coordinate space.
/// Leave breathing room on both sides of the physical hinge.
struct DuoTabletopLayout<SlideContent: View, Controls: View>: View {
    let division: CGRect
    @ViewBuilder var slide: () -> SlideContent
    @ViewBuilder var controls: () -> Controls

    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                slide()
                    .frame(width: proxy.size.width, height: max(0, division.minY - 16))
                    .clipped()
                Color.black.frame(height: division.height + 32)
                controls()
                    .frame(width: proxy.size.width, height: max(0, proxy.size.height - division.maxY - 16))
                    .clipped()
            }
        }
        .background(.black)
    }
}

private struct DuoTabletopPreview: View {
    let showsNotes: Bool
    @StateObject private var controller = SlideIndexController {
        CenterTextSlide(text: "現在のスライド", script: "現在のスライドの原稿を表示します。\nヒンジより上にはスライド、下には原稿と操作ボタンを配置します。")
        CenterTextSlide(text: "次のスライド", script: "次のスライドの原稿")
    }

    var body: some View {
        DuoTabletopLayout(division: CGRect(x: 0, y: 590, width: 900, height: 20)) {
            Color.gray.overlay(Text("現在のスライド").font(.largeTitle).foregroundStyle(.white))
        } controls: {
            if showsNotes {
                SpeakerNotesPanel(slideIndexController: controller)
            } else {
                SlideNavigationBar(slideIndexController: controller)
                    .padding(24)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

#Preview("Duo 卓上・操作", traits: .fixedLayout(width: 900, height: 1200)) {
    DuoTabletopPreview(showsNotes: false)
}

#Preview("Duo 卓上・ノート", traits: .fixedLayout(width: 900, height: 1200)) {
    DuoTabletopPreview(showsNotes: true)
}
