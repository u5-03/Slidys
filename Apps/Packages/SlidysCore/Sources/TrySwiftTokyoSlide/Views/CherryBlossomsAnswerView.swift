//
//  Created by yugo.sugiyama on 2025/03/16
//  Copyright ©Sugiy All rights reserved.
//

import SwiftUI
import SlidesCore

struct CherryBlossomsAnswerView: View {
    var body: some View {
        ZStack {
            CherryBlossomsOutlineShape()
                .fill(Color(hex: "F4DCE2"))
            CherryBlossomsBranchShape()
                .fill(Color(hex: "C89B6C"))
            CherryBlossomsPetalsShape()
                .fill(Color(hex: "ECADC9"))
        }
        .aspectRatio(CherryBlossomsShape.aspectRatio, contentMode: .fit)
    }
}

#Preview {
    CherryBlossomsAnswerView()
}
