//
//  Created by ___USERNAME___ on ___DATE___
//  Copyright ©Sugiy All rights reserved.
//

import SwiftUI
import SlideKit
import SlidesCore

public struct  ___FILEBASENAME___View: SlideViewProtocol {
    let configuration = SlideConfiguration()

    public init() {}

    public var body: some View {
        SlideBaseView(slideConfiguration: configuration)
    }
}

struct SlideConfiguration: SlideConfigurationProtocol {
    let slideIndexController = SlideIndexController() {
        CenterTextSlide(text: "")
    }
}
