#if os(iOS)
import SwiftUI
import SlideKit

enum DuoNotesHingeEdge: String, CaseIterable, Identifiable {
    case left, right, top, bottom
    var id: Self { self }
    var title: String {
        switch self {
        case .left: "左"
        case .right: "右"
        case .top: "上"
        case .bottom: "下"
        }
    }
}

/// Inset the entire notes UI, including its navigation bar and page controls.
/// Physical sides are configurable because a case cover is not represented by OS safe areas.
struct DuoNotesCaseMargin: ViewModifier {
    @AppStorage("duoNotesHingeEdge") private var edge = DuoNotesHingeEdge.left
    @AppStorage("duoNotesHingeMargin") private var width = 72

    func body(content: Content) -> some View {
        content.modifier(DuoNotesPhysicalInset(edge: edge, width: CGFloat(width)))
    }
}

private struct DuoNotesPhysicalInset: ViewModifier {
    let edge: DuoNotesHingeEdge
    let width: CGFloat
    @Environment(\.layoutDirection) private var direction

    func body(content: Content) -> some View {
        let left = edge == .left ? width : 0
        let right = edge == .right ? width : 0
        content.padding(EdgeInsets(
            top: edge == .top ? width : 0,
            leading: direction == .leftToRight ? left : right,
            bottom: edge == .bottom ? width : 0,
            trailing: direction == .leftToRight ? right : left
        ))
        .background(.black)
    }
}

struct DuoNotesCaseMarginMenu: View {
    @AppStorage("duoNotesHingeEdge") private var edge = DuoNotesHingeEdge.left
    @AppStorage("duoNotesHingeMargin") private var width = 72

    var body: some View {
        Menu("ヒンジカバーの余白") {
            Picker("ヒンジの位置", selection: $edge) {
                ForEach(DuoNotesHingeEdge.allCases) { edge in
                    Text(edge.title).tag(edge)
                }
            }
            Picker("余白の幅", selection: $width) {
                ForEach([0, 48, 72, 96], id: \.self) { width in
                    Text("\(width) pt").tag(width)
                }
            }
        }
    }
}

#if DEBUG
private struct DuoNotesCasePreview: View {
    let edge: DuoNotesHingeEdge
    private let controller = SlideIndexController {
        CenterTextSlide(text: "現在のスライド", script: "ヒンジカバーの下にノートや操作ボタンが隠れないよう、画面の端に余白を設けています。")
        CenterTextSlide(text: "次のスライド", script: "次のノート")
    }
    var body: some View {
        NavigationStack {
            SpeakerNotesView(
                slideIndexController: controller,
                slideTheme: CustomSlideTheme(showSlideIndex: false, listTextStyle: .large),
                handlesKeyboardNavigation: false,
                usesPortraitPresenterLayout: true,
                interactiveCurrentSlide: false
            )
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Text("Duo") } }
        }
        .preferredColorScheme(.dark)
        .modifier(DuoNotesPhysicalInset(edge: edge, width: 72))
    }
}

#Preview("Duo外側ノート・左に72pt", traits: .fixedLayout(width: 466, height: 678)) {
    DuoNotesCasePreview(edge: .left)
}
#Preview("Duo外側ノート・右に72pt", traits: .fixedLayout(width: 466, height: 678)) {
    DuoNotesCasePreview(edge: .right)
}
#endif
#endif
