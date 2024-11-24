// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SlidysCore",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(
            name: "SlidysCore",
            targets: ["SlidysCore"]),
    ],
    dependencies: [
        .package(url: "https://github.com/mtj0928/SlideKit", from: "0.4.0"),
        .package(url: "https://github.com/cybozu/WebUI", from: "2.3.0"),
    ],
    targets: [
        .target(
            name: "SlidysCore",
            dependencies: [
                "SlideKit",
                "WebUI",
            ],
            resources: [
                .process("Resources/opening_input.mp4"),
                .process("Resources/opening_output.mp4"),
            ]
        ),
        .testTarget(
            name: "SlidysCoreTests",
            dependencies: ["SlidysCore"]
        ),
    ]
)
