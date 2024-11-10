// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FlutterKaigiSlide",
    platforms: [.iOS(.v17), .macOS(.v13)],
    products: [
        .library(
            name: "FlutterKaigiSlide",
            targets: ["FlutterKaigiSlide"]),
    ],
    dependencies: [
        .package(path: "../SlidysCore"),
        .package(url: "https://github.com/mtj0928/SlideKit", from: "0.4.0"),
    ],
    targets: [
        .target(
            name: "FlutterKaigiSlide",
            dependencies: [
                "SlideKit",
                "SlidysCore",
            ]
        ),
        .testTarget(
            name: "FlutterKaigiSlideTests",
            dependencies: ["FlutterKaigiSlide"]),
    ]
)
