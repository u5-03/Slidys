// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SlidysCore",
    platforms: [.iOS(.v17), .macOS(.v14)],
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
    ],
    dependencies: [
        .package(url: "https://github.com/mtj0928/SlideKit", from: "0.4.0"),
        .package(url: "https://github.com/cybozu/WebUI", from: "2.3.0"),
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
            ],
            resources: [
                .process("Resources/opening_input.mp4"),
                .process("Resources/opening_output.mp4"),
            ]
        ),
        .target(
            name: "SlidysCommon",
            dependencies: [
                "iOSDCSlide",
                "ChibaSwiftSlide",
                "KanagawaSwiftSlide",
                "OsakaSwiftSlide",
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
        .testTarget(
            name: "KanagawaSwiftSlideTests",
            dependencies: ["KanagawaSwiftSlide"]
        ),
    ],
    swiftLanguageModes: [.v5]
)

