//
//  Created by yugo.sugiyama on 2025/04/20
//  Copyright ©Sugiy All rights reserved.
//

import SwiftUI

struct PixelView: View {
    let pixel: Pixel

    var body: some View {
        Rectangle()
            .fill(pixel.color)
            .aspectRatio(1, contentMode: .fit)
    }
}
