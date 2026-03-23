import SwiftUI
import SlidysShareCore

struct SlideListView: View {
    @Bindable var storage: SlideStorage
    let connection: MultipeerManager

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
                NavigationLink(destination: SlideEditView(deck: SlideDeck(title: "新しいスライド"), storage: storage, isNew: true)) {
                    Image(systemName: "plus")
                }
            }
        }
        .overlay {
            if storage.decks.isEmpty {
                ContentUnavailableView("スライドがありません", systemImage: "rectangle.on.rectangle.slash", description: Text("右上の+ボタンからスライドを作成してください"))
            }
        }
    }
}
