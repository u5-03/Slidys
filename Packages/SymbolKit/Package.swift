// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SymbolKit",
    platforms: [.iOS(.v17), .macOS(.v13)],
    products: [
        .library(
            name: "SymbolKit",
            targets: ["SymbolKit"]),
    ],
    targets: [
        .target(
            name: "SymbolKit"),
        .testTarget(
            name: "SymbolKitTests",
            dependencies: ["SymbolKit"]),
    ]
)
