import SwiftUI
import SlidesCore

struct CenterImageContentView: View {
    let imageData: Data

    var body: some View {
        if let image = platformImage(from: imageData) {
            image
                .resizable()
                .scaledToFit()
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.slideBackgroundColor)
        }
    }
}
