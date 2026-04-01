# サンプルMarkdownファイル 期待結果一覧

## [0] SampleSlide.md — 基本サンプル（centerText/titleList/code混在）
- title: "SwiftUIで始めるアプリ開発"
- pages: 5
- [0] centerText: "SwiftUIで始めるアプリ開発入門"
- [1] titleList: "今日のアジェンダ" (5 items, 2 indented)
- [2] titleList: "SwiftUIのメリット" (5 items, 2 indented)
- [3] code: "Hello Worldの例" (SwiftUIコード)
- [4] centerText: "まとめ"

## [1] Sample_CenterTextOnly.md — centerTextのみ
- title: "自己紹介"
- pages: 3
- [0] centerText: "はじめまして"（自己紹介文）
- [1] centerText: "本日のテーマ"（テーマ説明）
- [2] centerText: "ありがとうございました"（締め）
- NOTE: リストもコードブロックもないので全ページcenterText

## [2] Sample_TitleListVariety.md — titleListバリエーション
- title: "リスト形式のバリエーション"
- pages: 3
- [0] titleList: "基本的なリスト" (3 items, none indented)
- [1] titleList: "ネスト構造" (4 items, 2 indented)
- [2] titleList: "番号付きリスト" (3 items, none indented)
- NOTE: 番号付きリスト(1. 2. 3.)もListItemとしてパースされるべき

## [3] Sample_CodeHeavy.md — コード多め
- title: "コードサンプル集"
- pages: 3
- [0] code: "SwiftでのAPI呼び出し" (Swiftコード)
- [1] code: "Pythonでのデータ処理" (Pythonコード)
- [2] code: "SQLクエリ" (言語指定なしSQL)
- NOTE: 全ページcodeタイプ

## [4] Sample_MixedContent.md — 混合コンテンツ
- title: "モバイルアプリ設計パターン"
- pages: 4
- [0] centerText: "モバイルアプリ設計パターン入門"
- [1] titleList: "今日話すこと" (4 items, 2 indented)
- [2] code: "MVVMの基本構造" (Swiftコード)
- [3] centerText: "まとめ"

## [5] Sample_EnglishPresentation.md — 英語プレゼン
- title: "Introduction to Swift Concurrency"
- pages: 4
- [0] centerText: "Introduction to Swift Concurrency"
- [1] titleList: "What We Will Cover" (5 items, 3 indented)
- [2] code: "async/await Example" (Swiftコード)
- [3] centerText: "Thank You!"
- NOTE: 全て英語。日本語と同様にパースされるべき

## [6] Sample_NoTypeHints.md — 型ヒントなし（AI推論テスト）
- title: "型ヒントなしのMarkdown"
- pages: 4
- [0] centerText: "このスライドはシンプルなテキストです"
- [1] titleList: "買い物リスト" (5 items, 2 indented)
- [2] code: "設定ファイル" (YAMLコード)
- [3] centerText: "おわり"
- NOTE: type commentなし。コンテンツ構造からAIが推論

## [7] Sample_FreeFormat.md — 自由記述（メモ書き→スライド変換）
- title: "週次ミーティングメモ"
- pages: 3
- [0] titleList: "進捗報告" (3-4 items)
- [1] titleList: "来週のタスク" (3 items)
- [2] centerText: "備考"
- NOTE: ---区切りなし。見出し(##)ごとにページ分割される想定

## [8] Sample_Minimal.md — 最小構成（1ページのみ）
- title: "一枚スライド"
- pages: 1
- [0] centerText: "Hello, Slidys!"

## [9] Sample_NoTitle.md — デッキタイトルなし
- title: "Untitled" or ""
- pages: 3
- [0] centerText: "最初のスライド"
- [1] titleList: "構成について" (2 items, 1 indented)
- [2] code: "コードスライド" (Swiftコード)
- NOTE: # 見出しがないMarkdown。各ページ自体は正常にパース

## [10] Sample_SpecialCharacters.md — 特殊文字・絵文字
- title: "特殊文字 & 記号テスト"
- pages: 3
- [0] centerText: "絵文字テスト"（絵文字が保持される）
- [1] titleList: "特殊記号を含むリスト" (5 items, 2 indented)
- [2] code: "エスケープが必要な文字"（特殊文字コード）
- NOTE: 絵文字やHTML記号等が正しく保持されること

## [11] Sample_NumberList.md — 番号付きリストでページ分割
- title: "リスト形式のバリエーション"
- pages: 3 (トップレベル番号2,3,4がページ、1がタイトル)
- [0] titleList: "基本的なリスト" (3 items)
- [1] titleList: "ネスト構造" (3 items, 2 indented)
- [2] titleList: "番号付きリスト" (3 items)
- NOTE: ---や##を使わず番号付きリストのみでスライド構成。AIの柔軟パース力テスト
