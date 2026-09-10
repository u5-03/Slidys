// swift-tools-version: 6.2
// スライドデッキを ImageRenderer でヘッドレス描画し、1枚ずつ PNG に書き出す macOS 用ツール。
// 使い方: Tools/snapshot_slides.sh を参照(xcodebuild でビルドして実行する)。
import PackageDescription

let package = Package(
    name: "SlideSnapshot",
    platforms: [.macOS(.v26)],
    products: [
        .executable(name: "SlideSnapshot", targets: ["SlideSnapshot"])
    ],
    dependencies: [
        .package(path: "../../Packages/SlidysCore"),
        .package(url: "https://github.com/mtj0928/SlideKit", from: "0.7.0"),
    ],
    targets: [
        .executableTarget(
            name: "SlideSnapshot",
            dependencies: [
                .product(name: "SlidesCore", package: "SlidysCore"),
                .product(name: "iOSDC2026Slide", package: "SlidysCore"),
                .product(name: "SlideKit", package: "SlideKit"),
            ]
        )
    ],
    swiftLanguageModes: [.v5]
)
