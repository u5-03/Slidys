import SwiftUI
import SlideKit
import SlidesCore
import SymbolKit
#if canImport(HandGesturePackage)
import HandGesturePackage
#endif

public struct iOSDC2025SlideView: SlideViewProtocol {
    let configuration = SlideConfiguration()

    public init() {}

    public var body: some View {
        SlideBaseView(slideConfiguration: configuration, timerDuration: Duration.seconds(60 * 20))
    }
}

struct SlideConfiguration: SlideConfigurationProtocol {
    @MainActor
    let slideIndexController = SlideIndexController() {
        CenterTextSlide(text: "iOSDC Japan 2025")
        CenterTextSlide(text: "これは何を示しているか、分かりますか？")
        CenterTextSlide(text: "手話/Sign Languageは\n普段触れる機会が少ない")
        CenterTextSlide(text: "テクノロジーの力でそのハードルを\n少しでも下げることができる？？")
        CenterTextSlide(text: "今回はApple Vision Proの\nハンドジェスチャー検知を使って、\nその可能性と限界を探ります！")
        TitleSlide()
        ReadmeSlide(
            title: "README",
            info: .init(
                name: "すぎー/Sugiy",
                image: .icon,
                firstText: "DeNAでFlutterのスポーツ系ライブ配信アプリplay-by-sports開発中",
                secondText: "11月にやるKanagawa.swift #2の運営をしています",
                thirdText: "iOSDCのスタッフもしてます",
                fourthText: "来月末に戸建て新居ができるので、引越しします",
                fifthText: "明後日の夜に羽田空港からドイツに行き、別のカンファレンスで登壇してきます"
            )
        )
        TalkPlanSlide()
        GestureDetectionStructionSlide()

        // HandSkeletonとEntityの基礎
        HandSkeletonStructureSlide()
        HandSkeletonDiagramSlide()
        ViewSlide {
            Text("デモ")
                .font(.extraLargeFont)
                .padding()
            Text("手の関節にマーカーを表示")
                .font(.largeFont)
                .padding()
        }
        RealityKitSystemSlide()
        ContentSlide(headerTitle: "偉大なパンフレット記事が...!") {
            Image(.ecsPamphlet)
                .resizable()
                .scaledToFit()
        }
        EntityPlacementSlide()

//        PerformanceOptimizationSlide()
        // 実装詳細
        TrackingSystemImplementationSlide()
        ViewSlide {
            Text("デモ")
                .font(.extraLargeFont)
                .padding()
            Text("ジェスチャーや手話の検知")
                .font(.largeFont)
                .padding()
            Text("冒頭の手話の答え合わせ")
                .font(.largeFont)
                .padding()
        }
        GestureDetectorLogicSlide()
        SerialGestureSystemSlide()
        
        // 手話ジェスチャー
        LimitationsSlide()
        PossibilitiesSlide()

        WrapUpSlide()
        ReferenceSlide()
    }
}
