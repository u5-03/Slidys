import SwiftUI
import SlideKit
import SyntaxInk

struct CodeContentView: View {
    let title: String
    let code: String
    let style: SlideStyle

    var body: some View {
        HeaderSlide(LocalizedStringKey(title)) {
            Code(
                code,
                syntaxHighlighter: .presentationDark(fontSize: 40)
            )
        }
    }
}
