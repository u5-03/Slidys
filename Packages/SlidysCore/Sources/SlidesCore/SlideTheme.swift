//
//  SlideTheme.swift
//
//
//  Created by Yugo Sugiyama on 2024/11/10.
//

import SwiftUI
import SlideKit

public struct CustomSlideTheme: SlideTheme {
    public let headerSlideStyle = CustomHeaderSlideStyle()
    public let itemStyle = CustomItemStyle()
    public let indexStyle = CustomIndexStyle()

    public init() {}
}

@Slide
public struct CustomStyleSlide: View {
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
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 40) {
            configuration.header
                .font(.mediumFont)
                .lineLimit(1)
                .minimumScaleFactor(0.1)
                .foregroundStyle(.themeColor)
                .frame(maxWidth: .infinity, alignment: .leading)
            VStack(alignment: .leading, spacing: 30) {
                configuration.content
                    .font(.system(size: 60, weight: .medium))
                    .foregroundStyle(.defaultForegroundColor)
            }
        }
        .padding(60)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(.slideBackgroundColor)
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
                    .lineLimit(2)
            }

            if let child = configuration.child {
                child
                    .padding(.leading, 60)

            }
        }
    }
}

public struct CustomIndexStyle: IndexStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        Text("\(configuration.slideIndexController.currentIndex + 1) / \(configuration.slideIndexController.slides.count)")
            .foregroundColor(.gray)
            .font(.system(size: 30))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            .padding()
    }
}

@Slide
struct AnimationStructureSlide: View {
    var body: some View {
        HeaderSlide("Structure of animation implementation") {
            Item("Explained how to animate SwiftUI Paths", accessory: .number(1))
            Item("Simple topic, but one that has many applications", accessory: .number(2))
            Item("As an application, we played the Japan Symbol Quiz to guess the Japan symbol", accessory: .number(3)) {
                Item("Did you have fun?", accessory: .number(1))
            }
            Item("There are a few other quizzes available too", accessory: .number(4)) {
                Item("If you want to try, please come to Ask The Speaker or the DeNA sponsor booth", accessory: .number(1))
            }
        }
    }
}

#Preview {
    SlidePreview {
        AnimationStructureSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
    .indexStyle(CustomIndexStyle())
}
