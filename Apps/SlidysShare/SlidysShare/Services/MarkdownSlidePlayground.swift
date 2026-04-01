import Playgrounds
import Foundation
import FoundationModels
import SlidysShareCore

// テスト対象のmdファイル一覧（indexを変えて切り替え）
let sampleFiles = [
    "SampleSlide",              // 0: 基本サンプル（centerText/titleList/code混在）
    "Sample_CenterTextOnly",    // 1: centerTextのみ
    "Sample_TitleListVariety",  // 2: titleListバリエーション
    "Sample_CodeHeavy",         // 3: コード多め
    "Sample_MixedContent",      // 4: 混合コンテンツ
    "Sample_EnglishPresentation", // 5: 英語プレゼン
    "Sample_NoTypeHints",       // 6: 型ヒントなし（AI推論テスト）
    "Sample_FreeFormat",        // 7: 自由記述（メモ書き→スライド変換）
    "Sample_Minimal",           // 8: 最小構成（1ページのみ）
    "Sample_NoTitle",           // 9: デッキタイトルなし
    "Sample_SpecialCharacters", // 10: 特殊文字・絵文字
    "Sample_NumberList",        // 11: 番号付きリストでページ分割
]

// ↓ ここのindexを変えてテスト対象を切り替え
let selectedIndex = 11

#Playground {
    let model = SystemLanguageModel.default
    print("Model availability: \(model.availability)")

    guard model.isAvailable else {
        print("Model is not available!")
        return
    }

    let fileName = sampleFiles[selectedIndex]
    print("Selected: [\(selectedIndex)] \(fileName)")

    guard let url = Bundle.main.url(forResource: fileName, withExtension: "md") else {
        print("ERROR: \(fileName).md not found in bundle")
        return
    }

    let markdown = try String(contentsOf: url, encoding: .utf8)
    print("Markdown length: \(markdown.count) chars")
    print("---")
    print(markdown.prefix(200))
    print("---")

    let parser = MarkdownSlideParser()
    do {
        let deck = try await parser.parse(markdown: markdown)
        print("\nResult: \(deck.title)")
        print("Pages: \(deck.pages.count)")
        for (i, page) in deck.pages.enumerated() {
            switch page.type {
            case .centerText(let text):
                print("  [\(i)] centerText: \(text)")
            case .titleList(let title, let items):
                print("  [\(i)] titleList: \(title)")
                for item in items {
                    let prefix = item.isIndented ? "    - " : "  - "
                    print("       \(prefix)\(item.text)")
                }
            case .code(let title, let code):
                print("  [\(i)] code: \(title)")
                print("       \(code.prefix(80))")
            case .centerImage:
                print("  [\(i)] centerImage")
            case .titleImage(let title, _):
                print("  [\(i)] titleImage: \(title)")
            }
        }
    } catch {
        print("\nError: \(error.localizedDescription)")
    }
}
