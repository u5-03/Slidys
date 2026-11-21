/// How the presenter uses the two physical displays of iPhone Duo.
public enum DuoDisplayMode: String, CaseIterable, Identifiable {
    case outerSlides
    case mirroredSlides
    case innerSlides

    public var id: String { rawValue }
    public var title: String {
        switch self {
        case .outerSlides: "外側にスライド・内側にノート"
        case .mirroredSlides: "両画面にスライド（操作を共有）"
        case .innerSlides: "内側にスライド・外側にノート"
        }
    }
}

/// Output rendering and the presenter's layout are separate choices.
struct PresenterDisplayRouting {
    var externalConnected: Bool
    var externalPresentation: Bool
    var duoEnabled: Bool
    var duoMode: DuoDisplayMode
    var capturesOutput: Bool

    var mainShowsPresenterNotes: Bool {
        if duoEnabled { return duoMode == .outerSlides }
        return externalConnected && externalPresentation
    }
    var mainMirrorsOuter: Bool {
        duoEnabled && duoMode == .innerSlides && capturesOutput
    }
    var outerShowsPresenterNotes: Bool { duoEnabled && duoMode == .innerSlides }
    var outerMirrorsMain: Bool {
        duoEnabled && (duoMode == .mirroredSlides || (duoMode == .outerSlides && capturesOutput))
    }
    var interactiveMainPreview: Bool {
        capturesOutput || (duoEnabled && duoMode == .mirroredSlides)
    }
}
