//
//  ContentView.swift
//  SlidysMac
//
//  Created by Yugo Sugiyama on 2024/11/10.
//

import SwiftUI
import SlidysCommon

struct ContentView: View {
    var body: some View {
        SlidysCommonView(slideTypes: SlideType.allCases)
    }
}



#Preview {
    ContentView()
}
