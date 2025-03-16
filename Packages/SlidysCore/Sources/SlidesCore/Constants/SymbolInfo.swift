//
//  SymbolInfo.swift
//  SlidysCore
//
//  Created by yugo.sugiyama on 2025/01/23.
//

import SwiftUI
import SymbolKit

public struct SymbolInfo {
    public let quizIndex: Int
    public let answer: String
    public let answerHint: String
    public let aspectRatio: CGFloat
    public let pathAnimationType: PathAnimationType
    public let shape: any Shape
    public let questionDrawingDuration: Duration
    public let answerDrawingDuration: Duration
    public let lineWidth: CGFloat
    public let answerAlternativeContent: AnyView?

    public init(quizIndex: Int, answer: String, answerHint: String = "", aspectRatio: CGFloat, pathAnimationType: PathAnimationType = .progressiveDraw, shape: any Shape, questionDrawingDuration: Duration = .seconds(60), answerDrawingDuration: Duration = .seconds(5), lineWidth: CGFloat = 5, answerAlternativeContent: AnyView? = nil) {
        self.quizIndex = quizIndex
        self.answer = answer
        self.answerHint = answerHint
        self.aspectRatio = aspectRatio
        self.pathAnimationType = pathAnimationType
        self.shape = shape
        self.questionDrawingDuration = questionDrawingDuration
        self.answerDrawingDuration = answerDrawingDuration
        self.lineWidth = lineWidth
        self.answerAlternativeContent = answerAlternativeContent
    }
}
