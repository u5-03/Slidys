#!/usr/bin/env python3
"""FlutterKaigi2026 デッキの String Catalog(Localizable.xcstrings)を作る。

キーは日本語の文言そのもの(スライドのコードに書いてある文字列)。ここに英訳を足して実行すると
Packages/SlidysCore/Sources/FlutterKaigi2026Slide/Localizable.xcstrings を書き出す。
強調語(keywords)は、訳した本文にそのまま出てくる語にしておくこと。

使い方: python3 Tools/SlideLocalization/flutterkaigi2026_strings.py
"""
import json
import os
import re
import sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
DECK = os.path.join(ROOT, "Packages/SlidysCore/Sources/FlutterKaigi2026Slide")
OUT = os.path.join(DECK, "Localizable.xcstrings")

EN = {
    # つかみ
    "みなさん": "Everyone",
    "エンジニアの人？": "Any engineers here?",
    "バグチケットの対応を\nしたことある人？": "Who has worked on\na bug ticket?",
    "QAテストをしたことある人？": "Who has done QA testing?",
    "バグチケットの対応は\n場合によっては大変なことが多い": "Working on bug tickets\ncan often be tough",
    "エンジニア": "Engineer",
    "再現手順が不明確": "Unclear repro steps",
    "環境情報がない": "No environment info",
    "OS・デバイス・ビルド番号": "OS, device, build number",
    "画像や動画がない": "No images or video",
    "画面のどこかわからない": "Where on the screen?",
    "もちろん、バグチケットの起票も大変です": "Of course, filing bug tickets is hard too",
    "できる限り省力化して\nチケットを起票する方法の一例を\nお話しします": "Today: one way to file tickets\nwith as little effort as possible",

    # タイトル / 自己紹介
    "その不具合、どのWidgetですか？": "Which Widget Is That Bug In?",
    "― アプリ内で“直せるバグ報告”を作る": "― Building fixable bug reports, in-app",
    "DeNAのiOS/Flutterエンジニア": "iOS/Flutter engineer at DeNA",
    "FlutterKaigiは2024の前夜祭LT以来2回目": "2nd FlutterKaigi talk, after the 2024 pre-event LT",
    "去年末までFlutterアプリ、今はiPadOSアプリのプロジェクト": "On a Flutter app until late last year; now on an iPadOS app",
    "最近車と3Dプリンターを買ってお金が...💸": "Just bought a car and a 3D printer… my wallet 💸",
    "iPhone Duoを検討中…": "Thinking about getting an iPhone Duo…",

    # バグ起票の流れ
    "バグ起票の流れ: いま と アプリ内バグ起票": "Filing bugs: today vs. in-app",
    "いまの一般的な流れ": "The usual flow today",
    "アプリ内バグ起票(iPadOSアプリで運用中)": "In-app bug filing (in use in our iPadOS app)",
    "バグや改善点を検知": "Spot a bug or idea",
    "動画やスクショの用意": "Video / screenshots",
    "自分で撮る": "Capture it yourself",
    "手動で情報を入力して起票": "Write it up and file",
    "再現手順や環境情報の記載、ファイルの添付": "Repro steps, environment info, attachments",
    "アプリが自動で撮影開始": "The app records automatically",
    "起票": "File the ticket",
    "環境情報などは自動入力": "Environment info auto-filled",
    "Actionsで下調べ・振り分け": "Triage in Actions",
    "起票後は自動": "Automatic after filing",

    # 今日話すこと / 章扉
    "今日話すこと": "Today's topics",
    "画面上のWidgetをタップして、対象のWidgetを選ぶ": "Tap a Widget on screen to pick the target",
    "静止画リングバッファ + デバイスで動画化して、不具合の動画を作る": "Still-frame ring buffer + on-device encoding to make a bug video",
    "Widget階層・ログ・環境情報を一緒にチケットに添付する": "Attach the Widget tree, logs, and environment info to the ticket",
    "画面上のWidgetをタップして選ぶ": "Pick a Widget by tapping the screen",
    "静止画リングバッファ + デバイスで動画化": "Still-frame ring buffer + on-device video",
    "Widget階層・ログ・環境情報を添付する": "Attach Widget tree, logs, environment info",

    # 1. 要素ピッカー
    "「画面のどこ」が明確だと直しやすい": "Knowing exactly where makes fixing easier",
    "曖昧だと不具合箇所を探すところから始まる": "If it's vague, you start by hunting for the spot",
    "探すところから": "hunting for the spot",
    "AI に修正を頼むときも、どの Widget かが正確に直させる材料になる": "When asking AI to fix it, the exact Widget is key context",
    "AI に修正を頼むとき": "asking AI to fix it",
    "報告する人は画面上で対象の Widget をタップするだけにしたい": "Reporters should only need to tap the Widget on screen",
    "タップするだけ": "only need to tap",
    "タップした Widget が枠で囲まれる": "The tapped Widget gets outlined",
    "「要素を選ぶ」で選択モードへ": "\"Pick element\" enters selection mode",
    "報告したい Widget をタップ": "Tap the Widget you want to report",
    "タップ": "Tap",
    "入れ子は一番小さい要素が選ばれる": "When nested, the smallest element wins",
    "一番小さい要素": "smallest element",
    "「この要素にする」で確定して起票画面へ反映": "\"Use this element\" confirms and fills the form",
    "確定": "confirms",
    "Flutter デモ": "Flutter demo",
    "発表時はここに実際の画面が表示されます": "The live screen appears here during the talk",
    "Flutterの3つのツリー": "Flutter's three trees",
    "設計図": "Blueprint",
    "build() で書く不変の構成。\n状態が変わるたび描き直される。\n位置もサイズも持たない": "Immutable config written in build().\nRebuilt whenever state changes.\nHas no position or size",
    "部品の台帳": "Parts ledger",
    "設計図から建てられた実体の一覧。\n設計図と実物の両方を知っている。\nrootElement が根": "The instances built from blueprints.\nKnows both blueprint and real thing.\nrootElement is the root",
    "実物(レイアウト・描画)": "The real thing",
    "サイズと座標を持つのはここだけ。\nlocalToGlobal で画面座標に": "The only one with size and position.\nlocalToGlobal gives screen coordinates",
    "仕組みの肝": "How it works",
    "Element ツリーをたどり、RenderObject の位置を取る": "Walk the Element tree to get RenderObject positions",
    "RenderBox.localToGlobal で画面座標に変換する": "RenderBox.localToGlobal gives screen coordinates",
    "目印は Semantics(identifier:) / ValueKey。a11y対応がデバッグ資産に": "Markers: Semantics(identifier:) / ValueKey. a11y work becomes a debug asset",
    "タップ位置を含む候補のうち、面積が最小の要素を選ぶ": "Pick the smallest-area candidate under the tap",
    "面積が最小": "smallest-area",

    # 2. 画面リプレイ
    "事象が起きてから動画を撮るのは手間": "Recording after it happens is a hassle",
    "起きたあとに撮り直すのは手間。": "Re-recording afterwards is a hassle.",
    "撮り直すのは手間": "Re-recording afterwards is a hassle",
    "再現が難しいと、再現させるのに時間がかかる(そもそも再現しないことも)": "Hard-to-repro bugs take time to reproduce (or never reproduce)",
    "再現しない": "never reproduce",
    "現在のiPadOSのプロジェクトのアプリ: 裏で静止画を撮り続けて直近60秒をリングバッファに → 起票時に動画化": "Our current iPadOS app: keeps capturing stills into a 60-second ring buffer → makes a video when filing",
    "リングバッファ": "ring buffer",
    "Flutterでも作れる？ 3段階に分けて検証": "Can Flutter do it too? Tested in 3 steps",
    "3段階": "3 steps",
    "3段階に分けて考える": "Break it into 3 steps",
    "① フレーム取得": "① Capture frames",
    "△ Flutterだけだと不十分": "△ Flutter alone isn't enough",
    "toImage では PlatformView が黒い → ネイティブで View 階層ごと撮る": "toImage shows PlatformViews as black → capture the whole view hierarchy natively",
    "② リングバッファ": "② Ring buffer",
    "◎ Flutterだけで可": "◎ Flutter alone works",
    "tmp に PNG を書き続けて、古い分を削除": "Keep writing PNGs to tmp and delete the old ones",
    "③ 動画エンコード": "③ Video encoding",
    "× Dartだけでは不可": "× Not possible in Dart alone",
    "ネイティブのエンコーダを MethodChannel で呼ぶ": "Call the native encoder through a MethodChannel",
    "作ってみてわかった注意点": "Lessons learned building it",
    "撮影はネイティブで画面ごと。PlatformView も写る": "Capture the whole screen natively. PlatformViews are included",
    "ネイティブで画面ごと": "whole screen natively",
    "秒数・解像度・fps はプロジェクトに合わせて調整": "Tune duration, resolution, and fps for your project",
    "プロジェクトに合わせて調整": "for your project",
    "フレームはファイルに溜め、古い順に消す": "Store frames in files and delete the oldest first",
    "ファイルに溜め": "in files",
    "負荷が重い処理は、実行時に OFF にできるようにする": "Make heavy work switchable OFF at runtime",
    "OFF にできる": "switchable OFF",

    # 3. 診断情報
    "Issueに載せる情報": "What goes into the Issue",
    "報告する人が選ぶ(任意・スキップ可)": "Chosen by the reporter (optional, can skip)",
    "機械が自動で集める": "Collected automatically",
    "選択したUI要素": "Selected UI element",
    "報告とコードを結ぶアンカー": "Anchor linking the report to code",
    "スクリーンショット": "Screenshot",
    "見た目の証拠": "Visual evidence",
    "直近の動画": "Recent video",
    "起きるまでの流れ": "What led up to it",
    "Widget階層": "Widget tree",
    "その瞬間の画面構造": "Screen structure at that moment",
    "ログ": "Logs",
    "直前に何が起きていたか": "What happened just before",
    "スタックトレース": "Stack trace",
    "どの経路で来たか": "How execution got there",
    "環境情報": "Environment info",
    "端末・OS・バージョン依存の切り分け": "Isolating device / OS / version issues",
    "最大の差分: ログは自分で溜める": "Biggest difference: collect logs yourself",
    "Flutter には iOS の OSLogStore 相当の API がない": "Flutter has no API like iOS's OSLogStore",
    "OSLogStore 相当の API がない": "no API like iOS's OSLogStore",
    "mein() で debugPrint / print / onError をフックして流し込む": "In mein(), hook debugPrint / print / onError and feed them in",
    "mein() で": "In mein(),",
    "起動時からアプリ内リングバッファに直近 1000 行を保持し、起票時に添付": "From launch, keep the latest 1000 lines in an in-app ring buffer and attach on filing",
    "起動時から": "From launch,",
    "起票後はGitHub Actionsにおまかせ(発展)": "After filing, GitHub Actions takes over (advanced)",
    "ラベルをトリガーに Actions で後処理(AI の下調べなど)": "Labels trigger post-processing in Actions (e.g. AI research)",
    "ラベルをトリガー": "Labels trigger",
    "ラベルの種類で、タスク管理 / バグ管理どちらの Projects に入れるかを判定": "The label type decides which Projects board: tasks or bugs",
    "ラベルの種類": "label type",
    "小ネタ: ラベルは2段階で付ける(同時付与だと concurrency で run がキャンセルされる)": "Tip: add labels in 2 steps (adding them at once cancels the run via concurrency)",
    "2段階": "2 steps",

    # まとめ
    "なぜ作ったのか(課題意識)": "Why we built it",
    "コミュニケーションコストの削減。情報不足による確認のやりとりを無くしたい": "Cut communication cost. No more back-and-forth over missing info",
    "コミュニケーションコストの削減": "Cut communication cost",
    "AI で増えるエンジニアのアウトプットに対して、QA の負荷を減らしたい": "As AI boosts engineering output, reduce the load on QA",
    "QA の負荷": "load on QA",
    "AI に修正させるための正確なコンテキストとして、そのまま渡せるチケットにしたい": "Tickets that can be handed to AI as accurate context for the fix",
    "AI に修正させる": "handed to AI",
    "QA チームに聞いてみた": "We asked the QA team",
    "よかった点": "What worked well",
    "不具合の箇所をエンジニアに明確に伝えられる": "Can show engineers exactly where the bug is",
    "動画を撮り直さなくていいのが楽": "No need to re-record videos",
    "環境情報などの入力漏れ・間違いがなくなった": "No more missing or wrong environment info",
    "大変だった点と工夫": "Pain points and workarounds",
    "iPad での長文入力は大変": "Typing long text on an iPad is hard",
    "音声入力で書く・大枠だけ起票して PC で整える": "Use dictation, or file a rough draft and polish it on a PC",
    "まとめ": "Wrap-up",
    "AI は機能開発だけでなく、効率化や QA の負荷削減にも": "Use AI beyond features: for efficiency and a lighter QA load",
    "効率化や QA の負荷削減": "efficiency and a lighter QA load",
    "AI でツールを作るコストとハードルは大きく下がった": "AI has greatly lowered the cost and hurdle of building tools",
    "コストとハードル": "cost and hurdle",
    "まずは自分で QA をして、課題意識を QA チームと共有": "Do QA yourself first, and share the pain points with your QA team",
    "自分で QA": "Do QA yourself",

    # 紹介と締め
    "YouTube 動画の紹介": "A YouTube video to check out",
    "YouTube で公開中": "Now on YouTube (in Japanese)",
    "終わり": "The End",
}

