import SwiftUI
import SlideKit
import SlidesCore
import SymbolKit

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
        CenterTextSlide(text: "手話/Sign Languageは普段触れる機会が少ない")
        CenterTextSlide(text: "テクノロジーの力でそのハードルを少しでも越えられる？？")
        CenterTextSlide(text: "今回はApple Vision Proのハンドジェスチャー\n検知を使って、その可能性と限界を探ります！")
        TitleSlide()
        TalkPlanSlide()
        GestureDetectionStructionSlide()
        
        // HandSkeletonとEntityの基礎
        HandSkeletonStructureSlide()
        EntityPlacementSlide()
        RealityKitSystemSlide()
        EntityDemoSlide()
        
        // フレームワーク比較
        FrameworkComparisonSlide()
        
        // 実装詳細
        TrackingSystemImplementationSlide()
        CustomGestureDemoSlide()
        GestureDetectorLogicSlide()
        
        // 手話ジェスチャー
        SignLanguageDemoSlide()
        LimitationsSlide()

        WrapUpSlide()
        ReferenceSlide()
    }
}
