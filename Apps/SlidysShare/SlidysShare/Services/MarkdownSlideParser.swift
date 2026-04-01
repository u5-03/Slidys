#if canImport(FoundationModels)
import Foundation
import FoundationModels
import SlidysShareCore

@Generable(description: "A slide deck with a title and pages")
struct GenerableSlideDeckDTO {
    @Guide(description: "The title of the slide deck")
    var title: String
    @Guide(description: "Array of slide pages")
    var pages: [GenerableSlidePageDTO]
}

@Generable(description: "A single slide page")
struct GenerableSlidePageDTO {
    @Guide(description: "Slide type: centerText, titleList, or code", .anyOf(["centerText", "titleList", "code"]))
    var type: String
    @Guide(description: "Main text for centerText, or title for titleList/code")
    var title: String
    @Guide(description: "List items for titleList type, nil otherwise")
    var listItems: [GenerableListItemDTO]?
    @Guide(description: "Code string for code type, nil otherwise")
    var code: String?
    @Guide(description: "List style: bullet for - items, numbered for 1. 2. items. Default bullet.", .anyOf(["bullet", "numbered"]))
    var listStyle: String?
}

@Generable(description: "A list item")
struct GenerableListItemDTO {
    @Guide(description: "The text of the list item")
    var text: String
    @Guide(description: "true if this is a sub-item (indented)")
    var isIndented: Bool
}

enum MarkdownSlideParserError: LocalizedError {
    case modelUnavailable(details: String)
    case parsingFailed(underlying: Error, details: String)

    var errorDescription: String? {
        switch self {
        case .modelUnavailable(let details):
            return String(localized: "Apple Intelligenceが利用できません。\(details)")
        case .parsingFailed(let underlying, let details):
            return String(localized: "Markdownの解析に失敗しました: \(underlying.localizedDescription)\n詳細: \(details)")
        }
    }
}

struct MarkdownSlideParser {
    func parse(markdown: String, deckTitle: String? = nil) async throws -> SlideDeck {
        let trimmed = markdown.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return SlideDeck(title: deckTitle ?? "", pages: [])
        }

        let model = SystemLanguageModel.default

        // 詳細な利用可否チェック
        switch model.availability {
        case .available:
            break
        case .unavailable(let reason):
            let details: String
            switch reason {
            case .deviceNotEligible:
                details = String(localized: "このデバイスはApple Intelligenceに対応していません。")
            case .appleIntelligenceNotEnabled:
                details = String(localized: "設定でApple Intelligenceを有効にしてください。")
            case .modelNotReady:
                details = String(localized: "モデルのダウンロード中です。しばらくお待ちください。")
            @unknown default:
                details = String(localized: "理由: \(String(describing: reason))")
            }
            throw MarkdownSlideParserError.modelUnavailable(details: details)
        }

        let instructions = """
        Convert Markdown to a slide deck. Rules:
        - First # heading = deck title. No # heading = title "Untitled".
        - Pages split by --- or ## headings.
        - centerText: text without list or code block. Title = the text content.
        - titleList: has ## heading AND list items. Each list item must have its full original text. Never abbreviate with "…" or ellipsis.
        - code: has ## heading AND fenced code block.
        - Ambiguous content = centerText.
        - Use ONLY text from the input. Never invent, summarize, or abbreviate content.
        - Ignore HTML comments.
        """

        let session = LanguageModelSession(instructions: instructions)

        let prompt = "Convert this Markdown into a slide deck:\n\n\(markdown)"
        let debugInfo = "markdownLength=\(markdown.count), promptLength=\(prompt.count)"

        do {
            let response = try await session.respond(
                to: prompt,
                generating: GenerableSlideDeckDTO.self
            )
            return response.content.toDomain(deckTitle: deckTitle)
        } catch let error as LanguageModelSession.GenerationError {
            let errorDetail: String
            switch error {
            case .exceededContextWindowSize:
                errorDetail = String(localized: "コンテキストウィンドウを超えました。Markdownが長すぎます。") + "(\(debugInfo))"
            case .guardrailViolation:
                errorDetail = String(localized: "コンテンツがガードレールに違反しました。") + "(\(debugInfo))"
            case .unsupportedLanguageOrLocale:
                errorDetail = String(localized: "サポートされていない言語/ロケールです。") + "(\(debugInfo))"
            case .assetsUnavailable:
                errorDetail = String(localized: "モデルアセットが利用できません。ダウンロード状態を確認してください。") + "(\(debugInfo))"
            case .unsupportedGuide:
                errorDetail = String(localized: "@Guideの制約がサポートされていません。") + "(\(debugInfo))"
            case .decodingFailure:
                errorDetail = String(localized: "モデル出力のデコードに失敗しました。") + "(\(debugInfo))"
            case .rateLimited:
                errorDetail = String(localized: "レート制限に達しました。しばらく待ってから再試行してください。") + "(\(debugInfo))"
            case .concurrentRequests:
                errorDetail = String(localized: "同時リクエストが多すぎます。") + "(\(debugInfo))"
            case .refusal:
                errorDetail = String(localized: "モデルがリクエストを拒否しました。") + "(\(debugInfo))"
            @unknown default:
                let nsErr = error as NSError
                errorDetail = "GenerationError code=\(nsErr.code), domain=\(nsErr.domain), userInfo=\(nsErr.userInfo), \(debugInfo)"
            }
            throw MarkdownSlideParserError.parsingFailed(underlying: error, details: errorDetail)
        } catch {
            let nsError = error as NSError
            let errorDetail = "code=\(nsError.code), domain=\(nsError.domain), userInfo=\(nsError.userInfo), \(debugInfo)"
            throw MarkdownSlideParserError.parsingFailed(underlying: error, details: errorDetail)
        }
    }
}

private extension GenerableSlideDeckDTO {
    func toDomain(deckTitle: String? = nil) -> SlideDeck {
        let slidePages = pages.map { dto -> SlidePageData in
            let slideType: ShareSlideType
            let listBulletStyle: ListBulletStyle = dto.listStyle == "numbered" ? .numbered : .bullet
            switch dto.type {
            case "centerText":
                slideType = .centerText(text: dto.title)
            case "titleList":
                let items = dto.listItems?.map { item in
                    ListItem(text: item.text, isIndented: item.isIndented)
                } ?? []
                slideType = .titleList(title: dto.title, items: items)
            case "code":
                slideType = .code(title: dto.title, code: dto.code ?? "")
            default:
                slideType = .centerText(text: dto.title)
            }
            return SlidePageData(type: slideType, listBulletStyle: listBulletStyle)
        }
        return SlideDeck(title: deckTitle ?? title, pages: slidePages)
    }
}
#endif
