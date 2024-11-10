//
//  BookView.swift
//  iOSDC2024Slide
//
//  Created by Yugo Sugiyama on 2024/08/12.
//

import SwiftUI

// Ref: https://www.youtube.com/watch?v=MAUvXkxLnvk&t=631s
struct BookView: View {
    @State private var shouldShowCover = true
    @State private var shouldShowBihind = false
    @State private var shouldCloseBihind = true
    @State private var shouldMove = false
    @State private var isAnimating = false
    private let didOpen: () -> Void

    private let pageDuration: TimeInterval = 0.5
    private var moveDuration: TimeInterval {
        return pageDuration * 0.8
    }

    init(didOpen: @escaping () -> Void) {
        self.didOpen = didOpen
    }

    var body: some View {
        GeometryReader { proxy in
            let length = min(proxy.size.height, proxy.size.width)
            return ZStack(alignment: .center) {
                BookBehindSecondView(shouldShowBihind: $shouldShowBihind, shouldMove: $shouldMove)
                    .frame(width: length, height: length)
                BookBehindView(shouldShowBihind: $shouldShowBihind, shouldCloseBihind: $shouldCloseBihind)
                    .frame(width: length, height: length)
                BookCoverView(shouldShow: $shouldShowCover, shouldMove: shouldMove)
                    .frame(width: length, height: length)
            }
            .offset(x: shouldMove ? length / 2 : 0)
            .scaleEffect(x: shouldMove ? 1 : 0.6, y: shouldMove ? 1 : 0.8)
            .onTapGesture {
                if shouldShowCover {
                    toggleOpen()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.white)
        }
        .ignoresSafeArea()
    }

    struct BookCoverView: View {
        @Binding var shouldShow: Bool
        let shouldMove: Bool

        var body: some View {
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .foregroundStyle(.black)
                        .frame(width: proxy.size.width * 0.04)
                    Rectangle()
                        .foregroundStyle(Color(.darkGray))
                        .frame(width: proxy.size.width * 0.01)
                        .padding(.leading, proxy.size.width * 0.02)

                    // GeometryReader内でalignmentが効かない
                    VStack(spacing: proxy.size.height * 0.08) {
                        Text("iOSDC Lighting Talk")
                            .lineSpacing(10)
                            .foregroundStyle(.defaultForegroundColor)
                            .bold()
                            .font(.custom("Georgia", fixedSize: proxy.size.height * 0.08))
                            .minimumScaleFactor(0.001)
                            .padding(.top, proxy.size.height * 0.04)
                            .padding(.horizontal, proxy.size.width * 0.04 + 10)
                        ViewThatFits(in: .vertical) {
                            MusicNoteMaskView()
                                .containerRelativeFrame([.horizontal, .vertical], { length, _ in
                                    return length * 0.3
                                })
                                .scaleEffect(x: shouldMove ? 1 : 1.4)
                            MusicNoteMaskView()
                                .frame(height: proxy.size.height / 2)
                                .scaleEffect(x: shouldMove ? 1 : 1.4)
                        }
                        Text("Presented by Sugiy")
                            .foregroundStyle(.defaultForegroundColor)
                            .bold()
                            .minimumScaleFactor(0.001)
                            .font(.custom("Georgia", fixedSize: proxy.size.height * 0.05))
                            .padding(.horizontal, proxy.size.width * 0.04 + 10)
                            .padding(.vertical, proxy.size.height * 0.025)
                    }
                }
                .frame(width: proxy.size.width)
                .clipped()
                .frame(maxWidth: .infinity)
                .background(.black)
                .rotation3DEffect(
                    .degrees(shouldShow ? 0 : -90),
                    axis: (x: 0, y: 1, z: 0),
                    anchor: .leading,
                    anchorZ: 0,
                    perspective: 0.3
                )
            }
        }
    }

    struct BookBehindView: View {
        @Binding var shouldShowBihind: Bool
        @Binding var shouldCloseBihind: Bool

        var body: some View {
            ZStack(alignment: .leading) {
                Color.slideBackgroundColor
                Text("ある")
                    .minimumScaleFactor(0.1)
                    .font(.largeFont)
                    .rotation3DEffect(
                        .degrees(-180),
                        axis: (x: 0, y: 1, z: 0)
                    )
            }
            .rotation3DEffect(
                .degrees(shouldShowBihind ? -180 : 0),
                axis: (x: 0, y: 1, z: 0),
                anchor: .leading,
                anchorZ: 0,
                perspective: 0.3
            )
            .opacity(shouldCloseBihind ? 1 : 0)

        }
    }

    struct BookBehindSecondView: View {
        @Binding var shouldShowBihind: Bool
        @Binding var shouldMove: Bool

        var body: some View {
            ZStack(alignment: .leading) {
                Color.slideBackgroundColor
                Text("日...")
                    .minimumScaleFactor(0.1)
                    .font(.largeFont)
            }
        }
    }
}

private extension BookView {
    func toggleOpen() {
        isAnimating = true
        if shouldShowCover {
            withAnimation(.linear(duration: pageDuration)) {
                shouldShowCover.toggle()
            } completion: {
                shouldCloseBihind = true
            }
            withAnimation(.linear(duration: pageDuration * 2)) {
                shouldShowBihind.toggle()
            } completion: {
                didOpen()
            }
            withAnimation(.linear(duration: moveDuration).delay(moveDuration)) {
                shouldMove.toggle()
            }
        } else {
            withAnimation(.linear(duration: pageDuration).delay(pageDuration)) {
                shouldShowCover.toggle()
            } completion: {
                shouldCloseBihind = false
            }
            withAnimation(.linear(duration: pageDuration * 2)) {
                shouldShowBihind.toggle()
            }
            withAnimation(.linear(duration: moveDuration).delay(moveDuration)) {
                shouldMove.toggle()
            }
        }
    }
}


#Preview {
    BookView() {}
        .frame(width: 800, height: 400)
}
#Preview {
    BookView() {}
        .frame(width: 200, height: 800)
}
