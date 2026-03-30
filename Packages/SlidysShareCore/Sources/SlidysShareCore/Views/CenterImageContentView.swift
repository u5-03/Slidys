import SwiftUI

struct CenterImageContentView: View {
    let imageData: Data
    let style: SlideStyle

    var body: some View {
        if let image = platformImage(from: imageData) {
            image
                .resizable()
                .scaledToFit()
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
