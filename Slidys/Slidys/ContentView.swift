//
//  ContentView.swift
//  Slidys
//
//  Created by Yugo Sugiyama on 2024/10/27.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
            Text("Hello, world!")
            FlutterView(type: .circle)
                .frame(height: 400)
                .background(.red)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
