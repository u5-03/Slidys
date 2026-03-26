import SwiftUI
import SlidysShareCore

struct ContentView: View {
    @State private var storage = SlideStorage()
    @State private var multipeerManager = MultipeerManager()

    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                Text("Slidys Share")
                    .font(.largeTitle.bold())

                NavigationLink("スライドを配信する") {
                    SlideListView(storage: storage, connection: multipeerManager)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                NavigationLink("スライドを受信する") {
                    SlideReceiverView(connection: multipeerManager)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
            .navigationTitle("Slidys Share")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape")
                    }
                }
            }
        }
    }
}
