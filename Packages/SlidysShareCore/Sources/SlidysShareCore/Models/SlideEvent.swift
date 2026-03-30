import Foundation

public enum SlideEvent: Codable, Equatable {
    case openSlide(pageCount: Int, style: SlideStyle)
    case showPage(index: Int, page: SlidePageData)
    case closeSlide
    case reaction(ReactionType)
}
