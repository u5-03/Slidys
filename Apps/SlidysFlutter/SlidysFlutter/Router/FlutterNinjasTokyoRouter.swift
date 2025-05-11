//
//  Created by yugo.sugiyama on 2025/05/10
//  Copyright ©Sugiy All rights reserved.
//

import SwiftUI
import FlutterNinjasSlide

public struct FlutterNinjasRouter: RouterProtocol {
    public init() {}

    /// 遷移先の画面を返すだけ, 画面遷移 はView側で行う
    public func build(viewType: FlutterNinjasViewType) -> AnyView {
        return AnyView(SlidysFlutter.FlutterView(type: .flutterNinjas(type: viewType)))
    }
}
