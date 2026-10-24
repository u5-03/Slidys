//
//  DiagnosticsTableSlide.swift
//  FlutterKaigi2026Slide
//
//  Issue に載せる情報を「報告する人が選ぶもの(任意)」と「機械が自動で集めるもの」に分けて一覧にする。
//  スクショと動画は自動では載せない。撮ったものを報告する人が明示的に選んで添付する。
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct DiagnosticsTableSlide: View {
    /// スピーカーノート(表は最初から全部見せる)
    var script: String {
        """
        Issue に載せる情報は 2 種類に分けています。
        上の 3 つは、報告する人が明示的に選びます。さっきのWidgetピッカーで選ぶ UI 要素と、スクショ、動画です。スクショや動画は勝手には載せず、選んで添付します。どれも必須ではないので、スキップもできます。
        下の 4 つは、手動だと記入漏れが起きるので、起票のときに自動で集めます。Widget 階層は、要素ピッカーと同じようにツリーをたどってテキストにしたものです。
        ログは不具合修正で重要な情報の1つです。
        """
    }

    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    private struct Row: Identifiable {
        let id: Int
        let kind: String
        let role: String
    }

    private struct Group: Identifiable {
        let id: Int
        let title: String
        let color: Color
        let rows: [Row]
    }

    private let groups: [Group] = [
        // スクショと動画は自動では載せない。撮ったものを明示的に選んで添付する(どれも任意)
        .init(id: 0, title: "報告する人が選ぶ(任意・スキップ可)", color: .defaultForegroundColor, rows: [
            .init(id: 0, kind: "選択したUI要素", role: "報告とコードを結ぶアンカー"),
            .init(id: 1, kind: "スクリーンショット", role: "見た目の証拠"),
            .init(id: 2, kind: "直近の動画", role: "起きるまでの流れ"),
        ]),
        .init(id: 1, title: "機械が自動で集める", color: .strokeColor, rows: [
            .init(id: 3, kind: "Widget階層", role: "その瞬間の画面構造"),
            .init(id: 4, kind: "ログ", role: "直前に何が起きていたか"),
            .init(id: 5, kind: "スタックトレース", role: "どの経路で来たか"),
            .init(id: 6, kind: "環境情報", role: "端末・OS・バージョン依存の切り分け"),
        ]),
    ]

    var body: some View {
        HeaderSlide(loc: "Issueに載せる情報") {
            // 列見出しと罫線は置かず、2 つのまとまり(人が選ぶ / 機械が集める)を大きな見出しと間隔で分ける
            VStack(spacing: 40) {
                ForEach(groups) { group in
                    VStack(alignment: .leading, spacing: 10) {
                        Text(group.title.loc)
                            .font(.system(size: 48, weight: .heavy))
                            .foregroundStyle(group.color)
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                            .padding(.bottom, 6)
                        ForEach(group.rows) { row in
                            HStack(spacing: 24) {
                                Text(row.kind.loc)
                                    .font(.system(size: 46, weight: .bold))
                                    .foregroundStyle(.themeColor)
                                    .frame(width: 520, alignment: .leading)
                                Text(row.role.loc)
                                    .font(.system(size: 42, weight: .semibold))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                            .padding(.vertical, 6)
                        }
                    }
                    .padding(.horizontal, 36)
                    .padding(.vertical, 22)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .fill(Color.white.opacity(0.06))
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
}

#Preview {
    SlidePreview {
        DiagnosticsTableSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}