# 訳さずそのまま出す文言(固有名など)。チェックで「訳が無い」と言われないようにする
UNTRANSLATED = {"FlutterKaigi 2026", "Element", "Semantics(identifier:)", "localToGlobal"}

# いまのデッキ(SlideConfiguration.swift)で使っていないスライド。訳のチェックから外す
UNUSED_SLIDES = {
    "BeforeAfterSlide.swift",
    "DiagnosticsMotivationSlide.swift",
    "EndSlide.swift",
    "IssueBodySlide.swift",
    "ReferenceSlide.swift",
    "ReplayDesignBranchSlide.swift",
    "WidgetTreeSlide.swift",
}


def keys_in_source():
    """コードから拾える範囲のキー(loc: "…" / "…".loc / keywords: […] / centerText("…"))"""
    literal = r'"((?:[^"\\]|\\.)*)"'
    found = set()
    for dirpath, _, files in os.walk(DECK):
        for name in files:
            if not name.endswith(".swift") or name in UNUSED_SLIDES:
                continue
            text = open(os.path.join(dirpath, name), encoding="utf-8").read()
            for pattern in (r"loc: " + literal, literal + r"\.loc\b", r"centerText\(\s*" + literal):
                found.update(re.findall(pattern, text))
            for group in re.findall(r"keywords: \[([^\]]*)\]", text):
                found.update(re.findall(literal, group))
    return {k.replace("\\n", "\n").replace('\\"', '"') for k in found}


def main():
    strings = {}
    for key, value in sorted(EN.items()):
        strings[key] = {"localizations": {"en": {"stringUnit": {"state": "translated", "value": value}}}}
    for key in sorted(UNTRANSLATED):
        strings[key] = {"shouldTranslate": False}
    catalog = {"sourceLanguage": "ja", "strings": strings, "version": "1.0"}
    with open(OUT, "w", encoding="utf-8") as f:
        json.dump(catalog, f, ensure_ascii=False, indent=2, sort_keys=True)
        f.write("\n")
    print(f"wrote {len(strings)} strings → {os.path.relpath(OUT, ROOT)}")

    missing = sorted(k for k in keys_in_source() if k not in EN and k not in UNTRANSLATED)
    if missing:
        print("英訳が無いキー(日本語のまま表示されます):")
        for key in missing:
            print("  -", key.replace("\n", "\\n"))
        sys.exit(1)


if __name__ == "__main__":
    main()
