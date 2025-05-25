//
//  AutoScrollTextView.swift
//  iOSDC2024Slide
//
//  Created by Yugo Sugiyama on 2024/07/27.
//

import SwiftUI
import Foundation
import Observation
import Algorithms

#if os(macOS)
import AppKit
public typealias AppFont = NSFont
public typealias AppColor = NSColor
#elseif os(iOS) || os(visionOS)
import UIKit
public typealias AppFont = UIFont
public typealias AppColor = UIColor
#endif

public struct AutoScrollTextView: View {
    // Making the controller optional allows you to place the MarqueeView before text is available to display without crashing your app.
    @State var controller: AutoScrollController
    private let beginingEmptyWidthRatio: CGFloat

    public init(controller: AutoScrollController, beginingEmptyWidthRatio: CGFloat = 1.1) {
        self.controller = controller
        self.beginingEmptyWidthRatio = beginingEmptyWidthRatio
    }

    public var body: some View {
        TimelineView(.animation) { context in
            let autoScrollCalculationType: AutoScrollCalculationType
            switch controller.autoScrollType {
            case .timer(let duration):
                let progress: CGFloat
                if let startTime = controller.startTime {
                    let newProgress = (Double(context.date.timeIntervalSince1970) - startTime) / Double(duration.components.seconds)
                    controller.progress = newProgress
                    progress = newProgress
                } else {
                    progress = 0
                }
                autoScrollCalculationType = .timer(
                    duration: duration,
                    progress: progress
                )
            case .speed(let speed):
                let elapsedTime: CGFloat
                if let startTime = controller.startTime {
                    let newElapsedTime = context.date.timeIntervalSince1970 - startTime
                    controller.elapsedTime = newElapsedTime
                    elapsedTime = newElapsedTime
                } else {
                    elapsedTime = 0
                }
                autoScrollCalculationType = .speed(speed: speed, elapsedTime: elapsedTime)
            }
            return AutoScrollLayout(
                beginingEmptyWidthRatio: beginingEmptyWidthRatio,
                autoScrollCalculationType: autoScrollCalculationType
            ) {
                ForEach(controller.splittedMessage, id: \.self) { message in
                    Text(message)
                        .font(Font(controller.marqueeFont))
                        .foregroundStyle(.primary)
                }
            }
//            .onAppear {
//                if progress >= 1 {
//                    controller.startTime = nil
//                }
//            }
        }
        .clipped()
    }
}

fileprivate struct AutoScrollLayout: Layout {
    fileprivate let beginingEmptyWidthRatio: CGFloat
    fileprivate let autoScrollCalculationType: AutoScrollCalculationType

    fileprivate struct Cache {
        var widths: [CGFloat]
        var startPoints: [CGFloat]
        var totolWidth: CGFloat
    }

    fileprivate func makeCache(subviews: Subviews) -> Cache {
        var startPoint: CGFloat = 0
        var startPoints: [CGFloat] = []
        var widths: [CGFloat] = []
        subviews.forEach { subView in
            let width = subView.sizeThatFits(.unspecified).width
            startPoints.append(startPoint)
            startPoint += width
            widths.append(width)
        }
        return Cache(widths: widths, startPoints: startPoints, totolWidth: startPoint)
    }

    fileprivate func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) -> CGSize {
        return proposal.replacingUnspecifiedDimensions()
    }

    fileprivate func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) {
        let totalWidth = cache.totolWidth
        let displayWidth = proposal.width ?? 0
        // Add space of displayWidth * beginingEmptyWidthRatio to leading
        let beginingEmptyWidth = displayWidth * beginingEmptyWidthRatio
        let displayStartPoint = switch autoScrollCalculationType {
        case .timer(_, let progress):
            (totalWidth + beginingEmptyWidth) * CGFloat(progress)
        case .speed(let speed, let elapsedTime):
            speed * CGFloat(elapsedTime)
        }
        let displayEndPoint = displayStartPoint + displayWidth
        for (index, subview) in subviews.indexed() {
            let startPoint = cache.startPoints[index] + beginingEmptyWidth
            let textWidth = cache.widths[index]
            let endPoint = startPoint + textWidth
            // Place only if subview is within view range
            if displayStartPoint <= endPoint || startPoint <= displayEndPoint {
                let subviewX = bounds.minX + (startPoint + beginingEmptyWidth) - displayStartPoint
                subview.place(
                    at: CGPoint(x: subviewX, y: bounds.midY),
                    anchor: .leading,
                    proposal: .init(
                        width: textWidth,
                        height: proposal.height ?? 0
                    )
                )
            }
        }
    }
}

