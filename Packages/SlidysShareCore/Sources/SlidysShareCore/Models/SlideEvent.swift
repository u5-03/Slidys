import Foundation

public enum SlideEvent: Codable {
    case openSlide(pageCount: Int)
    case showPage(index: Int, page: SlidePageData)
    case closeSlide
}
