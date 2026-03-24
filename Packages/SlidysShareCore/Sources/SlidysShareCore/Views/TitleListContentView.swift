import SwiftUI
import SlideKit
import SlidesCore

struct TitleListContentView: View {
    let title: String
    let items: [ListItem]

    var body: some View {
        HeaderSlide(.init(title)) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                if item.isIndented {
                    Item("", accessory: .number(index + 1)) {
                        Item(LocalizedStringKey(item.text))
                    }
                } else {
                    Item(LocalizedStringKey(item.text), accessory: .number(index + 1))
                }
            }
        }
    }
}
