// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PianoUI",
    platforms: [.iOS(.v17), .macOS(.v14), .visionOS(.v2)],
    products: [
        .library(
            name: "PianoUI",
            targets: ["PianoUI"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "PianoUI",
            dependencies: []
        ),
        .testTarget(
            name: "PianoUITests",
            dependencies: ["PianoUI"]),
    ]
)
