import SwiftUI
import SlideKit

struct TitleListContentView: View {
    let title: String
    let items: [ListItem]
    let style: SlideStyle
    var listBulletStyle: ListBulletStyle = .bullet

    var body: some View {
        HeaderSlide(.init(title)) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                if item.isIndented {
                    switch listBulletStyle {
                    case .bullet:
                        Item("", accessory: .bullet) {
                            Item(LocalizedStringKey(item.text), accessory: .bullet)
                        }
                    case .numbered:
                        Item("", accessory: .number(index + 1)) {
                            Item(LocalizedStringKey(item.text))
                        }
                    }
                } else {
                    switch listBulletStyle {
                    case .bullet:
                        Item(LocalizedStringKey(item.text), accessory: .bullet)
                    case .numbered:
                        Item(LocalizedStringKey(item.text), accessory: .number(index + 1))
                    }
                }
            }
        }
    }
}
