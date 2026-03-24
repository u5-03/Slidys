import SlideKit
import SlidesCore
import SwiftUI
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
    let slideIndexController = SlideIndexController {
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
                secondText: "iOSDCのスタッフしてます",
                thirdText: "11月に実施するKanagawa.swift #2の運営もしています",
                fourthText: "来月末に戸建て新居ができるので、引越しします🍍",
                fifthText: "来週ドイツで別のカンファレンス登壇があるので、Day2の夜にそのまま羽田空港へ向かいます"
            )
        )
//        TalkPlanSlide()
        GestureDetectionStructionSlide()

        // HandSkeletonとEntityの基礎
        HandLocationStructureSlide()
        // HandSkeletonDiagramSlide()
        ViewSlide {
            Text("デモ")
                .font(.extraLargeFont)
                .padding()
            Text("手の部位にマーカーを表示")
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
        VideoSlide(videoType: .handGestureEntitySample)
        VideoSlide(videoType: .handGestureSignLanguage)
        GestureDetectorLogicSlide()
        SerialGestureSystemSlide()

        // 手話ジェスチャー
        LimitationsSlide()
        PossibilitiesSlide()

        WrapUpSlide()
        ReferenceSlide()
        CenterTextSlide(text: "おわり")
        OneMoreThingSlide()
        CenterTextSlide(text: "僕/私/俺もApple Vision Proで\nハンドジェスチャー試したいなー！")
        ContentSlide(headerTitle: "HandGestureKit爆誕!") {
            Image(.handGestureKit)
                .resizable()
                .scaledToFit()
        }
        EndSlide()
    }
}
