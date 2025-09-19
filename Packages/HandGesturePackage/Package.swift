// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HandGesturePackage",
    platforms: [
        .iOS(.v18),
        .macOS(.v15),
        .visionOS(.v2),
    ],
    products: [
        .library(
            name: "HandGesturePackage",
            targets: ["HandGesturePackage"])
    ],
    dependencies: [
        .package(path: "../HandGestureKit")
    ],
    targets: [
        .target(
            name: "HandGesturePackage",
            dependencies: ["HandGestureKit"]
        )
    ],
    swiftLanguageModes: [.v5]
)
