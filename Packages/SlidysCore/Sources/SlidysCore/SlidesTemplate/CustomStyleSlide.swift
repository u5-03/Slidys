//
//  CustomStyleSlide.swift
//  Slidys
//
//  Created by Yugo Sugiyama on 2024/10/27.
//

import SwiftUI
import SlideKit

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
            VStack(alignment: .leading, spacing: 48) {
                configuration.content
                    .lineLimit(nil)
                    .minimumScaleFactor(0.1)
                    .font(.system(size: 60, weight: .medium))
                    .foregroundStyle(.defaultForegroundColor)
            }
            Spacer()
        }
        .padding(60)
        .background(.slideBackgroundColor)
    }
}

public struct CustomItemStyle: ItemStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 28) {
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
            }

            if let child = configuration.child {
                child
                    .minimumScaleFactor(0.01)
                    .padding(.leading, 60)

            }
        }
    }
}

#Preview {
    SlidePreview {
        CustomStyleSlide()
    }
}

