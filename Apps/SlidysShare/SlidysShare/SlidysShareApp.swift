//
//  Created by yugo.sugiyama on 2026/03/23
//  Copyright (C)Sugiy All rights reserved.
//

import SwiftUI

@main
struct SlidysShareApp: App {
    @State private var storage = SlideStorage()

    var body: some Scene {
        WindowGroup {
            ContentView(storage: storage)
                .onOpenURL { url in
                    storage.importDeck(from: url)
                }
        }
    }
}
