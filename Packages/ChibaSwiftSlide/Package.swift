// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ChibaSwiftSlide",
    platforms: [.iOS(.v17), .macOS(.v13)],
    products: [
        .library(
            name: "ChibaSwiftSlide",
            targets: ["ChibaSwiftSlide"]),
    ],
    dependencies: [
        .package(path: "../SlidysCore"),
        .package(path: "../PianoUI"),
    ],
    targets: [
        .target(
            name: "ChibaSwiftSlide",
            dependencies: [
                "SlidysCore",
                "PianoUI",
            ]
        ),
        .testTarget(
            name: "ChibaSwiftSlideTests",
            dependencies: ["ChibaSwiftSlide"]),
    ]
)
