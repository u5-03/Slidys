//
//  Created by ___USERNAME___ on ___DATE___
//  Copyright ©Sugiy All rights reserved.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
public struct ___FILEBASENAME___: View {
    public init() {}

    public var body: some View {
        HeaderSlide("") {
        }
    }
}

#Preview {
    SlidePreview {
        ___FILEBASENAME___()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
