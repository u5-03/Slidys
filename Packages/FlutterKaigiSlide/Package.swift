// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FlutterKaigiSlide",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(
            name: "FlutterKaigiSlide",
            targets: ["FlutterKaigiSlide"]),
    ],
    dependencies: [
        .package(path: "../SlidysCore"),
        .package(path: "../PianoUI"),
    ],
    targets: [
        .target(
            name: "FlutterKaigiSlide",
            dependencies: [
                "SlidysCore",
                "PianoUI",
            ]
        ),
        .testTarget(
            name: "FlutterKaigiSlideTests",
            dependencies: ["FlutterKaigiSlide"]),
    ]
)
