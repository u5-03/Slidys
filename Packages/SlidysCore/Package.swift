// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SlidysCore",
    platforms: [.iOS(.v17), .macOS(.v15)],
    products: [
        .library(
            name: "SlidesCore",
            targets: ["SlidesCore"]
        ),
        .library(
            name: "SlidysCommon",
            targets: ["SlidysCommon"]
        ),
        .library(
            name: "iOSDCSlide",
            targets: ["iOSDCSlide"]
        ),
        .library(
            name: "ChibaSwiftSlide",
            targets: ["ChibaSwiftSlide"]
        ),
        .library(
            name: "KanagawaSwiftSlide",
            targets: ["KanagawaSwiftSlide"]
        ),
        .library(
            name: "FlutterKaigiSlide",
            targets: ["FlutterKaigiSlide"]
        ),
        .library(
            name: "OsakaSwiftSlide",
            targets: ["OsakaSwiftSlide"]
        ),
        .library(
            name: "MinokamoSwiftSlide",
            targets: ["MinokamoSwiftSlide"]
        ),
        .library(
            name: "GoToNextPlatformSlide",
            targets: ["GoToNextPlatformSlide"]
        ),
        .library(
            name: "TrySwiftTokyoSlide",
            targets: ["TrySwiftTokyoSlide"]
        ),
        .library(
            name: "NagoyaSwiftSlide",
            targets: ["NagoyaSwiftSlide"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/mtj0928/SlideKit", from: "0.4.0"),
        .package(url: "https://github.com/cybozu/WebUI", from: "2.3.0"),
        .package(url: "https://github.com/u5-03/YugiohCardEffect", from: "0.3.0"),
        .package(url: "https://github.com/apple/swift-algorithms.git", from: "1.0.0"),
        .package(path: "../PianoUI"),
        .package(path: "../SymbolKit"),
    ],
    targets: [
        .target(
            name: "SlidesCore",
            dependencies: [
                "SlideKit",
                "WebUI",
                "YugiohCardEffect",
                "SymbolKit",
                .product(name: "Algorithms", package: "swift-algorithms"),
            ],
            resources: [
                .process("Resources/opening_input.mp4"),
                .process("Resources/opening_output.mp4"),
                .process("Resources/book_animation.mp4"),
            ]
        ),
        .target(
            name: "SlidysCommon",
            dependencies: [
                "iOSDCSlide",
                "ChibaSwiftSlide",
                "KanagawaSwiftSlide",
                "OsakaSwiftSlide",
                "MinokamoSwiftSlide",
                "GoToNextPlatformSlide",
                "TrySwiftTokyoSlide",
                "NagoyaSwiftSlide",
            ]
        ),
        .target(
            name: "iOSDCSlide",
            dependencies: [
                "SlidesCore",
                "PianoUI",
                .product(name: "Algorithms", package: "swift-algorithms")
            ]
        ),
        .target(
            name: "ChibaSwiftSlide",
            dependencies: [
                "SlidesCore",
                "PianoUI",
            ]
        ),
        .target(
            name: "KanagawaSwiftSlide",
            dependencies: [
                "SlidesCore",
                "PianoUI",
                "SymbolKit",
            ]
        ),
        .target(
            name: "FlutterKaigiSlide",
            dependencies: [
                "SlidesCore",
                "PianoUI",
            ],
            resources: [
                .process("Resources/vision_pro_piano_demo.mp4"),
            ]
        ),
        .target(
            name: "OsakaSwiftSlide",
            dependencies: [
                "SlidesCore",
                "PianoUI",
                "SymbolKit",
            ]
        ),
        .target(
            name: "MinokamoSwiftSlide",
            dependencies: [
                "SlidesCore",
                "PianoUI",
                "SymbolKit",
            ]
        ),
        .target(
            name: "GoToNextPlatformSlide",
            dependencies: [
                "SlidesCore",
            ]
        ),
        .target(
            name: "TrySwiftTokyoSlide",
            dependencies: [
                "SlidesCore",
            ]
        ),
        .target(
            name: "NagoyaSwiftSlide",
            dependencies: [
                "SlidesCore",
                "PianoUI",
                "SymbolKit",
            ]
        ),
        .testTarget(
            name: "KanagawaSwiftSlideTests",
            dependencies: ["KanagawaSwiftSlide"]
        ),
    ],
    swiftLanguageModes: [.v5]
)