public enum AutoScrollType {
    case timer(duration: Duration)
    case speed(speed: CGFloat) // move points per second
}

fileprivate enum AutoScrollCalculationType {
    case timer(duration: Duration, progress: Double)
    case speed(speed: CGFloat, elapsedTime: CGFloat)
}

@Observable
public final class AutoScrollController {
    fileprivate var startTime: Double?
    fileprivate var progress: Double?
    fileprivate var elapsedTime: Double?
    fileprivate let autoScrollType: AutoScrollType
    // Using a AppFont because the width can be measured.
    public let marqueeFont: AppFont
    fileprivate var splittedMessage: [String] = []
    private let messageUnit = 50
    private let message: String

    public func formattedTime(format: String = "%d:%02d") -> String? {
        switch autoScrollType {
        case .timer(let duration):
            guard let progress else { return nil }
            let remainingTime = max(0, Double(duration.components.seconds) * (1.0 - progress))
            // Convert remaining time to minutes and seconds
            let minutes = Int(remainingTime) / 60
            let seconds = Int(remainingTime) % 60

            // Format to m:ss format
            return String(format: format, minutes, seconds)
        case .speed:
            guard let elapsedTime else { return nil }
            let seconds = Int(elapsedTime)
            let minutes = seconds / 60
            let remainingSeconds = seconds % 60
            return String(format: format, minutes, remainingSeconds)
        }
    }

    public init(message: String, autoScrollType: AutoScrollType, marqueeFont: AppFont = AppFont.systemFont(ofSize: 40, weight: .bold)) {
        self.message = message
        self.autoScrollType = autoScrollType
        self.marqueeFont = marqueeFont
    }

//    fileprivate func progress(currentDate: Date) -> CGFloat {
//        guard let startTime else { return 0 }
//        switch autoScrollType {
//        case .timer(let duration):
//            
//            self.progress = progress
//            return progress
//        case .speed:
//            return 0
//        }
//    }

    public func startScrolling() {
        splittedMessage = message.removingNewlines.splitStringIntoChunks(chunkSize: messageUnit)
        startTime = Date().timeIntervalSince1970
    }
}

fileprivate extension String {
    var removingNewlines: String {
        return self.components(separatedBy: .newlines).joined()
    }

    func width(usingFont font: AppFont) -> CGFloat {
        let attributes = [NSAttributedString.Key.font: font]
        return (self as NSString).size(withAttributes: attributes).width
    }

    func splitStringIntoChunks(chunkSize: Int) -> [String] {
        var chunks: [String] = []
        var currentIndex = startIndex

        while currentIndex < endIndex {
            let endIndex = index(currentIndex, offsetBy: chunkSize, limitedBy: endIndex) ?? endIndex
            let chunk = String(self[currentIndex..<endIndex])
            chunks.append(chunk)
            currentIndex = endIndex
        }
        return chunks
    }
}

#Preview {
    let controller = AutoScrollController(
        message: introductionSentence,
        autoScrollType: .timer(duration: .seconds(10))
//        autoScrollType: .speed(speed: 100)
    )
    return HStack {
        Group {
            if let formatRemainingTime = controller.formattedTime() {
                Text(formatRemainingTime)
                    .font(.system(size: 30, weight: .bold))
                    .minimumScaleFactor(0.1)
                    .frame(width: 60)
            } else {
                Button(action: {
                    controller.startScrolling()
                }, label: {
                    Image(systemName: "play")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .padding(4)
                })
            }
        }
        .padding()
        AutoScrollTextView(controller: controller)
            .frame(height: 80, alignment: .leading)
            .onAppear {
                //                controller.startScrolling()
            }
    }
}
