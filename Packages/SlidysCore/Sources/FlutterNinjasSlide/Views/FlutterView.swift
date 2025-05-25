//
//  FlutterView.swift
//
//
//  Created by Yugo Sugiyama on 2024/11/10.
//

import SwiftUI

struct FlutterView: View {
    @Environment(\.router) var router
    let type: FlutterNinjasViewType

    var body: some View {
        router.build(viewType: type)
    }
}


