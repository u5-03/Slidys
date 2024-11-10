// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SlidysCore",
    platforms: [.iOS(.v17), .macOS(.v13)],
    products: [
        .library(
            name: "SlidysCore",
            targets: ["SlidysCore"]),
    ],
    dependencies: [
        .package(url: "https://github.com/mtj0928/SlideKit", from: "0.4.0"),
    ],
    targets: [
        .target(
            name: "SlidysCore",
            dependencies: [
                "SlideKit",
            ]
        ),
        .testTarget(
            name: "SlidysCoreTests",
            dependencies: ["SlidysCore"]
        ),
    ]
)
