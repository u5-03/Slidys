// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI
import SlideKit
import SlidysCore

public struct iOSDCSlideView: View {

    public init() {}

    public var body: some View {
        iosdcSlideBaseView()
            .foregroundStyle(.defaultForegroundColor)
            .background(.slideBackgroundColor)
    }
}

struct SlideConfiguration: SlideConfigurationProtocol {

    ///  「ある日」の分のスライドはスキップする
    let slideIndexController = SlideIndexController(index: 1) {
        CenterTextSlide(text: .init(localized: "someday", defaultValue: "ある日..."))
        TitleImageSlide()
        CenterTextSlide(text: .init(localized: "degital_piano", defaultValue: "電子ピアノ"))
        CenterTextSlide(text: .init(localized: "degitalPianoEqualGadget", defaultValue: "電子ピアノ=ガジェット"))
        CenterTextSlide(text: .init(localized: "iWantToPlay", defaultValue: "なので何か使って遊びたい！"))
        TitleSlide()
        CenterTextSlide(text: .init(localized: "implementationAppOfPianoWithStroke", defaultValue: "今回はピアノの鍵盤を叩く強さを\n表示できるアプリを実装しました"))
        OsTitleSlide(shouldAnimated: false)
        CenterTextSlide(text: .init(localized: "pianoWithMidi", defaultValue: "我が家の電子ピアノはMIDIの\n規格に対応している"))
        MidiSlide()
        PianoStrokeInfoSlide()
        PianoStrokeConstructionSlide()
        ConnectionChartSlide()
        PianoImageCompareSlide()
        PianoViewStructureSlide()
        CenterTextSlide(text: .init(localized: "playDemoVideo", defaultValue: "デモ動画を流します"))
        CenterTextSlide(text: .init(localized: "byTheWay", defaultValue: "ちなみに..."))
        AppendixSlide()
        CenterTextSlide(text: .init(localized: "connectWirelessDevice", defaultValue: "有線を繋げないデバイスでも利用できる！"))
        OneMoreThingSlide()
        OsTitleSlide(shouldAnimated: true)
        CenterTextSlide(text: .init(localized: "playVisionProDemoVideo", defaultValue: "Vision Proでのデモ動画を流します!"))
        VideoSlide(videoName: "opening_input", fileExtension: "mp4")
        ImageSlide(imageName: "ipadAppCapture")
        VideoSlide(videoName: "opening_output", fileExtension: "mp4")
        WrapupSlide()
        ReadmeSlide()
        ReferenceSlide()
        EndSlide()
    }
}
