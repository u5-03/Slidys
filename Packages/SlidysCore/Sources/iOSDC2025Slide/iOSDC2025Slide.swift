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
        ContentSlide(headerTitle: "visionOS用のデモを開始する") {
#if canImport(HandGesturePackage)
            StartDemoButton(fontSize: 80)
#else
            Text("visionOSでのみデモは開始できます")
#endif
        }

        // HandSkeletonとEntityの基礎
        HandSkeletonStructureSlide()
        HandSkeletonDiagramSlide()
        EntityPlacementSlide()
        RealityKitSystemSlide()
        
        // フレームワーク比較
        FrameworkComparisonSlide()
        PerformanceOptimizationSlide()
        
        // 実装詳細
        TrackingSystemImplementationSlide()
        CustomGestureDemoSlide()
        GestureDetectorLogicSlide()
        SerialGestureSystemSlide()
        
        // 手話ジェスチャー
        SignLanguageDemoSlide()
        LimitationsSlide()
        PossibilitiesSlide()

        WrapUpSlide()
        ReferenceSlide()
    }
}
