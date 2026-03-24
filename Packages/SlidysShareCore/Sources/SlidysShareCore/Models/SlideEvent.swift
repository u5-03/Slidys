import Foundation

public enum SlideEvent: Codable, Equatable {
    case openSlide(pageCount: Int)
    case showPage(index: Int, page: SlidePageData)
    case closeSlide
}
