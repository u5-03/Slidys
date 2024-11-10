// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "KanagawaSwiftSlide",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(
            name: "KanagawaSwiftSlide",
            targets: ["KanagawaSwiftSlide"]),
    ],
    dependencies: [
        .package(path: "../SlidysCore"),
        .package(path: "../PianoUI"),
        .package(path: "../SymbolKit"),
    ],
    targets: [
        .target(
            name: "KanagawaSwiftSlide",
            dependencies: [
                "SlidysCore",
                "PianoUI",
                "SymbolKit",
            ]
        ),
        .testTarget(
            name: "KanagawaSwiftSlideTests",
            dependencies: ["KanagawaSwiftSlide"]),
    ]
)
