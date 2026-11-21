import SlideKit
import SwiftUI

/// Keep existential opening outside preview-instrumented view bodies. Xcode's
/// __designTimeSelection wrapper otherwise prevents AnyView from opening any Slide.
@MainActor
func presentationSlideView(_ slide: any Slide) -> AnyView {
    AnyView(slide)
}
