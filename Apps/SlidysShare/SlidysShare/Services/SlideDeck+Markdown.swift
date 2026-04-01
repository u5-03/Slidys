import Foundation
import SlidysShareCore

extension SlideDeck {
    func toMarkdown() -> String {
        var lines: [String] = []
        lines.append("# \(title)")

        for page in pages {
            lines.append("")
            lines.append("---")
            lines.append("")
            lines.append(page.type.toMarkdown())
        }

        return lines.joined(separator: "\n")
    }
}

private extension ShareSlideType {
    func toMarkdown() -> String {
        switch self {
        case .centerText(let text):
            return "<!-- type: centerText -->\n## \(text)"

        case .titleList(let title, let items):
            var result = "<!-- type: titleList -->\n## \(title)\n"
            for item in items {
                if item.isIndented {
                    result += "\n  - \(item.text)"
                } else {
                    result += "\n- \(item.text)"
                }
            }
            return result

        case .titleImage(let title, _):
            return "<!-- type: titleImage -->\n## \(title)\n<!-- image omitted -->"

        case .centerImage:
            return "<!-- type: centerImage -->\n<!-- image omitted -->"

        case .code(let title, let code):
            return "<!-- type: code -->\n## \(title)\n\n```\n\(code)\n```"
        }
    }
}
