// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "iOSDCSlide",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(
            name: "iOSDCSlide",
            targets: ["iOSDCSlide"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-algorithms.git", from: "1.0.0"),
        .package(path: "../SlidysCore"),
        .package(path: "../PianoUI"),
    ],
    targets: [
        .target(
            name: "iOSDCSlide",
            dependencies: [
                "SlidysCore",
                "PianoUI",
                .product(name: "Algorithms", package: "swift-algorithms")
            ]
        ),
        .testTarget(
            name: "iOSDCSlideTests",
            dependencies: ["iOSDCSlide"]),
    ]
)
