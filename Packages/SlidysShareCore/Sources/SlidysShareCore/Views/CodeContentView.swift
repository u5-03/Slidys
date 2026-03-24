import SwiftUI
import SlideKit
import SlidesCore
import SyntaxInk

struct CodeContentView: View {
    let title: String
    let code: String

    var body: some View {
        HeaderSlide(LocalizedStringKey(title)) {
            Code(
                code,
                syntaxHighlighter: .presentationDark(fontSize: 40)
            )
        }
    }
}
