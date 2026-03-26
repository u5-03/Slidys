import SwiftUI
import SlideKit

struct TitleImageContentView: View {
    let title: String
    let imageData: Data

    var body: some View {
        HeaderSlide(.init(title)) {
            if let image = platformImage(from: imageData) {
                image
                    .resizable()
                    .scaledToFit()
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.slideBackgroundColor)
            }
        }
    }
}
