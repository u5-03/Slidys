//
//  SlideTheme.swift
//
//
//  Created by Yugo Sugiyama on 2024/11/10.
//

import SwiftUI
import SlideKit

/// リスト(HeaderSlide 内の Item)本文の文字サイズ・行間の設定。
/// デッキ単位で調整できるようにし、既存デッキはプリセット(`.standard` / `.large`)のまま影響を受けない。
public struct ListTextStyle: Sendable {
    /// 本文(Item)のフォントサイズ
    public var contentFontSize: CGFloat
    /// 項目同士の縦スペース
    public var contentSpacing: CGFloat
    /// 本文が折り返したときの行間
    public var contentLineSpacing: CGFloat
    /// 見出し(HeaderSlideのタイトル)のフォントサイズ。
    /// 本文とのジャンプ率を上げたいデッキは本文と一緒に大きくする。
    public var headerFontSize: CGFloat
    /// 見出し領域の高さ。フォントサイズに合わせて確保する。
    public var headerHeight: CGFloat

    public init(
        contentFontSize: CGFloat = 45,
        contentSpacing: CGFloat = 30,
        contentLineSpacing: CGFloat = 0,
        headerFontSize: CGFloat = 72,
        headerHeight: CGFloat = 100
    ) {
        self.contentFontSize = contentFontSize
        self.contentSpacing = contentSpacing
        self.contentLineSpacing = contentLineSpacing
        self.headerFontSize = headerFontSize
        self.headerHeight = headerHeight
    }

    /// 従来どおり(45pt)
    public static let standard = ListTextStyle()
    /// 文字少なめ・話し中心のデッキ向け(60pt、行間広め)
    public static let large = ListTextStyle(
        contentFontSize: 60,
        contentSpacing: 44,
        headerFontSize: 84,
        headerHeight: 120
    )

    var contentFont: Font {
        .system(size: contentFontSize, weight: .semibold)
    }

    var headerFont: Font {
        .system(size: headerFontSize, weight: .bold)
    }
}

@MainActor
public struct CustomSlideTheme: SlideTheme {
    public let headerSlideStyle: CustomHeaderSlideStyle
    public let itemStyle = CustomItemStyle()
    public let indexStyle: CustomIndexStyle

    public init(
        showSlideIndex: Bool = true,
        showsTotalSlideCount: Bool = true,
        listTextStyle: ListTextStyle = .standard
    ) {
        self.headerSlideStyle = CustomHeaderSlideStyle(listTextStyle: listTextStyle)
        self.indexStyle = CustomIndexStyle(isVisible: showSlideIndex, showsTotalSlideCount: showsTotalSlideCount)
    }
}

@Slide
public struct CustomStyleSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    public init() {}

    public var body: some View {
        HeaderSlide("Custom Style Slide") {
            Item("Header Slide Style") {
                Item("You can customize the layout of HeaderSlide by HeaderSlideStyle")
            }
            Item("Item Style") {
                Item("You can also customize the design of Item by ItemStyle.You can also customize the design of Item by ItemStyle.", accessory: .number(2))
            }
        }
        .headerSlideStyle(CustomHeaderSlideStyle())
        .itemStyle(CustomItemStyle())
    }
}


public struct CustomHeaderSlideStyle: HeaderSlideStyle {
    private let listTextStyle: ListTextStyle

    public init(listTextStyle: ListTextStyle = .standard) {
        self.listTextStyle = listTextStyle
    }

    public func makeBody(configuration: Configuration) -> some View {
        GeometryReader { proxy in
            VStack(alignment: .leading, spacing: 40) {
                configuration.header
                    .font(listTextStyle.headerFont)
                    .lineLimit(1)
                    .minimumScaleFactor(0.1)
                    .foregroundStyle(.themeColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: listTextStyle.headerHeight)
                VStack(alignment: .leading, spacing: listTextStyle.contentSpacing) {
                    configuration.content
                        .font(listTextStyle.contentFont)
                        .lineSpacing(listTextStyle.contentLineSpacing)
                        .foregroundStyle(.defaultForegroundColor)
                }
            }
            .padding(60)
            .frame(width: proxy.size.width)
            .frame(maxHeight: .infinity, alignment: .topLeading)
            .background(.slideBackgroundColor)
        }
    }
}

public struct CustomItemStyle: ItemStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                switch configuration.accessory {
                case .bullet:
                    Text("・").bold()
                case .number(let number):
                    Text("\(number). ")
                case .string(let string):
                    Text("\(string). ")
                case nil:
                    EmptyView()
                }
                configuration.label
                    .lineLimit(4)
            }

            if let child = configuration.child {
                child
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 60)
            }
        }
    }
}

public struct CustomIndexStyle: IndexStyle {
    private let isVisible: Bool
    private let showsTotalSlideCount: Bool

    public init(isVisible: Bool = true, showsTotalSlideCount: Bool = true) {
        self.isVisible = isVisible
        self.showsTotalSlideCount = showsTotalSlideCount
    }

    public func makeBody(configuration: Configuration) -> some View {
#if os(visionOS)
        EmptyView()
#else
        if isVisible {
            // 総数を出すと「残り何枚か」が分かってしまうデッキ向けに、現在ページのみの表示も選べる
            let current = configuration.slideIndexController.currentIndex + 1
            let text = showsTotalSlideCount
                ? "\(current) / \(configuration.slideIndexController.slides.count)"
                : "\(current)"
            Text(text)
                .foregroundColor(.gray)
                .font(.system(size: 30))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .padding()
        }
#endif
    }
}

@Slide
struct AnimationStructureSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        HeaderSlide("Structure of animation implementation") {
            Item("Explained how to animate SwiftUI Paths", accessory: .number(1))
            Item("Simple topic, but one that has many applications", accessory: .number(2))
            Item("As an application, we played the Japan Symbol Quiz to guess the Japan symbol", accessory: .number(3)) {
                Item("Did you have fun?", accessory: .number(1))
            }
            Item("There are a few other quizzes available too", accessory: .number(4))
        }
    }
}

#Preview {
    SlidePreview {
        ReadmeSlide(
            title: "README",
            info: .init(
                name: "すぎー/Sugiy",
                image: .icon,
                firstText: "DeNAでFlutterのスポーツ系ライブ配信アプリplay-by-sports開発中",
                secondText: "神山.swiftからJapan-\\\\(Region)-Swiftコンプリート中",
                thirdText: "1月に岐阜(minokamo.swift)に来たとき以来の名古屋！",
                fourthText: "今月try!SwiftTokyo2025で登壇して、来月FlutterNinjas2025でも登壇",
                fifthText: "再来月からの家のBuildに向け、土地の雑草抜きを絶賛計画中..!"
            )
        )
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
    .indexStyle(CustomIndexStyle())
}
